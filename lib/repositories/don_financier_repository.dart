
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/don_financier.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';
// URL du backend Spring Boot pour l'émulateur Android.
const String apiBaseUrl = AuthRepository.baseUrl;

// Client HTTP partagé par les dépôts.
// Client HTTP qui ajoute le token JWT à chaque requête.
class ClientAuthentifie extends http.BaseClient {
  final http.Client _interne;
  final Future<String?> Function() _lireToken;

  ClientAuthentifie(this._interne, this._lireToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _lireToken();

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return _interne.send(request);
  }

  @override
  void close() => _interne.close();
}



// Fournisseur du dépôt des dons financiers.
final donFinancierRepositoryProvider =
Provider<DonFinancierRepository>((ref) {
  return DonFinancierRepository(
    baseUrl: apiBaseUrl,
    client: ref.watch(httpClientProvider),
  );
});

class DonFinancierRepository {
  final String baseUrl;
  final http.Client client;

  DonFinancierRepository({
    required this.baseUrl,
    required this.client,
  });

  // Récupérer tous les dons financiers.
  Future<List<DonFinancier>> getAll() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/dons-financiers'),
    );

    _verifierReponse(response);

    final List<dynamic> donnees = jsonDecode(response.body);

    return donnees
        .map(
          (json) => DonFinancier.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  // Récupérer un don financier par son identifiant.
  Future<DonFinancier> getById(int id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/dons-financiers/$id'),
    );

    _verifierReponse(response);

    return DonFinancier.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }


  // Récupérer les dons financiers d'un donateur.
  Future<List<DonFinancier>> getByDonateur(
      int donateurId,
      ) async {
    final response = await client.get(
      Uri.parse(
        '$baseUrl/api/dons-financiers/donateur/$donateurId',
      ),
    );

    _verifierReponse(response);

    final List<dynamic> donnees = jsonDecode(response.body);

    return donnees
        .map(
          (json) => DonFinancier.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  // Récupérer les dons financiers d'une demande d'aide.
  Future<List<DonFinancier>> getByDemande(
      int demandeAideId,
      ) async {
    final response = await client.get(
      Uri.parse(
        '$baseUrl/api/dons-financiers/demande/$demandeAideId',
      ),
    );

    _verifierReponse(response);

    final List<dynamic> donnees = jsonDecode(response.body);

    return donnees
        .map(
          (json) => DonFinancier.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  // Récupérer le total des dons financiers confirmés.
  Future<double> getTotalDons() {
    return _getMontant(
      '/api/dons-financiers/statistiques/total',
    );
  }

  // Récupérer le total des dons affectés.
  Future<double> getTotalDonsAffectes() {
    return _getMontant(
      '/api/dons-financiers/statistiques/affectes',
    );
  }

  // Récupérer le total des dons généraux.
  Future<double> getTotalDonsGeneraux() {
    return _getMontant(
      '/api/dons-financiers/statistiques/generaux',
    );
  }

  // Vérifier le montant avant un don affecté à une demande.
  Future<bool> verifierMontant({
    required int demandeAideId,
    required double montant,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/dons-financiers/demande/'
          '$demandeAideId/verifier-montant',
    ).replace(
      queryParameters: {
        'montant': montant.toString(),
      },
    );

    final response = await client.get(uri);

    _verifierReponse(response);

    final resultat = jsonDecode(response.body);

    if (resultat is bool) {
      return resultat;
    }

    throw Exception(
      'La réponse de vérification du montant est invalide.',
    );
  }

  // Récupérer une statistique numérique.
  Future<double> _getMontant(String chemin) async {
    final response = await client.get(
      Uri.parse('$baseUrl$chemin'),
    );

    _verifierReponse(response);

    final resultat = jsonDecode(response.body);

    if (resultat is num) {
      return resultat.toDouble();
    }

    throw Exception(
      'Le montant retourné par le serveur est invalide.',
    );
  }

  // Vérifier les erreurs HTTP.
  void _verifierReponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Erreur HTTP ${response.statusCode}';

    try {
      final resultat = jsonDecode(response.body);

      if (resultat is Map<String, dynamic>) {
        message = resultat['message']?.toString() ??
            resultat['error']?.toString() ??
            message;
      } else if (response.body.isNotEmpty) {
        message = response.body;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw Exception(message);
  }
  /// Total des dons financiers confirmés d'un donateur
  /// pendant une période.
  Future<double> getTotalConfirmeParPeriode({
    required int donateurId,
    required DateTime debut,
    required DateTime fin,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/dons-financiers/donateur/'
          '$donateurId/statistiques/periode',
    ).replace(
      queryParameters: {
        'debut': _formaterDate(debut),
        'fin': _formaterDate(fin),
      },
    );

    final response = await client.get(uri);

    _verifierReponse(response);

    final dynamic resultat = jsonDecode(response.body);

    if (resultat is num) {
      return resultat.toDouble();
    }

    throw Exception(
      'Le total financier retourné par le serveur est invalide.',
    );
  }

  String _formaterDate(DateTime date) {
    final annee = date.year.toString().padLeft(4, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final jour = date.day.toString().padLeft(2, '0');

    return '$annee-$mois-$jour';
  }
}
