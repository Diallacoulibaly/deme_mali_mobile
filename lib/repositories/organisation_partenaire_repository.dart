
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/organisation_partenaire.dart';

class OrganisationPartenaireRepository {
  final String baseUrl;
  final http.Client _client;

  OrganisationPartenaireRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Liste des organisations validées avec leurs informations de likes.
  Future<List<OrganisationPartenaire>> getOrganisationsAvecLikes({
    required int donateurId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/organisations-partenaires/liste-avec-likes',
    ).replace(
      queryParameters: {
        'donateurId': donateurId.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les organisations '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw const FormatException(
        'La réponse du serveur doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une organisation.',
        );
      }

      return OrganisationPartenaire.fromJson(element);
    }).toList();
  }

  /// Détails d'une organisation par son identifiant.
  Future<OrganisationPartenaire> getOrganisationById(
      int organisationId,
      ) async {
    final uri = Uri.parse(
      '$baseUrl/api/organisations-partenaires/$organisationId',
    );

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger cette organisation '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format incorrect pour les détails de l’organisation.',
      );
    }

    return OrganisationPartenaire.fromJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}

/// Repository disponible dans Riverpod.
final organisationPartenaireRepositoryProvider =
Provider<OrganisationPartenaireRepository>((ref) {
  const baseUrl = 'http://localhost:8080';

  final repository = OrganisationPartenaireRepository(
    baseUrl: baseUrl,
  );

  ref.onDispose(repository.dispose);

  return repository;
});

/// Chargement de la liste pour un donateur donné.
final organisationsAvecLikesProvider =
FutureProvider.family<List<OrganisationPartenaire>, int>(
      (ref, donateurId) {
    final repository = ref.watch(
      organisationPartenaireRepositoryProvider,
    );

    return repository.getOrganisationsAvecLikes(
      donateurId: donateurId,
    );
  },
);

/// Chargement des détails d'une organisation.
final organisationParIdProvider =
FutureProvider.family<OrganisationPartenaire, int>(
      (ref, organisationId) {
    final repository = ref.watch(
      organisationPartenaireRepositoryProvider,
    );

    return repository.getOrganisationById(organisationId);
  },
);
