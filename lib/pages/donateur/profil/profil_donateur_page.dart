
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:deme_mali_mobile/models/don_financier.dart';
import 'package:deme_mali_mobile/models/don_materiel.dart';
import 'package:deme_mali_mobile/models/badge_donateur_model.dart';
import 'package:deme_mali_mobile/controllers/badge_controller.dart';
import 'package:deme_mali_mobile/controllers/don_financier_controller.dart';
import 'package:deme_mali_mobile/controllers/don_materiel_controller.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';
class ProfilDonateurPage extends ConsumerWidget {
  final int donateurId;
  final String nomDonateur;

  const ProfilDonateurPage({
    super.key,
    required this.donateurId,
    required this.nomDonateur,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donsFinanciersAsync =
    ref.watch(donsFinanciersDonateurControllerProvider(donateurId));

    final donsMaterielsAsync =
    ref.watch(donsMaterielsParDonateurProvider(donateurId));

    final badgesAsync = ref.watch(badgesActuelsProvider(donateurId));

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.invalidate(
              donsFinanciersDonateurControllerProvider(donateurId),
            );
            ref.invalidate(
              donsMaterielsParDonateurProvider(donateurId),
            );
            ref.invalidate(badgesActuelsProvider(donateurId));

            await Future.wait([
              ref.read(
                donsFinanciersDonateurControllerProvider(donateurId).future,
              ),
              ref.read(
                donsMaterielsParDonateurProvider(donateurId).future,
              ),
              ref.read(badgesActuelsProvider(donateurId).future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const Center(
                child: Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Informations du donateur
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAE8E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 42,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      nomDonateur,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Statistiques des dons financiers
              donsFinanciersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger les dons financiers.',
                ),
                data: (dons) {
                  final total = dons.fold<double>(
                    0,
                        (somme, don) => somme + don.montant,
                  );

                  return _statistiquesFinancieres(
                    nombreDons: dons.length,
                    montantTotal: total,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Badges du semestre actuel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes badges',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.noir,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: CouleursApp.fond,
                        builder: (_) => _HistoriqueBadges(
                          donateurId: donateurId,
                        ),
                      );
                    },
                    child: const Text(
                      'Voir tous',
                      style: TextStyle(
                        color: CouleursApp.vert,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              badgesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger les badges.',
                ),
                data: (badges) {
                  if (badges.isEmpty) {
                    return _carteMessage(
                      'Aucun badge disponible pour le moment.',
                      Icons.workspace_premium_outlined,
                    );
                  }

                  return SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: badges.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _carteBadge(badges[index]);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Activité mensuelle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mon activité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.noir,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EFE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Cette année',
                      style: TextStyle(
                        fontSize: 11,
                        color: CouleursApp.vert,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              donsFinanciersAsync.when(
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger le graphique.',
                ),
                data: (dons) => _graphiqueMensuel(dons),
              ),

              const SizedBox(height: 24),

              // Statistiques des dons matériels
              const Text(
                'Mes dons matériels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 12),

              donsMaterielsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger les dons matériels.',
                ),
                data: (dons) => _statistiquesMaterielles(dons),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statistiquesFinancieres({
    required int nombreDons,
    required double montantTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statistique(
              'Dons effectués',
              '$nombreDons',
              Icons.volunteer_activism_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 55,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _statistique(
              'Total des dons',
              '${_montant(montantTotal)} FCFA',
              Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistique(String titre, String valeur, IconData icone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icone, color: CouleursApp.vert, size: 24),
          const SizedBox(height: 8),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valeur,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteBadge(BadgeDonateurModel badge) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badge.obtenu
              ? CouleursApp.jaune.withValues(alpha: 0.7)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge.imageUrl != null && badge.imageUrl!.isNotEmpty)
            Image.network(
              badge.imageUrl!,
              width: 42,
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.workspace_premium,
                size: 42,
                color: badge.obtenu
                    ? CouleursApp.jaune
                    : Colors.grey,
              ),
            )
          else
            Icon(
              Icons.workspace_premium,
              size: 42,
              color: badge.obtenu
                  ? CouleursApp.jaune
                  : Colors.grey,
            ),
          const SizedBox(height: 8),
          Text(
            badge.nom,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            badge.obtenu ? 'Obtenu' : 'Pas encore obtenu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: badge.obtenu
                  ? CouleursApp.vert
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphiqueMensuel(List<DonFinancier> dons) {
    final maintenant = DateTime.now();
    final montants = List<double>.filled(12, 0);

    for (final don in dons) {
      final date = don.dateDon;

      if (date != null && date.year == maintenant.year) {
        montants[date.month - 1] += don.montant;
      }
    }

    final mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];

    final maximum = montants.fold<double>(
      0,
          (max, valeur) => valeur > max ? valeur : max,
    );

    final maxY = maximum <= 0 ? 100.0 : maximum * 1.2;

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_montant(maximum)} FCFA',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${mois[group.x]}\\n${_montant(rod.toY)} FCFA',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) => Text(
                        _abregerMontant(value),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= 12) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            mois[index],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(12, (index) {
                  final montant = montants[index];
                  final moisActif = index == maintenant.month - 1;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: montant,
                        width: 13,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        color: moisActif
                            ? CouleursApp.vert
                            : CouleursApp.jaune,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistiquesMaterielles(List<DonMateriel> dons) {
    final quantiteRecue = dons.fold<int>(
      0,
          (total, don) => total + don.quantiteRecue,
    );

    final nombreRecus = dons.where((don) {
      return don.statutReception == 'RECU' ||
          don.statutReception == 'PARTIELLEMENT_RECU';
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statistique(
              'Dons matériels',
              '${dons.length}',
              Icons.inventory_2_outlined,
            ),
          ),
          Expanded(
            child: _statistique(
              'Dons réceptionnés',
              '$nombreRecus',
              Icons.check_circle_outline,
            ),
          ),
          Expanded(
            child: _statistique(
              'Quantité reçue',
              '$quantiteRecue',
              Icons.volunteer_activism_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteMessage(String message, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: CouleursApp.vert),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _messageErreur(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  String _montant(double montant) {
    return montant.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );
  }

  String _abregerMontant(double montant) {
    if (montant >= 1000000) {
      return '${(montant / 1000000).toStringAsFixed(1)}M';
    }

    if (montant >= 1000) {
      return '${(montant / 1000).toStringAsFixed(0)}K';
    }

    return montant.toStringAsFixed(0);
  }
}

// Historique des badges du donateur.
class _HistoriqueBadges extends ConsumerWidget {
  final int donateurId;

  const _HistoriqueBadges({
    required this.donateurId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiqueAsync = ref.watch(
      historiqueBadgesProvider(donateurId),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique de mes badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: historiqueAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => const Text(
                  'Impossible de charger l’historique des badges.',
                ),
                data: (badges) {
                  if (badges.isEmpty) {
                    return const Text(
                      'Aucun badge dans votre historique.',
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: badges.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final badge = badges[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.workspace_premium,
                          color: badge.obtenu
                              ? CouleursApp.jaune
                              : Colors.grey,
                          size: 32,
                        ),
                        title: Text(badge.nom),
                        subtitle: Text(
                          [
                            if (badge.semestre != null)
                              badge.semestre!,
                            if (badge.annee != null)
                              '${badge.annee}',
                          ].join(' · '),
                        ),
                        trailing: Icon(
                          badge.obtenu
                              ? Icons.check_circle
                              : Icons.lock_outline,
                          color: badge.obtenu
                              ? CouleursApp.vert
                              : Colors.grey,
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
