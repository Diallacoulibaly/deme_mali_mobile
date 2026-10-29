
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demande_aide.dart';
import '../repositories/demande_aide_donateur_repository.dart';

final demandeAideControllerProvider =
AsyncNotifierProvider<DemandeAideController, List<DemandeAide>>(
  DemandeAideController.new,
);

class DemandeAideController extends AsyncNotifier<List<DemandeAide>> {
  @override
  Future<List<DemandeAide>> build() async {
    return _chargerDemandes();
  }

  Future<List<DemandeAide>> _chargerDemandes() async {
    final repository = ref.read(demandeAideRepositoryProvider);
    final demandes = await repository.getDemandesDisponibles();

    return demandes
        .where((demande) => demande.statut == 'VALIDEE')
        .toList();
  }

  Future<void> actualiser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_chargerDemandes);
  }
}

/// Récupérer une demande d'aide précise par son identifiant.
final demandeAideDetailProvider =
FutureProvider.family<DemandeAide, int>((ref, id) async {
  final repository = ref.watch(demandeAideRepositoryProvider);
  return repository.getDemandeById(id);
});
