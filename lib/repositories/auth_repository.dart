
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

      // Enregistrer le token et les infos utiles de l'utilisateur
      await stockage.write(
        key: 'accessToken',
        value: resultat.accessToken,
      );
      await stockage.write(
        key: 'userId',
        value: resultat.utilisateur.id.toString(),
      );
      await stockage.write(
        key: 'userPrenom',
        value: resultat.utilisateur.prenom,
      );
      await stockage.write(
        key: 'userNom',
        value: resultat.utilisateur.nom,
      );
      await stockage.write(
        key: 'userTelephone',
        value: resultat.utilisateur.telephone,
      );
      await stockage.write(
        key: 'userRole',
        value: resultat.utilisateur.role,
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

  // Déconnexion : supprimer les données de session
  Future<void> deconnexion() async {
    await stockage.deleteAll();
  }
}
