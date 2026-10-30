import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/demande_aide.dart';
import '../../../controllers/don_controller.dart';
import '../../../controllers/images_demande_controller.dart';
import '../../../styles/couleurs.dart';
import 'widgets/historique_demande_widget.dart';
import 'widgets/etude_terrain_widget.dart';
import 'widgets/rapports_demande_widget.dart';

class DetailDemandePage extends ConsumerStatefulWidget {
  final DemandeAide demande;
  final VoidCallback? onFaireDon;

  const DetailDemandePage({
    super.key,
    required this.demande,
    this.onFaireDon,
  });

  @override
  ConsumerState<DetailDemandePage> createState() =>
      _DetailDemandePageState();
}

class _DetailDemandePageState extends ConsumerState<DetailDemandePage> {
  int rubriqueSelectionnee = 0;

  @override
  Widget build(BuildContext context) {
    final demande = widget.demande;

    final imagesAsync =
    ref.watch(imageDemandeControllerProvider(demande.id));

    final donateursAsync =
    ref.watch(nombreDonateursProvider(demande.id));

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: AppBar(
        title: const Text('Détail de la demande'),
        backgroundColor: CouleursApp.fond,
        foregroundColor: CouleursApp.noir,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CouleursApp.blanc,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: imagesAsync.when(
                      data: (images) {
                        if (images.isNotEmpty &&
                            images.first.cheminFichier.isNotEmpty) {
                          return Image.network(
                            images.first.cheminFichier,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imageParDefaut(),
                          );
                        }

                        return _imageParDefaut();
                      },
                      loading: _imageParDefaut,
                      error: (_, __) => _imageParDefaut(),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  demande.titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  demande.descriptionSituation.isNotEmpty
                      ? demande.descriptionSituation
                      : 'Aucune description disponible.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: CouleursApp.noir.withValues(alpha: 0.75),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _information(
                        'Montant nécessaire',
                        _formaterMontant(
                          demande.montantNecessaire ?? 0,
                        ),
                        Icons.flag_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _information(
                        'Montant collecté',
                        _formaterMontant(
                          demande.montantCollecte ?? 0,
                        ),
                        Icons.volunteer_activism_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                donateursAsync.when(
                  data: (nombre) => _information(
                    'Donateurs',
                    '$nombre personne(s)',
                    Icons.people_outline,
                  ),
                  loading: () => const LinearProgressIndicator(
                    color: CouleursApp.vert,
                  ),
                  error: (_, __) => _information(
                    'Donateurs',
                    '${demande.nombreDonateurs} personne(s)',
                    Icons.people_outline,
                  ),
                ),

                // Le parcours du don est fourni par la page appelante.
                if (widget.onFaireDon != null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onFaireDon,
                      icon: const Icon(Icons.favorite_outline),
                      label: const Text('Faire un don'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _boutonRubrique('Historique', 0),
              const SizedBox(width: 5),
              _boutonRubrique('Rapports', 1),
              const SizedBox(width: 5),
              _boutonRubrique('Étude terrain', 2),
            ],
          ),

          const SizedBox(height: 12),

          if (rubriqueSelectionnee == 0)
            HistoriqueDemandeWidget(demande: demande),

          if (rubriqueSelectionnee == 1)
            RapportsDemandeWidget(demande: demande),

          if (rubriqueSelectionnee == 2)
            EtudeTerrainWidget(demande: demande),
        ],
      ),
    );
  }

  Widget _boutonRubrique(String titre, int index) {
    final selectionne = rubriqueSelectionnee == index;

    return Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              rubriqueSelectionnee = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            selectionne ? CouleursApp.vert : CouleursApp.blanc,
            foregroundColor:
            selectionne ? CouleursApp.blanc : CouleursApp.noir,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageParDefaut() {
    return Container(
      color: CouleursApp.fond,
      alignment: Alignment.center,
      child: const Icon(
        Icons.volunteer_activism_outlined,
        color: CouleursApp.vert,
        size: 48,
      ),
    );
  }

  Widget _information(
      String titre,
      String valeur,
      IconData icone,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            color: CouleursApp.vert,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontSize: 11,
                    color: CouleursApp.noir.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formaterMontant(num montant) {
    final texte = montant.round().toString();

    return '${texte.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    )} FCFA';
  }
}