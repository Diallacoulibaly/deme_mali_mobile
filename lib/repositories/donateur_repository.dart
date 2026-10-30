
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/donateur.dart';

// Adapte cette URL à ton environnement.
// Émulateur Android : http://10.0.2.2:8080
// Téléphone physique : http://IP_LOCALE_DU_PC:8080
const String apiBaseUrl = 'http://10.0.2.2:8080';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final donateurRepositoryProvider = Provider<DonateurRepository>((ref) {
  return DonateurRepository(
    baseUrl: apiBaseUrl,
    client: ref.watch(httpClientProvider),
  );
});

final donateurProvider =
FutureProvider.family<Donateur, int>((ref, id) {
  return ref.watch(donateurRepositoryProvider).getById(id);
});

final tousLesDonateursProvider =
FutureProvider<List<Donateur>>((ref) {
  return ref.watch(donateurRepositoryProvider).getAll();
});

class DonateurRepository {
  final String baseUrl;
  final http.Client client;

  DonateurRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<Donateur> getById(int id) async {
    final response = await _get('/api/donateurs/$id');
    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Donateur>> getAll() async {
    final response = await _get('/api/donateurs');

    if (response is! List) {
      throw const FormatException(
        'La réponse doit être une liste de donateurs.',
      );
    }

    return response.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Un donateur reçu est invalide.',
        );
      }

      return Donateur.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<Donateur> modifierPays({
    required int donateurId,
    required int paysId,
  }) async {
    final response = await _request(
      'PATCH',
      '/api/donateurs/$donateurId/pays/$paysId',
    );

    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  Future<Donateur> creer(Map<String, dynamic> donnees) async {
    final response = await _request(
      'POST',
      '/api/donateurs',
      body: donnees,
    );

    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  Future<dynamic> _get(String path) async {
    return _request('GET', path);
  }

  Future<dynamic> _request(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$baseUrl$path');

    try {
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await client.get(
            url,
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 15));
          break;

        case 'POST':
          response = await client.post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          ).timeout(const Duration(seconds: 15));
          break;

        case 'PATCH':
          response = await client.patch(
            url,
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 15));
          break;

        default:
          throw UnsupportedError('Méthode HTTP non prise en charge.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Erreur API ${response.statusCode} : ${response.body}',
        );
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception('Le serveur ne répond pas à temps.');
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion : ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Réponse JSON invalide : ${e.message}');
    }
  }
}
