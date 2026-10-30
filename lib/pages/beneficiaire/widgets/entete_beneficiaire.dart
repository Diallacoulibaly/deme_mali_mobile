import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';

// En-tête avec logo à gauche et cloche de notification à droite
class EnteteBeneficiaire extends StatelessWidget {
  const EnteteBeneficiaire({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo Dèmè Mali + Nom
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_acceuil.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/logo_Acceuil.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error2, stackTrace2) => Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: CouleursApp.vert.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: CouleursApp.vert,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Dèmè Mali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: CouleursApp.noir,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Bouton cloche notification avec badge
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: CouleursApp.blanc,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: CouleursApp.noir,
                  size: 24,
                ),
                Positioned(
                  top: 12,
                  right: 13,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: CouleursApp.jaune,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
