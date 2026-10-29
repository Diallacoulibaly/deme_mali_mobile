
import 'package:flutter/material.dart';

import '/styles/couleurs.dart';
import 'mode_paiement_page.dart';

class DonFinancierPage extends StatefulWidget {
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;


  const DonFinancierPage({
    super.key,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId

  });

  @override
  State<DonFinancierPage> createState() => _DonFinancierPageState();
}

class _DonFinancierPageState extends State<DonFinancierPage> {
  final TextEditingController _montantController =
  TextEditingController();

  bool _anonyme = false;

  final List<int> _montants = [200, 300, 400, 500, 600, 700];

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _selectionnerMontant(int montant) {
    setState(() {
      _montantController.text = montant.toString();
    });
  }

  void _continuer() {
    final texte = _montantController.text
        .trim()
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    final montant = double.tryParse(texte);

    if (montant == null || !montant.isFinite || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez saisir un montant supérieur à zéro.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModePaiementPage(
          montant: montant,
          anonyme: _anonyme,
          donateurId: widget.donateurId,
          demandeAideId: widget.demandeAideId,
            organisationPartenaireId:widget.organisationPartenaireId

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, contraintes) {
            final largeur = contraintes.maxWidth;
            final petitEcran = contraintes.maxHeight < 700;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                largeur < 360 ? 14 : 20,
                petitEcran ? 6 : 12,
                largeur < 360 ? 14 : 20,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: CouleursApp.blanc,
                          foregroundColor: CouleursApp.noir,
                          side: BorderSide(
                            color: CouleursApp.noir.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Faire un don',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CouleursApp.noir,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  SizedBox(height: petitEcran ? 12 : 20),

                  const Text(
                    'Choisissez ou saisissez un montant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CouleursApp.noir,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: petitEcran ? 18 : 28),

                  // Saisie du montant
                  Container(
                    width: double.infinity,
                    height: petitEcran ? 82 : 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      border: Border.all(
                        color: CouleursApp.vert,
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _montantController,
                      textAlign: TextAlign.center,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: CouleursApp.vert,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0 FCFA',
                        hintStyle: TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  SizedBox(height: petitEcran ? 20 : 30),

                  // Montants proposés
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _montants.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: largeur < 360 ? 8 : 12,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final montant = _montants[index];

                      final selectionne =
                          _montantController.text.trim() ==
                              montant.toString();

                      return OutlinedButton(
                        onPressed: () =>
                            _selectionnerMontant(montant),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectionne
                              ? CouleursApp.vert
                              : CouleursApp.fond,
                          foregroundColor: selectionne
                              ? CouleursApp.blanc
                              : CouleursApp.vert,
                          side: const BorderSide(
                            color: CouleursApp.vert,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$montant F',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: petitEcran ? 12 : 20),

                  // Choix du don anonyme
                  CheckboxListTile(
                    value: _anonyme,
                    onChanged: (value) {
                      setState(() {
                        _anonyme = value ?? false;
                      });
                    },
                    activeColor: CouleursApp.vert,
                    controlAffinity:
                    ListTileControlAffinity.leading,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    title: const Text(
                      'Faire un don anonyme',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Continuer
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _continuer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
