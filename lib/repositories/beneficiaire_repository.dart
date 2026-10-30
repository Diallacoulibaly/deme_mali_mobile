
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/beneficiaire.dart';
import 'auth_repository.dart';

class BeneficiaireRepository {
  static const String baseUrl = '${AuthRepository.baseUrl}/api';

  /// Récupérer un bénéficiaire par son identifiant.
  Future<Beneficiaire> getBeneficiaireById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/beneficiaires/$id'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'La réponse doit être un objet JSON.',
        );
      }

      return Beneficiaire.fromJson(decoded);
    }

    if (response.statusCode == 404) {
      throw Exception('Bénéficiaire introuvable (ID : $id).');
    }

    throw Exception(
      'Impossible de récupérer le bénéficiaire '
          '(${response.statusCode}).',
    );
  }
}

/// Provider du repository.
final beneficiaireRepositoryProvider =
Provider<BeneficiaireRepository>((ref) {
  return BeneficiaireRepository();
});
