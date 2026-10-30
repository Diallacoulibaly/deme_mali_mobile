import 'package:flutter/material.dart';
import '../../../../models/demande_aide.dart';
import '../../../../styles/couleurs.dart';
import '../../../../controllers/etude_terrain_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoriqueDemandeWidget extends ConsumerWidget {
  final DemandeAide demande;
  const HistoriqueDemandeWidget({super.key, required this.demande});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync = ref.watch(etudeTerrainControllerProvider(demande.id));
    return _carte(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Historique de la demande', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CouleursApp.noir)),
      const SizedBox(height: 18),
      _etape(Icons.check_circle_outline, '1. Demande d’aide', 'Créée le ${_date(demande.dateCreation)}'),
      etudeAsync.when(
        data: (etude) => _etape(Icons.location_on_outlined, '2. Étude de terrain', etude == null ? 'Aucune étude de terrain enregistrée.' : 'Statut : ${etude.statut ?? 'Non précisé'} • ${_date(etude.dateRealisation ?? etude.datePlanification)}'),
        loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator(color: CouleursApp.vert)),
        error: (_, __) => _etape(Icons.location_on_outlined, '2. Étude de terrain', 'Les informations de l’étude ne sont pas disponibles.'),
      ),
      _etape(Icons.article_outlined, '3. Rapport de besoin', 'Besoin identifié et solution proposée.'),
      _etape(Icons.assignment_outlined, '4. Rapport technique', 'Articles, quantités, prix et montant final estimé.', dernier: true),
    ]));
  }

  Widget _etape(IconData icone, String titre, String description, {bool dernier = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icone, color: CouleursApp.vert, size: 23),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CouleursApp.noir)),
        const SizedBox(height: 5),
        Text(description, style: TextStyle(fontSize: 13, height: 1.4, color: CouleursApp.noir.withValues(alpha: 0.7))),
      ])),
    ]),
  );

  Widget _carte({required Widget child}) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(15)), child: child);
  String _date(DateTime? date) => date == null ? 'Date non précisée' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
