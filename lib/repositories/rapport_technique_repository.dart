
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/rapport_technique.dart';
import 'auth_repository.dart';

class RapportTechniqueRepository {
  static const String baseUrl = AuthRepository.baseUrl;

  Future<RapportTechnique?> getRapportTechniquePourDemande(
      int demandeId,
      ) async {
    // Étape 1 : récupérer l'étude de terrain.
    final etudeUrl = Uri.parse(
      '$baseUrl/api/etudes-terrain/demande/$demandeId',
    );

    final etudeResponse = await http.get(
      etudeUrl,
      headers: {'Accept': 'application/json'},
    );

    if (etudeResponse.statusCode == 404) {
      return null;
    }

    if (etudeResponse.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération de l’étude '
            '(${etudeResponse.statusCode}) : ${etudeResponse.body}',
      );
    }

    final etude =
    jsonDecode(etudeResponse.body) as Map<String, dynamic>;

    final etudeId = (etude['id'] as num).toInt();

    // Étape 2 : récupérer le rapport de besoin.
    final besoinUrl = Uri.parse(
      '$baseUrl/api/rapports-besoin/etude-terrain/$etudeId',
    );

    final besoinResponse = await http.get(
      besoinUrl,
      headers: {'Accept': 'application/json'},
    );

    if (besoinResponse.statusCode == 404) {
      return null;
    }

    if (besoinResponse.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération du rapport de besoin '
            '(${besoinResponse.statusCode}) : ${besoinResponse.body}',
      );
    }

    final besoin =
    jsonDecode(besoinResponse.body) as Map<String, dynamic>;

    final rapportBesoinId = (besoin['id'] as num).toInt();

    // Étape 3 : récupérer le rapport technique.
    final techniqueUrl = Uri.parse(
      '$baseUrl/api/rapports-techniques/rapport-besoin/'
          '$rapportBesoinId',
    );

    final techniqueResponse = await http.get(
      techniqueUrl,
      headers: {'Accept': 'application/json'},
    );

    if (techniqueResponse.statusCode == 404) {
      return null;
    }

    if (techniqueResponse.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération du rapport technique '
            '(${techniqueResponse.statusCode}) : '
            '${techniqueResponse.body}',
      );
    }

    final technique =
    jsonDecode(techniqueResponse.body) as Map<String, dynamic>;

    return RapportTechnique.fromJson(technique);
  }
}

// Provider Riverpod du repository.
final rapportTechniqueRepositoryProvider =
Provider<RapportTechniqueRepository>((ref) {
  return RapportTechniqueRepository();
});
