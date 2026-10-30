import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../models/notification_item.dart';
import '../../../styles/couleurs.dart';
import '../detail/detail_aide_page.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String filtreActif = 'Toutes';

  static const List<String> filtres = ['Toutes', 'Dons reçus', 'Demandes'];

  List<NotificationItem> _filtrer(List<NotificationItem> liste) {
    if (filtreActif == 'Dons reçus') {
      return liste.where((n) => n.type == TypeNotification.donRecu).toList();
    }
    if (filtreActif == 'Demandes') {
      return liste
          .where(
            (n) =>
                n.type == TypeNotification.demandeValidee ||
                n.type == TypeNotification.demandeRefusee ||
                n.type == TypeNotification.objectifAtteint,
          )
          .toList();
    }
    return liste;
  }

  void _ouvrirDemande(NotificationItem notif, List<DemandeAide> demandes) {
    ref.read(notificationsNotifierProvider.notifier).marquerCommeLue(notif.id);

    if (notif.demandeId == null) return;

    final correspondance = demandes.where((d) => d.id == notif.demandeId).firstOrNull;
    if (correspondance != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailAidePage(demande: correspondance),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final mesDemandes = ref.watch(mesDemandesBeneficiaireProvider).value ?? [];
    final notificationsFiltrees = _filtrer(state.notifications);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            // 1. En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 19,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  if (state.aDesNonLues)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(notificationsNotifierProvider.notifier)
                            .toutMarquerCommeLu();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: CouleursApp.vert,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Tout lire',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 2. Onglets de filtrage rapide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filtres.map((f) {
                  final actif = filtreActif == f;
                  int? compte;
                  if (f == 'Toutes') compte = state.notifications.length;
                  if (f == 'Dons reçus') {
                    compte = state.notifications
                        .where((n) => n.type == TypeNotification.donRecu)
                        .length;
                  }
                  if (f == 'Demandes') {
                    compte = state.notifications
                        .where(
                          (n) =>
                              n.type == TypeNotification.demandeValidee ||
                              n.type == TypeNotification.demandeRefusee ||
                              n.type == TypeNotification.objectifAtteint,
                        )
                        .length;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => filtreActif = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: actif ? CouleursApp.vert : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: actif
                                ? CouleursApp.vert
                                : const Color(0xFFE5DECF),
                          ),
                          boxShadow: actif
                              ? [
                                  BoxShadow(
                                    color: CouleursApp.vert.withValues(alpha: 0.22),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          compte != null && compte > 0
                              ? '$f ($compte)'
                              : f,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                actif ? FontWeight.w700 : FontWeight.w600,
                            color: actif ? Colors.white : const Color(0xFF555555),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Liste des notifications
            Expanded(
              child: RefreshIndicator(
                color: CouleursApp.vert,
                onRefresh: () async {
                  await ref
                      .read(notificationsNotifierProvider.notifier)
                      .charger();
                },
                child: state.chargement && state.notifications.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: CouleursApp.vert,
                        ),
                      )
                    : notificationsFiltrees.isEmpty
                        ? _vueVide()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: notificationsFiltrees.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notif = notificationsFiltrees[index];
                              return _carteNotification(
                                notif: notif,
                                onTap: () => _ouvrirDemande(notif, mesDemandes),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vueVide() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CouleursApp.vert.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: CouleursApp.vert,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les notifications concernant vos dons reçus, la validation '
              'de vos demandes et les distributions s’afficheront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteNotification({
    required NotificationItem notif,
    required VoidCallback onTap,
  }) {
    final estNonLue = !notif.lu;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: estNonLue ? const Color(0xFFFAFDF9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estNonLue
                ? CouleursApp.vert.withValues(alpha: 0.35)
                : const Color(0xFFEDE6D8),
            width: estNonLue ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pastille d'icône colorée
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: notif.couleur.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.icone,
                color: notif.couleur,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),

            // Contenu textuel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.titre,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: estNonLue
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: CouleursApp.noir,
                          ),
                        ),
                      ),
                      if (estNonLue)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CouleursApp.vert,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Nouveau',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: const TextStyle(
                      fontSize: 11.8,
                      height: 1.35,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.dateFormatee,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF999999),
                        ),
                      ),
                      if (notif.demandeId != null)
                        const Row(
                          children: [
                            Text(
                              'Voir la demande',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: CouleursApp.vert,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: CouleursApp.vert,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
