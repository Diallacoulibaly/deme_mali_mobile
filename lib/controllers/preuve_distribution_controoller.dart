
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preuve_distribution.dart';
import '../repositories/preuve_distribution_repository.dart';

final preuveDistributionRepositoryProvider =
Provider<PreuveDistributionRepository>((ref) {
  const baseUrl = 'http://localhost:8080';

  final repository = PreuveDistributionRepository(
    baseUrl: baseUrl,
  );

  ref.onDispose(repository.dispose);

  return repository;
});

final preuvesParDistributionProvider =
FutureProvider.family<List<PreuveDistribution>, int>(
      (ref, aideDistribueeId) {
    final repository = ref.watch(
      preuveDistributionRepositoryProvider,
    );

    return repository.getByDistribution(aideDistribueeId);
  },
);
