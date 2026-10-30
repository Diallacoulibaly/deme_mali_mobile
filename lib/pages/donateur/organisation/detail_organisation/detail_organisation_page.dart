
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../../models/organisation_partenaire.dart';
import 'widgets/a_propos_organisation_widget.dart';
import 'widgets/entete_organisation_widget.dart';
import 'widgets/liste_aides_distribuees_widget.dart';
import '/pages/donateur/don/faire_un_don_page.dart';

class DetailOrganisationPage extends ConsumerWidget {
  const DetailOrganisationPage({
    super.key,
    required this.organisation,
    required this.donateurId,
    required this.prenom,
  });

  final OrganisationPartenaire organisation;
  final int donateurId;
  final String prenom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),

      // PAS D'APPBAR : PAS DE TITRE NI DE FLÈCHE

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PARTIE FIXE : IDENTITÉ DE L'ORGANISATION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: EnteteOrganisationWidget(
                organisation: organisation,
              ),
            ),

            const SizedBox(height: 16),

            // PARTIE FIXE : À PROPOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AProposOrganisationWidget(
                organisation: organisation,
              ),
            ),

            const SizedBox(height: 20),

            // PARTIE FIXE : TITRE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Aides distribuées',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F7A4B),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SEULE CETTE PARTIE EST DÉFILANTE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListeAidesDistribueesWidget(
                  organisationId: organisation.id,
                ),
              ),
            ),
          ],
        ),
      ),

      // BOUTON FIXE EN BAS
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaireUnDonPage(
                      donateurId: donateurId,
                      organisationPartenaireId: organisation.id,
                      prenom: prenom,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.volunteer_activism),
              label: const Text(
                'Soutenir cette organisation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F7A4B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
