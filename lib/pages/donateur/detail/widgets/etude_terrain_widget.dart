import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../controllers/etude_terrain_controller.dart';
import '../../../../models/demande_aide.dart';
import '../../../../styles/couleurs.dart';

class EtudeTerrainWidget extends ConsumerWidget {
  final DemandeAide demande;
  const EtudeTerrainWidget({super.key, required this.demande});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync = ref.watch(etudeTerrainControllerProvider(demande.id));
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(15)),
      child: etudeAsync.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: CouleursApp.vert))),
        error: (erreur, _) => const Text('Impossible de charger les informations de l’étude de terrain.'),
        data: (etude) {
          if (etude == null) return const Text('Aucune étude de terrain n’est encore associée à cette demande.', style: TextStyle(color: CouleursApp.noir));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Étude de terrain', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CouleursApp.noir)),
            const SizedBox(height: 14),
            _ligne(Icons.flag_outlined, 'Objectif', etude.objectif),
            _ligne(Icons.place_outlined, 'Lieu', etude.lieu),
            _ligne(Icons.calendar_month_outlined, 'Date planifiée', _date(etude.datePlanification)),
            _ligne(Icons.event_available_outlined, 'Date de réalisation', _date(etude.dateRealisation)),
            _ligne(Icons.access_time, 'Heure', etude.heure),
            _ligne(Icons.info_outline, 'Statut', etude.statut),
            _ligne(Icons.visibility_outlined, 'Observations', etude.observation),
            _ligne(Icons.check_circle_outline, 'Résultat', etude.resultat),
          ]);
        },
      ),
    );
  }

  Widget _ligne(IconData icone, String titre, String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icone, color: CouleursApp.vert, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titre, style: TextStyle(fontSize: 12, color: CouleursApp.noir.withValues(alpha: 0.65))),
        const SizedBox(height: 3),
        Text(valeur, style: const TextStyle(fontSize: 14, height: 1.4, color: CouleursApp.noir)),
      ])),
    ]));
  }

  String? _date(DateTime? date) => date == null ? null : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
