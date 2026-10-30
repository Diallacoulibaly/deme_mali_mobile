
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article_demande.dart';
import '../repositories/article_demande_repository.dart';

// Provider du repository des articles.
// Le repository reste responsable des appels HTTP.
final articleDemandeRepositoryProvider =
Provider<ArticleDemandeRepository>((ref) {
  return ArticleDemandeRepository();
});

// Contrôleur pour charger les articles d'une demande précise.
final articleDemandeControllerProvider =
FutureProvider.family<List<ArticleDemande>, int>(
      (ref, demandeId) {
    final repository =
    ref.watch(articleDemandeRepositoryProvider);

    return repository.getArticles(demandeId);
  },
);
