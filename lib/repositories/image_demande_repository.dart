import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/image_demande.dart';
import 'auth_repository.dart';

class ImageDemandeRepository {
  static const String baseUrl = '${AuthRepository.baseUrl}/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  // Récupérer les images associées à une demande.
  Future<List<ImageDemande>> getImagesDemande(int demandeId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/images-demandes/demande/$demandeId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les images (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'La réponse doit être une liste JSON.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => ImageDemande.fromJson(json))
        .toList();
  }

  // Récupérer une image par son identifiant.
  Future<ImageDemande> getImageById(int id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/images-demandes/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer l’image (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'La réponse doit être un objet JSON.',
      );
    }

    return ImageDemande.fromJson(decoded);
  }
}

// Provider du repository des images.
final imageDemandeRepositoryProvider =
Provider<ImageDemandeRepository>((ref) {
  return ImageDemandeRepository();
});

// Provider pour charger les images d'une demande précise.
final imagesDemandeProvider =
FutureProvider.family<List<ImageDemande>, int>((ref, demandeId) {
  return ref
      .watch(imageDemandeRepositoryProvider)
      .getImagesDemande(demandeId);
});

// Provider pour charger une image précise par son identifiant.
final imageDetailProvider =
FutureProvider.family<ImageDemande, int>((ref, id) {
  return ref
      .watch(imageDemandeRepositoryProvider)
      .getImageById(id);
});
