import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/demande_aide_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../models/categorie_demande.dart';

import '../widgets/carte_demande_don.dart';
import 'widgets/entete_liste_demandes.dart';
import '../detail/detail_demande_page.dart';
import '../don/faire_un_don_page.dart';
import '../don/don_financier/don_financier_page.dart';

class ListeDemandesDon extends ConsumerStatefulWidget {
  final int donateurId;
  final int? organisationPartenaireId;
  final String prenom;

  const ListeDemandesDon({
    super.key,
    required this.donateurId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  ConsumerState<ListeDemandesDon> createState() =>
      _ListeDemandesDonState();
}

class _ListeDemandesDonState extends ConsumerState<ListeDemandesDon> {
  String texteRecherche = '';
  String urgenceSelectionnee = 'Toutes';
  int? categorieSelectionneeId;

  // Filtrage des demandes
  List<DemandeAide> filtrerDemandes(
      List<DemandeAide> demandes, {
        required String urgence,
        required int? categorieId,
      }) {
    final recherche = texteRecherche.trim().toLowerCase();
    final urgenceFiltre = urgence.trim().toLowerCase();

    return demandes.where((demande) {
      final correspondTitre =
      demande.titre.toLowerCase().contains(recherche);

      final urgenceDemande =
      demande.niveauUrgence.trim().toLowerCase();

      final correspondUrgence =
          urgenceFiltre == 'toutes' ||
              urgenceDemande == urgenceFiltre;

      final correspondCategorie =
          categorieId == null ||
              demande.categorieDemandeId == categorieId;

      return correspondTitre &&
          correspondUrgence &&
          correspondCategorie;
    }).toList();
  }

  // Navigation vers le formulaire de don selon le type de demande
  void _ouvrirChoixDon(DemandeAide demande) {
    if (demande.estFinanciere) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonFinancierPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId:
            widget.organisationPartenaireId,
          ),
        ),
      );
    } else if (demande.estMaterielle) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaireUnDonPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId:
            widget.organisationPartenaireId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le type de cette demande est inconnu.'),
        ),
      );
    }
  }

  // Navigation vers le détail de la demande
  void _ouvrirDetail(DemandeAide demande) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailDemandePage(
          demande: demande,
          donateurId: widget.donateurId,
          prenom: widget.prenom,
          organisationPartenaireId:
          widget.organisationPartenaireId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final demandesAsync = ref.watch(demandeAideControllerProvider);

    // Récupération des demandes déjà chargées.
    // Pendant le premier chargement, cette liste est simplement vide.
    final demandes = demandesAsync.asData?.value ?? <DemandeAide>[];

    // Récupération des niveaux d'urgence disponibles
    final urgencesDisponibles = demandes
        .map((demande) => demande.niveauUrgence.trim())
        .where((urgence) => urgence.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final niveauxUrgence = <String>[
      'Toutes',
      ...urgencesDisponibles.where(
            (urgence) => urgence.toLowerCase() != 'toutes',
      ),
    ];

    // Récupération des catégories présentes dans les demandes
    final categoriesParId = <int, CategorieDemande>{};

    for (final demande in demandes) {
      final id = demande.categorieDemandeId;
      final nom = demande.categorieDemandeNom?.trim();

      if (id != null && nom != null && nom.isNotEmpty) {
        categoriesParId.putIfAbsent(
          id,
              () => CategorieDemande(
            id: id,
            nom: nom,
          ),
        );
      }
    }

    final categories = categoriesParId.values.toList()
      ..sort(
            (a, b) => a.nom
            .toLowerCase()
            .compareTo(b.nom.toLowerCase()),
      );

    // Vérification de la catégorie sélectionnée
    final categorieActive =
    categorieSelectionneeId != null &&
        categoriesParId.containsKey(categorieSelectionneeId)
        ? categorieSelectionneeId
        : null;

    // Vérification du niveau d'urgence sélectionné
    final urgenceActive = niveauxUrgence.firstWhere(
          (niveau) =>
      niveau.trim().toLowerCase() ==
          urgenceSelectionnee.trim().toLowerCase(),
      orElse: () => 'Toutes',
    );

    final nomsCategories = <String>[
      'Toutes',
      ...categories.map((categorie) => categorie.nom),
    ];

    final nomCategorieActive = categorieActive == null
        ? 'Toutes'
        : categoriesParId[categorieActive]?.nom ?? 'Toutes';

    // Résultats filtrés
    final resultats = filtrerDemandes(
      demandes,
      urgence: urgenceActive,
      categorieId: categorieActive,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      body: SafeArea(
        child: Column(
          children: [
            // EN-TÊTE TOUJOURS VISIBLE
            EnteteListeDemandes(
              niveauxUrgence: niveauxUrgence,
              urgenceSelectionnee: urgenceActive,
              onUrgenceChanged: (valeur) {
                setState(() {
                  urgenceSelectionnee = valeur;
                });
              },
              categories: nomsCategories,
              categorieSelectionnee: nomCategorieActive,
              onCategorieChanged: (nom) {
                setState(() {
                  if (nom == 'Toutes') {
                    categorieSelectionneeId = null;
                  } else {
                    final correspondances = categories.where(
                          (categorie) => categorie.nom == nom,
                    );

                    categorieSelectionneeId =
                    correspondances.isEmpty
                        ? null
                        : correspondances.first.id;
                  }
                });
              },
              onRechercheChanged: (valeur) {
                setState(() {
                  texteRecherche = valeur;
                });
              },
              nombreDemandes: resultats.length,
            ),

            // SEULE LA ZONE DES RÉSULTATS CHANGE SELON L'ÉTAT
            Expanded(
              child: demandesAsync.when(
                // Premier chargement : l'en-tête reste visible
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0F7A4B),
                  ),
                ),

                // Erreur de chargement
                error: (error, stackTrace) {
                  debugPrint(
                    'Erreur chargement demandes : $error',
                  );

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFF0F7A4B),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Impossible de charger les demandes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(
                                demandeAideControllerProvider,
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F7A4B),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },

                // Demandes chargées
                data: (demandesChargees) {
                  final resultatsCharges = filtrerDemandes(
                    demandesChargees,
                    urgence: urgenceActive,
                    categorieId: categorieActive,
                  );

                  debugPrint(
                    'Nombre de demandes : ${demandesChargees.length}',
                  );

                  // Aucun résultat
                  if (resultatsCharges.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFF0F7A4B),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Aucune demande trouvée',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Essayez de modifier votre recherche '
                                  'ou vos filtres.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Liste des demandes
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    itemCount: resultatsCharges.length,
                    itemBuilder: (context, index) {
                      final demande = resultatsCharges[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CarteDemandeDon(
                          demande: demande,

                          // Bouton Faire un don
                          onFaireDon: () {
                            _ouvrirChoixDon(demande);
                          },

                          // Bouton Voir le détail
                          onVoirDetail: () {
                            _ouvrirDetail(demande);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}