import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/accueil_beneficiaire_controller.dart';
import '../../styles/couleurs.dart';
import 'widgets/aides_recues.dart';
import 'widgets/bienvenue_beneficiaire.dart';
import 'widgets/bouton_demande_aide.dart';
import 'widgets/cartes_actions.dart';
import 'widgets/entete_accueil.dart';
import 'widgets/liste_demandes.dart';
import 'widgets/suivi_aides.dart';

class AccueilBeneficiairePage extends ConsumerWidget {
  const AccueilBeneficiairePage({super.key, this.prenomBeneficiaire = '',
    this.onDemanderAide, this.onMesDemandes, this.onSuiviAides, this.onAidesRecues});
  final String prenomBeneficiaire;
  final VoidCallback? onDemanderAide, onMesDemandes, onSuiviAides, onAidesRecues;

  void _message(BuildContext context, String texte) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandesAsync = ref.watch(mesDemandesBeneficiaireProvider);
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: EnteteAccueil(onNotificationTap: () => _message(context, 'Les notifications seront ajoutées plus tard.'))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: BienvenueBeneficiaire(prenom: prenomBeneficiaire)),
        Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: BoutonDemandeAide(onPressed: onDemanderAide ??
            () => _message(context, 'La page de création de demande sera ajoutée ensuite.'))),
        const Padding(padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Text('Que souhaitez-vous faire ?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: CouleursApp.noir))),
        const SizedBox(height: 12),
        Expanded(child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.invalidate(mesDemandesBeneficiaireProvider);
            await ref.read(mesDemandesBeneficiaireProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CartesActions(
                onDemander: onDemanderAide ?? () => _message(context, 'La page de création de demande sera ajoutée ensuite.'),
                onMesDemandes: onMesDemandes ?? () => _message(context, 'La page Mes demandes sera ajoutée ensuite.'),
                onSuivi: onSuiviAides ?? () => _message(context, 'La page de suivi sera ajoutée ensuite.'),
                onAidesRecues: onAidesRecues ?? () => _message(context, 'La page Mes aides reçues sera ajoutée ensuite.'),
              ),
              const SizedBox(height: 24),
              const ListeDemandes(),
              const SizedBox(height: 24),
              demandesAsync.when(
                data: (demandes) => SuiviAides(demandes: demandes),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: CouleursApp.vert))),
                error: (_, __) => const Text('Le suivi sera disponible lorsque les demandes pourront être chargées.'),
              ),
              const SizedBox(height: 24),
              const AidesRecues(),
            ]),
          ),
        )),
      ])),
      // CurvedNavigationBar ajoutée dans une étape séparée.
    );
  }
}
