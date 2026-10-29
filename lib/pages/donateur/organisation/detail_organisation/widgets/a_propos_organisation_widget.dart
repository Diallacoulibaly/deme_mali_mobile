
import 'package:flutter/material.dart';

import '/../../../models/organisation_partenaire.dart';
import '/../../../styles/couleurs.dart';

class AProposOrganisationWidget extends StatelessWidget {
  const AProposOrganisationWidget({
    super.key,
    required this.organisation,
  });

  final OrganisationPartenaire organisation;

  @override
  Widget build(BuildContext context) {
    final informations = <MapEntry<String, String>>[
      MapEntry('Ville', organisation.ville),
      if ((organisation.adresse ?? '').trim().isNotEmpty)
        MapEntry('Adresse', organisation.adresse!.trim()),
      if ((organisation.email ?? '').trim().isNotEmpty)
        MapEntry('E-mail', organisation.email!.trim()),
      if ((organisation.telephoneOrganisation ?? '').trim().isNotEmpty)
        MapEntry(
          'Téléphone',
          organisation.telephoneOrganisation!.trim(),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À propos de l’organisation',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informations disponibles sur cette organisation partenaire.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: CouleursApp.noir.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          ...informations.map(
                (information) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      information.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      information.value,
                      style: TextStyle(
                        color: CouleursApp.noir.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
