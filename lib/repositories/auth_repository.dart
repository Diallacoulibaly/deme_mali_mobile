
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/reponse_connexion.dart';

class AuthRepository {
  // Adresse du backend Spring Boot pour Flutter Web
  static const String baseUrl = 'http://localhost:8080';

  // Stockage sécurisé du token
  final FlutterSecureStorage stockage = const FlutterSecureStorage();

  // Connexion de l'utilisateur
  Future<ReponseConnexion> connexion({
    required String telephone,
    required String motDePasse,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final reponse = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'telephone': telephone.trim(),
        'motDePasse': motDePasse,
      }),
    );

    if (reponse.statusCode == 200) {
      final donnees =
      jsonDecode(reponse.body) as Map<String, dynamic>;

      final resultat = ReponseConnexion.fromJson(donnees);

      // Enregistrer le token reçu du backend
      await stockage.write(
        key: 'accessToken',
        value: resultat.accessToken,
      );

      return resultat;
    }

    throw Exception(
      'Erreur HTTP ${reponse.statusCode} : ${reponse.body}',
    );
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
