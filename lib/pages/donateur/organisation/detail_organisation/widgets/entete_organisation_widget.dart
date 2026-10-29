
import 'package:flutter/material.dart';

import '/../../../models/organisation_partenaire.dart';
import '/../../../styles/couleurs.dart';

class EnteteOrganisationWidget extends StatelessWidget {
  const EnteteOrganisationWidget({
    super.key,
    required this.organisation,
  });

  final OrganisationPartenaire organisation;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 30,
                  color: CouleursApp.vert,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organisation.nomOrganisation,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.noir,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      organisation.typeOrganisation,
                      style: TextStyle(
                        color: CouleursApp.noir.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 19,
                color: CouleursApp.vert,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  organisation.ville,
                  style: const TextStyle(color: CouleursApp.noir),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 19,
                color: CouleursApp.jaune,
              ),
              const SizedBox(width: 6),
              Text(
                '${organisation.nombreLikes} j’aime',
                style: const TextStyle(
                  color: CouleursApp.noir,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
