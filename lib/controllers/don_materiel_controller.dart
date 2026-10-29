
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/don_materiel.dart';
import '../repositories/don_materiel_repository.dart';

// 1. Consultation des dons matériels par demande
final donMaterielControllerProvider =
FutureProvider.family<List<DonMateriel>, int>(
      (ref, demandeAideId) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getDonsParDemande(demandeAideId);
  },
);

// 2. Consultation des dons matériels par donateur
final donsMaterielsParDonateurProvider =
FutureProvider.family<List<DonMateriel>, int>(
      (ref, donateurId) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getByDonateur(donateurId);
  },
);

// 3. Provider pour créer un don matériel général
final creationDonMaterielProvider =
Provider<CreationDonMaterielController>((ref) {
  final repository =
  ref.watch(donMaterielRepositoryProvider);

  return CreationDonMaterielController(repository);
});

// 4. Contrôleur de création
class CreationDonMaterielController {
  final DonMaterielRepository repository;

  CreationDonMaterielController(this.repository);

  Future<DonMateriel> creer({
    required String designation,
    required int quantite,
    required String unite,
    required String etatMateriel,
    required bool anonyme,
    required int donateurId,
    int? demandeAideId,
    int? organisationPartenaireId,
    required String adresseLivraison,
  }) {
    return repository.creerDonMateriel(
      designation: designation,
      quantite: quantite,
      unite: unite,
      etatMateriel: etatMateriel,
      anonyme: anonyme,
      donateurId: donateurId,
      adresseLivraison: adresseLivraison,
      demandeAideId: demandeAideId,
      organisationPartenaireId: organisationPartenaireId,
    );
  }
}

// 5. Paramètres pour la statistique par période
class PeriodeDonMateriel {
  final int donateurId;
  final DateTime debut;
  final DateTime fin;

  const PeriodeDonMateriel({
    required this.donateurId,
    required this.debut,
    required this.fin,
  });
}

// 6. Statistique : valeur du matériel réellement reçu
// par un donateur pendant une période
final valeurMaterielleRecueControllerProvider =
FutureProvider.family<double, PeriodeDonMateriel>(
      (ref, periode) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getValeurMaterielleRecue(
      donateurId: periode.donateurId,
      debut: periode.debut,
      fin: periode.fin,
    );
  },
);
