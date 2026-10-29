
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
  });

  final OrganisationPartenaire organisation;
  final int donateurId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      appBar: AppBar(
        title: const Text('Détail de l’organisation'),
        backgroundColor: const Color(0xFF0F7A4B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EnteteOrganisationWidget(
                organisation: organisation,
              ),

              const SizedBox(height: 16),

              AProposOrganisationWidget(
                organisation: organisation,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaireUnDonPage(
                          donateurId: donateurId,
                          organisationPartenaireId: organisation.id,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Aides distribuées',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F7A4B),
                ),
              ),

              const SizedBox(height: 12),

              ListeAidesDistribueesWidget(
                organisationId: organisation.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
