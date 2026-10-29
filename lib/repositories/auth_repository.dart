
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/reponse_connexion.dart';

class AuthRepository {
  // Adresse du backend Spring Boot
  static const String baseUrl = 'http://localhost:8080';

  // Stockage du token
  final FlutterSecureStorage stockage =
  const FlutterSecureStorage();

  // Connexion de l'utilisateur
  Future<ReponseConnexion> connexion({
    required String telephone,
    required String motDePasse,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final chrono = Stopwatch()..start();

    try {
      debugPrint('[CONNEXION] Envoi de la requête...');

      final reponse = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telephone': telephone.trim(),
          'motDePasse': motDePasse,
        }),
      )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        '[CONNEXION] Réponse HTTP reçue : '
            '${chrono.elapsedMilliseconds} ms',
      );

      if (reponse.statusCode != 200) {
        throw Exception(
          'Erreur HTTP ${reponse.statusCode} : ${reponse.body}',
        );
      }

      // Lire la réponse du backend
      final donnees =
      jsonDecode(reponse.body) as Map<String, dynamic>;

      // Convertir la réponse en objet Flutter
      final resultat = ReponseConnexion.fromJson(donnees);

      debugPrint(
        '[CONNEXION] JSON analysé : '
            '${chrono.elapsedMilliseconds} ms',
      );

      // Enregistrer le token reçu
      await stockage.write(
        key: 'accessToken',
        value: resultat.accessToken,
      ).timeout(const Duration(seconds: 5));

      debugPrint(
        '[CONNEXION] Token enregistré : '
            '${chrono.elapsedMilliseconds} ms',
      );

      return resultat;
    } on TimeoutException {
      debugPrint('[CONNEXION] Délai dépassé.');

      throw Exception(
        'La connexion prend trop de temps. '
            'Vérifiez que le serveur est démarré.',
      );
    } catch (e) {
      debugPrint('[CONNEXION] Erreur : $e');
      rethrow;
    } finally {
      chrono.stop();

      debugPrint(
        '[CONNEXION] Durée totale : '
            '${chrono.elapsedMilliseconds} ms',
      );
    }
  }

  // Récupérer le token enregistré
  Future<String?> recupererToken() async {
    return stockage.read(key: 'accessToken');
  }

  // Déconnexion : supprimer le token
  Future<void> deconnexion() async {
    await stockage.delete(key: 'accessToken');
  }
}
