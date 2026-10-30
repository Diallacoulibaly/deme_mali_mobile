
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../../../controllers/aide_distribuee_controller.dart';
import '/../../../styles/couleurs.dart';
import 'carte_aide_distribuee_widget.dart';

class ListeAidesDistribueesWidget extends ConsumerWidget {
  const ListeAidesDistribueesWidget({
    super.key,
    required this.organisationId,
  });

  final int organisationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aidesAsync = ref.watch(
      aidesDistribueesParOrganisationProvider(organisationId),
    );

    return aidesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: CouleursApp.vert,
          ),
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Impossible de charger les aides distribuées. '
              'Vérifie le serveur et l’URL de l’API.',
          style: TextStyle(
            color: Colors.red.shade800,
            height: 1.4,
          ),
        ),
      ),
      data: (aides) {
        if (aides.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CouleursApp.blanc,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  size: 38,
                  color: CouleursApp.vert,
                ),
                SizedBox(height: 8),
                Text(
                  'Aucune aide distribuée pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CouleursApp.noir),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final aide in aides) ...[
              CarteAideDistribueeWidget(aide: aide),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
