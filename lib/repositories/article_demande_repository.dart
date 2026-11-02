
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/article_demande.dart';
import 'auth_repository.dart';

class ArticleDemandeRepository {
  static const String baseUrl = '${AuthRepository.baseUrl}/api';

  // Récupérer les articles initiaux d'une demande.
  Future<List<ArticleDemande>> getArticles(int demandeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/articles-demande/demande/$demandeId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les articles (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('La réponse doit être une liste JSON.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => ArticleDemande.fromJson(json))
        .toList();
  }
}

// Provider du repository des articles.
final articleDemandeRepositoryProvider =
Provider<ArticleDemandeRepository>((ref) {
  return ArticleDemandeRepository();
});

// Provider pour charger les articles d'une demande précise.
final articlesDemandeProvider =
FutureProvider.family<List<ArticleDemande>, int>((ref, demandeId) {
  return ref
      .watch(articleDemandeRepositoryProvider)
      .getArticles(demandeId);
});
