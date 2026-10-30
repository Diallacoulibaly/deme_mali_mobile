import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/styles/couleurs.dart';
import '/controllers/paiement_controller.dart';
import 'don_reussi_page.dart';

class InformationsPaiementPage extends ConsumerStatefulWidget {
  final double montant;
  final bool anonyme;
  final String modePaiement;
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;

  const InformationsPaiementPage({
    super.key,
    required this.montant,
    required this.anonyme,
    required this.modePaiement,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId
  });

  @override
  ConsumerState<InformationsPaiementPage> createState() =>
      _InformationsPaiementPageState();
}

class _InformationsPaiementPageState
    extends ConsumerState<InformationsPaiementPage> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _pinVisible = false;
  bool _chargement = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String get _nomModePaiement {
    switch (widget.modePaiement) {
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'WAVE':
        return 'Wave';
      case 'MOVE_MONEY':
        return 'Moov Money';

      default:
        return widget.modePaiement;
    }
  }

  Future<void> _confirmerPaiement() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    try {
      final paiement = await ref
          .read(paiementDonControllerProvider)
          .effectuerPaiement(
        montant: widget.montant,
        numeroTelephone: _telephoneController.text.trim(),
        codeSecret: _pinController.text.trim(),
        donateurId: widget.donateurId,
        modePaiement: widget.modePaiement,
        anonyme: widget.anonyme,
        demandeAideId: widget.demandeAideId,
          organisationPartenaireId:widget.organisationPartenaireId,
      );

      if (!mounted) return;

      if (paiement.statut == 'CONFIRME') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonReussiPage(
              montant: widget.montant,
              modePaiement: _nomModePaiement,
            ),
          ),
        );
      } else {
        final message = paiement.statut == 'ECHEC'
            ? 'Code PIN incorrect. Veuillez réessayer.'
            : 'Paiement non confirmé : ${paiement.statut}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: CouleursApp.blanc,
              ),
            ),
            backgroundColor: CouleursApp.noir,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du paiement : $e',
            style: const TextStyle(
              color: CouleursApp.blanc,
            ),
          ),
          backgroundColor: CouleursApp.noir,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    IconButton(
                      onPressed: _chargement
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: CouleursApp.blanc,
                        foregroundColor: CouleursApp.noir,
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(40, 40),
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Paiement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 14),

                const Center(
                  child: Text(
                    'Renseignez vos informations de paiement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CouleursApp.noir,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Récapitulatif du don
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CouleursApp.fond,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: CouleursApp.fond,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: CouleursApp.vert,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nomModePaiement,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CouleursApp.noir,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.montant.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                color: CouleursApp.vert,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        color: CouleursApp.vert,
                        size: 19,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Numéro de téléphone
                const Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  style: const TextStyle(
                    color: CouleursApp.noir,
                  ),
                  decoration: _decoration(
                    label: 'Entrez votre numéro',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le numéro de téléphone est obligatoire.';
                    }

                    final chiffres =
                    value.replaceAll(RegExp(r'\D'), '');

                    if (chiffres.length != 8) {
                      return 'Le numéro doit contenir exactement 8 chiffres.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Code PIN
                const Text(
                  'Code PIN ',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: _pinController,
                  obscureText: !_pinVisible,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: CouleursApp.noir,
                  ),
                  decoration: _decoration(
                    label: 'Entrez votre code PIN',
                  ).copyWith(
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _pinVisible = !_pinVisible;
                        });
                      },
                      icon: Icon(
                        _pinVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CouleursApp.vert,
                        size: 19,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le code de test est obligatoire.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 7),

                const Text(
                  'Utilisez uniquement le code prévu pour la simulation '
                      'de paiement de votre application.',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _chargement
                        ? null
                        : _confirmerPaiement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.vert,
                      foregroundColor: CouleursApp.blanc,
                      disabledBackgroundColor: CouleursApp.vert,
                      disabledForegroundColor: CouleursApp.blanc,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _chargement
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: CouleursApp.blanc,
                        strokeWidth: 2,
                      ),
                    )
                        : const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Confirmer le paiement',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Accent jaune de la charte
                Center(
                  child: Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: CouleursApp.jaune,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Style commun des champs
  InputDecoration _decoration({
    required String label,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        color: CouleursApp.noir,
        fontSize: 13,
      ),
      errorStyle: const TextStyle(
        color: CouleursApp.noir,
        fontSize: 11,
      ),
      filled: true,
      fillColor: CouleursApp.blanc,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.fond,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.fond,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.vert,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.noir,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.noir,
          width: 1.5,
        ),
      ),
    );
  }
}