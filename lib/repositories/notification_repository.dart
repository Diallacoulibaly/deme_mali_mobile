import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/notification_item.dart';
import 'auth_repository.dart';
import 'demande_aide_repository.dart';

class NotificationRepository {
  static const String baseUrl = AuthRepository.baseUrl;
  final FlutterSecureStorage stockage = const FlutterSecureStorage();
  final DemandeAideRepository demandeRepo = DemandeAideRepository();

  http.Client? _streamClient;

  // 1. Récupère l'historique des notifications depuis le backend Spring Boot
  Future<List<NotificationItem>> recupererHistoriqueBackend(String telephone) async {
    final telNettoye = telephone.replaceAll(RegExp(r'\s+'), '');
    if (telNettoye.isEmpty) return [];

    try {
      final url = Uri.parse('$baseUrl/api/notifications/user/$telNettoye');
      final reponse = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (reponse.statusCode == 200) {
        final dynamic donnees = jsonDecode(utf8.decode(reponse.bodyBytes));
        if (donnees is List) {
          return donnees
              .whereType<Map<String, dynamic>>()
              .map(NotificationItem.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Info historique notifications backend : $e');
    }
    return [];
  }

  // 2. Synthétise les notifications réelles depuis les dons reçus et demandes du bénéficiaire
  Future<List<NotificationItem>> synthetiserDepuisMetier(int? beneficiaireId) async {
    if (beneficiaireId == null) return [];
    final notifications = <NotificationItem>[];

    try {
      // A. Notifications des dons reçus / aides distribuées
      final aides = await demandeRepo.getAidesDistribueesByBeneficiaire(beneficiaireId);
      for (final aide in aides) {
        final dateDistribution = DateTime.tryParse(aide.dateDistribution ?? '') ?? DateTime.now();

        // Dons financiers reçus
        for (final affFin in aide.affectationsFinancieres) {
          final montant = affFin.montantAffecte;
          final date = DateTime.tryParse(affFin.dateAffectation ?? '') ?? dateDistribution;
          final montantLisible = montant.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          );

          notifications.add(
            NotificationItem(
              id: 'don_fin_${affFin.id}',
              type: TypeNotification.donRecu,
              titre: 'Nouveau don reçu !',
              message: 'Une contribution de $montantLisible FCFA a été allouée à votre demande.',
              date: date,
              demandeId: aide.demandeAideId,
              montant: montant,
            ),
          );
        }

        // Dons matériels reçus
        for (final affMat in aide.affectationsMaterielles) {
          final date = DateTime.tryParse(affMat.dateAffectation ?? '') ?? dateDistribution;
          notifications.add(
            NotificationItem(
              id: 'don_mat_${affMat.id}',
              type: TypeNotification.donRecu,
              titre: 'Don matériel alloué',
              message: 'Votre demande a reçu ${affMat.quantiteAffectee} ${affMat.unite} de ${affMat.designation}.',
              date: date,
              demandeId: aide.demandeAideId,
              quantite: '${affMat.quantiteAffectee} ${affMat.unite}',
            ),
          );
        }

        // Remise effective de l'aide
        if (aide.statut.toUpperCase() == 'DISTRIBUEE') {
          notifications.add(
            NotificationItem(
              id: 'distrib_${aide.id}',
              type: TypeNotification.distributionEffectuee,
              titre: 'Aide distribuée avec succès',
              message: 'Votre aide a été remise au lieu de distribution : ${aide.lieuDistribution ?? "Lieu convenu"}.',
              date: dateDistribution,
              demandeId: aide.demandeAideId,
            ),
          );
        }
      }

      // B. Notifications basées sur le statut des demandes d'aide
      final demandes = await demandeRepo.chargerMesDemandes(beneficiaireId: beneficiaireId);
      for (final demande in demandes) {
        final statut = demande.statut.toUpperCase();
        final titreDemande = demande.titre.trim();
        final dateDemande = demande.dateCreation ?? DateTime.now();

        if (statut == 'VALIDEE') {
          notifications.add(
            NotificationItem(
              id: 'demande_val_${demande.id}',
              type: TypeNotification.demandeValidee,
              titre: 'Demande validée',
              message: 'Votre demande « $titreDemande » a été validée par l’administrateur et est ouverte aux donateurs.',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        } else if (statut == 'REJETEE' || statut == 'REFUSEE') {
          notifications.add(
            NotificationItem(
              id: 'demande_rej_${demande.id}',
              type: TypeNotification.demandeRefusee,
              titre: 'Demande non retenue',
              message: 'Votre demande « $titreDemande » a été refusée.',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        }

        // Objectif 100% atteint
        if (demande.pourcentageCollecte >= 100) {
          notifications.add(
            NotificationItem(
              id: 'demande_100_${demande.id}',
              type: TypeNotification.objectifAtteint,
              titre: 'Objectif atteint à 100% !',
              message: 'Félicitations ! Votre demande « $titreDemande » a atteint la totalité de son objectif financier.',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Info synthèse notifications métier : $e');
    }

    return notifications;
  }

  // 3. Fusionne, applique l'état "lu / non lu" et trie chronologiquement
  Future<List<NotificationItem>> chargerToutesNotifications({
    required String telephone,
    int? beneficiaireId,
  }) async {
    final listes = await Future.wait([
      recupererHistoriqueBackend(telephone),
      synthetiserDepuisMetier(beneficiaireId),
    ]);

    final brutes = [...listes[0], ...listes[1]];
    final vues = <String, NotificationItem>{};

    for (final item in brutes) {
      vues[item.id] = item;
    }

    // Récupérer les IDs marqués comme lus
    final lusString = await stockage.read(key: 'notifications_lues');
    final idsLus = (lusString ?? '').split(',').toSet();

    final resultats = vues.values.map((notif) {
      if (idsLus.contains(notif.id)) {
        return notif.copyWith(lu: true);
      }
      return notif;
    }).toList();

    resultats.sort((a, b) => b.date.compareTo(a.date));
    return resultats;
  }

  // 4. Marquer une notification comme lue
  Future<void> marquerCommeLue(String id) async {
    final lusString = await stockage.read(key: 'notifications_lues');
    final idsLus = (lusString ?? '').split(',').where((e) => e.isNotEmpty).toSet();
    idsLus.add(id);
    await stockage.write(key: 'notifications_lues', value: idsLus.join(','));
  }

  // 5. Tout marquer comme lu
  Future<void> toutMarquerCommeLu(List<NotificationItem> notifications) async {
    final ids = notifications.map((n) => n.id).toSet();
    await stockage.write(key: 'notifications_lues', value: ids.join(','));
  }

  // 6. Écouter le flux Server-Sent Events (SSE) du backend Spring Boot en temps réel
  Stream<NotificationItem> ecouterStream(String telephone) async* {
    final telNettoye = telephone.replaceAll(RegExp(r'\s+'), '');
    if (telNettoye.isEmpty) return;

    _streamClient?.close();
    _streamClient = http.Client();

    try {
      final request = http.Request(
        'GET',
        Uri.parse('$baseUrl/api/notifications/stream/$telNettoye'),
      );
      request.headers['Accept'] = 'text/event-stream';

      final response = await _streamClient!.send(request);

      if (response.statusCode == 200) {
        String buffer = '';
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          final lines = buffer.split('\n');
          buffer = lines.removeLast();

          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('data:')) {
              final rawJson = trimmed.substring(5).trim();
              if (rawJson.isNotEmpty && rawJson != 'null') {
                try {
                  final decoded = jsonDecode(rawJson);
                  if (decoded is Map<String, dynamic>) {
                    if (decoded['type'] != 'CONNECTED') {
                      yield NotificationItem.fromJson(decoded);
                    }
                  }
                } catch (_) {}
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Flux SSE fermé ou erreur : $e');
    }
  }

  void fermerStream() {
    _streamClient?.close();
    _streamClient = null;
  }
}
