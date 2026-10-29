
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/demande_aide.dart';

class DemandeAideRepository {
  static const String baseUrl = 'http://localhost:8080/api';

  // Données temporaires de démonstration.
  // Cette méthode est conservée sans modification.
  Future<List<DemandeAide>> chargerMesDemandes() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    return const [
      DemandeAide(
        id: 1,
        titre: 'Aide alimentaire',
        descriptionSituation:
        'Besoin de produits alimentaires pour la famille.',
        niveauUrgence: 'FORTE',
        statut: 'EN_ATTENTE',
        categorieDemandeNom: 'Alimentation',
        typeDemandeAide: 'MATERIELLE',
      ),
      DemandeAide(
        id: 2,
        titre: 'Soutien scolaire',
        descriptionSituation:
        'Fournitures scolaires pour les enfants.',
        niveauUrgence: 'NORMALE',
        statut: 'VALIDEE',
        categorieDemandeNom: 'Éducation',
        typeDemandeAide: 'MATERIELLE',
      ),
    ];
  }

  // Récupérer une demande précise depuis le backend.
  Future<DemandeAide> getDemandeById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/demandes-aide/$id'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'La réponse du serveur doit être un objet JSON.',
        );
      }

      return DemandeAide.fromJson(decoded);
    }

    if (response.statusCode == 404) {
      throw Exception('Demande d’aide introuvable : $id');
    }

    throw Exception(
      'Erreur lors du chargement de la demande '
          '(HTTP ${response.statusCode}).',
    );
  }
}

// Provider du repository.
final demandeAideRepositoryProvider =
Provider<DemandeAideRepository>((ref) {
  return DemandeAideRepository();
});
