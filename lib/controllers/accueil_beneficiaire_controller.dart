
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/demande_aide.dart';
import '../repositories/demande_aide_repository.dart';

final demandeAideRepositoryProvider = Provider<DemandeAideRepository>(
  (ref) => DemandeAideRepository(),
);

final mesDemandesBeneficiaireProvider = FutureProvider<List<DemandeAide>>(
  (ref) => ref.watch(demandeAideRepositoryProvider).chargerMesDemandes(),
);
