
import 'package:flutter/material.dart';

import '../../controllers/connexion_controller.dart';
import '../../styles/couleurs.dart';
import '../beneficiaire/accueil_beneficiaire.dart';
import '../navigation_donateur_page.dart';
import 'widgets/champ_connexion.dart';
import 'widgets/bouton_connexion.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final telephoneController = TextEditingController();
  final motDePasseController = TextEditingController();
  final ConnexionController controller = ConnexionController();

  bool afficherMotDePasse = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_actualiser);
  }

  void _actualiser() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_actualiser);
    controller.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    final succes = await controller.connecter(
      telephone: telephoneController.text.trim(),
      motDePasse: motDePasseController.text,
    );

    if (!mounted) return;

    if (!succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.erreur ?? 'Erreur de connexion.',
          ),
        ),
      );
      return;
    }

    final utilisateur = controller.resultat!.utilisateur;
    final role = utilisateur.role.trim().toUpperCase();

    if (role == 'BENEFICIAIRE' || role == 'BENEFICIARE') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccueilBeneficiairePage(
            prenomBeneficiaire: utilisateur.prenom,
          ),
        ),
        (route) => false,
      );
    } else if (role == 'DONATEUR') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationDonateurPage(
            prenom: utilisateur.prenom,
            donateurId: utilisateur.id,

          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connexion réussie. Rôle : $role. '
                'La page correspondante reste à configurer.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              Center(
                child: Image.asset(
                  'assets/images/logo_acceuil.png',
                  width: 140,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/logo_Acceuil.png',
                    width: 140,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error2, stackTrace2) => Image.asset(
                      'assets/images/logo_accueil.png',
                      width: 140,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Dèmè ',
                        style: TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Mali',
                        style: TextStyle(
                          color: CouleursApp.jaune,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Connectez-vous à votre compte Dèmè Mali.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 25),

              ChampConnexion(
                titre: 'Téléphone',
                indication: 'Entrez votre numéro de téléphone',
                controller: telephoneController,
                typeClavier: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              ChampConnexion(
                titre: 'Mot de passe',
                indication: 'Entrez votre mot de passe',
                controller: motDePasseController,
                motDePasse: true,
                afficherMotDePasse: afficherMotDePasse,
                changerVisibilite: () {
                  setState(() {
                    afficherMotDePasse = !afficherMotDePasse;
                  });
                },
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La récupération du mot de passe sera ajoutée ensuite.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      fontSize: 11,
                      color: CouleursApp.vert,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              BoutonConnexion(
                chargement: controller.chargement,
                onPressed: _connecter,
              ),

              const SizedBox(height: 20),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      'Vous n’avez pas encore de compte ? ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'S’inscrire',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.vert,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
