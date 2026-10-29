
import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';

class EnteteDonateur extends StatelessWidget {
  final String prenom;
  const EnteteDonateur({super.key,required this.prenom,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CouleursApp.fond,
      padding: const EdgeInsets.fromLTRB(22, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo, nom de l'application et notifications.
          Row(
            children: [
              Image.asset(
                'assets/images/logo_acceuil.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: CouleursApp.vert,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              const Text(
                'Dèmè',
                style: TextStyle(
                  color: CouleursApp.vert,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Mali',
                style: TextStyle(
                  color: CouleursApp.jaune,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              // Bouton de notification.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CouleursApp.noir.withValues(alpha: 0.06),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Ajouter ici la navigation vers les notifications.
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: CouleursApp.noir,
                        size: 23,
                      ),
                    ),
                    Positioned(
                      right: 9,
                      top: 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Message de bienvenue.
          Text(
            'Bonjour ${prenom.trim()} ',
            style: const TextStyle(
              color: CouleursApp.noir,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),

          Text(
            'Merci de contribuer à une solidarité plus forte au Mali.',
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.65),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
