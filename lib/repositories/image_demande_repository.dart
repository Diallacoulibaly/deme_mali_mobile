
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/image_demande.dart';

class ImageDemandeRepository {
  static const String baseUrl = 'http://localhost:8080/api';

  // Récupérer les images associées à une demande.
  Future<List<ImageDemande>> getImagesDemande(int demandeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/images-demandes/demande/$demandeId'),
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
    final response = await http.get(
      Uri.parse('$baseUrl/images-demandes/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer l’image (${response.statusCode}).',
      );
    }

    return ImageDemande.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

// Provider du repository des images.
final imageDemandeRepositoryProvider =
Provider<ImageDemandeRepository>((ref) {
  return ImageDemandeRepository();
});

// Provider pour charger les images d'une demande.
final imagesDemandeProvider =
FutureProvider.family<List<ImageDemande>, int>((ref, demandeId) {
  return ref
      .watch(imageDemandeRepositoryProvider)
      .getImagesDemande(demandeId);
});

// Provider pour charger une image par son identifiant.
final imageDemandeDetailProvider =
FutureProvider.family<ImageDemande, int>((ref, id) {
  return ref
      .watch(imageDemandeRepositoryProvider)
      .getImageById(id);
});
