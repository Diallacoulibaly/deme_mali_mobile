
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controllers/etude_terrain_controller.dart';
import '../../../../controllers/rapport_besoin_controller.dart';
import '../../../../controllers/rapport_technique_controller.dart';
import '../../../../models/demande_aide.dart';
import '../../../../models/rapport_besoin.dart';
import '../../../../models/rapport_technique.dart';
import '../../../../styles/couleurs.dart';

class RapportsDemandeWidget extends ConsumerWidget {
  final DemandeAide demande;

  const RapportsDemandeWidget({
    super.key,
    required this.demande,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync =
    ref.watch(etudeTerrainControllerProvider(demande.id));
    final techniqueAsync =
    ref.watch(rapportTechniqueProvider(demande.id));

    return Column(
      children: [
        etudeAsync.when(
          loading: () => _carte(
            const Center(
              child: CircularProgressIndicator(
                color: CouleursApp.vert,
              ),
            ),
          ),
          error: (_, _) => _carte(
            const Text('Impossible de charger le rapport de besoin.'),
          ),
          data: (etude) {
            if (etude == null) {
              return _carte(
                const Text(
                  'Le rapport de besoin sera affiché lorsqu’une étude '
                      'de terrain sera disponible.',
                ),
              );
            }

            final besoinAsync =
            ref.watch(rapportBesoinControllerProvider(etude.id));

            return besoinAsync.when(
              loading: () => _carte(
                const Center(
                  child: CircularProgressIndicator(
                    color: CouleursApp.vert,
                  ),
                ),
              ),
              error: (_, _) => _carte(
                const Text('Impossible de charger le rapport de besoin.'),
              ),
              data: (rapport) => _rapportBesoin(rapport),
            );
          },
        ),
        const SizedBox(height: 12),
        techniqueAsync.when(
          loading: () => _carte(
            const Center(
              child: CircularProgressIndicator(
                color: CouleursApp.vert,
              ),
            ),
          ),
          error: (_, _) => _carte(
            const Text('Impossible de charger le rapport technique.'),
          ),
          data: (rapport) => _rapportTechnique(rapport),
        ),
      ],
    );
  }

  Widget _rapportBesoin(RapportBesoin? rapport) {
    if (rapport == null) {
      return _carte(
        const Text('Aucun rapport de besoin disponible pour le moment.'),
      );
    }

    return _carte(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapport de besoin',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 12),
          _ligne('Titre', rapport.titre),
          _ligne('Besoin identifié', rapport.besoinIdentifie),
          _ligne(
            'Description de la situation',
            rapport.descriptionSituation,
          ),
          _ligne('Solution proposée', rapport.solutionProposee),
          _ligne(
            'Montant estimé',
            rapport.montantEstime == null
                ? null
                : _montant(rapport.montantEstime!),
          ),
          _ligne(
            'Date de création',
            rapport.dateCreation == null
                ? null
                : _date(rapport.dateCreation!),
          ),
        ],
      ),
    );
  }

  Widget _rapportTechnique(RapportTechnique? rapport) {
    if (rapport == null) {
      return _carte(
        const Text('Aucun rapport technique disponible pour le moment.'),
      );
    }

    return _carte(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapport technique',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Montant final estimé : ${_montant(rapport.montantFinal)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(height: 12),
          if (rapport.details.isEmpty)
            const Text('Aucun article détaillé dans ce rapport.')
          else ...[
            const Text(
              'Détail des besoins',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 8),
            ...rapport.details.map(
                  (detail) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CouleursApp.fond,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.designation,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.noir,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantité : ${detail.quantite} ${detail.unite}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CouleursApp.noir,
                      ),
                    ),
                    Text(
                      'Prix unitaire : ${_montant(detail.prixUnitaire)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CouleursApp.noir,
                      ),
                    ),
                    Text(
                      'Montant : ${_montant((detail.montant ?? (detail.quantite * (detail.prixUnitaire ?? 0))).toDouble())}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.vert,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _carte(Widget enfant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(15),
      ),
      child: enfant,
    );
  }

  Widget _ligne(String titre, String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: TextStyle(
              fontSize: 12,
              color: CouleursApp.noir.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: CouleursApp.noir,
            ),
          ),
        ],
      ),
    );
  }

  String _montant(num valeur) {
    final texte = valeur.round().toString();

    return '${texte.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    )} FCFA';
  }

  String _date(DateTime valeur) {
    return '${valeur.day.toString().padLeft(2, '0')}/'
        '${valeur.month.toString().padLeft(2, '0')}/'
        '${valeur.year}';
  }
}
