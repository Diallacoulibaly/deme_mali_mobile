
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:deme_mali_mobile/controllers/preuve_distribution_controoller.dart';
import '/../../../models/aide_distribuee.dart';
import '/../../../styles/couleurs.dart';
import 'preuve_distribution_widget.dart';

class PreuvesDistributionWidget extends ConsumerWidget {
  const PreuvesDistributionWidget({
    super.key,
    required this.aide,
  });

  final AideDistribuee aide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preuvesAsync = ref.watch(
      preuvesParDistributionProvider(aide.id),
    );

    return preuvesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: CouleursApp.vert,
          ),
        ),
      ),
      error: (error, stackTrace) => Text(
        'Impossible de charger les preuves de cette distribution.',
        style: TextStyle(
          color: CouleursApp.noir.withValues(alpha: 0.65),
        ),
      ),
      data: (preuves) {
        if (preuves.isEmpty) {
          return Text(
            'Aucune preuve disponible pour cette distribution.',
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.65),
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: preuves.map((preuve) {
            return SizedBox(
              width: 135,
              child: PreuveDistributionWidget(
                preuve: preuve,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
