import '../models/demande_aide.dart';

/// Données temporaires de démonstration, pas des données du backend.
class DemandeAideRepository {
  Future<List<DemandeAide>> chargerMesDemandes() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      DemandeAide(id: 1, titre: 'Aide alimentaire',
        descriptionSituation: 'Besoin de produits alimentaires pour la famille.',
        niveauUrgence: 'FORTE', statut: 'EN_ATTENTE',
        categorieDemandeNom: 'Alimentation', typeDemandeAide: 'MATERIELLE'),
      DemandeAide(id: 2, titre: 'Soutien scolaire',
        descriptionSituation: 'Fournitures scolaires pour les enfants.',
        niveauUrgence: 'NORMALE', statut: 'VALIDEE',
        categorieDemandeNom: 'Éducation', typeDemandeAide: 'MATERIELLE'),
    ];
  }
}
