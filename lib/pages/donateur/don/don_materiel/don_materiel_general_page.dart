import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/controllers/don_materiel_controller.dart';
import '/models/don_materiel.dart';
import '/styles/couleurs.dart';

class DonMaterielGeneralPage extends ConsumerStatefulWidget {
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;


  const DonMaterielGeneralPage({
    super.key,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId
  });

  @override
  ConsumerState<DonMaterielGeneralPage> createState() =>
      _DonMaterielGeneralPageState();
}

class _DonMaterielGeneralPageState
    extends ConsumerState<DonMaterielGeneralPage> {
  final _formKey = GlobalKey<FormState>();
  final _designationController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _adresseController = TextEditingController();

  String _unite = 'Sac';
  String _etatMateriel = 'NEUF';
  bool _anonyme = false;
  bool _chargement = false;

  final List<String> _unites = [
    'Sac',
    'Kilogramme',
    'Carton',
    'Bidon',
    'Pièce',
    'Litre',
    'Paquet',
    'Autre',
  ];

  final Map<String, String> _etats = {
    'NEUF': 'Neuf',
    'BON_ETAT': 'Bon état',
    'MAUVAIS_ETAT': 'Mauvais état',
  };

  @override
  void dispose() {
    _designationController.dispose();
    _quantiteController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _envoyerDon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true);

    try {
      final controller = ref.read(creationDonMaterielProvider);

      final DonMateriel don = await controller.creer(
        designation: _designationController.text.trim(),
        quantite: int.parse(_quantiteController.text.trim()),
        unite: _unite,
        etatMateriel: _etatMateriel,
        anonyme: _anonyme,
        donateurId: widget.donateurId,
        demandeAideId: widget.demandeAideId,
        adresseLivraison: _adresseController.text.trim(),
        organisationPartenaireId: widget.organisationPartenaireId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Don enregistré avec succès. Référence : ${don.id}',
          ),
          backgroundColor: CouleursApp.vert,
        ),
      );

      _formKey.currentState!.reset();
      _designationController.clear();
      _quantiteController.clear();
      _adresseController.clear();

      setState(() {
        _unite = 'Sac';
        _etatMateriel = 'NEUF';
        _anonyme = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’enregistrer le don : $e'),
          backgroundColor: CouleursApp.noir,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _chargement = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: AppBar(
        backgroundColor: CouleursApp.fond,
        foregroundColor: CouleursApp.vert,
        elevation: 0,
        title: const Text(
          'Don matériel général',
          style: TextStyle(
            color: CouleursApp.noir,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CouleursApp.vert,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.volunteer_activism_outlined,
                        color: CouleursApp.jaune,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Votre don peut faire la différence',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proposez du matériel pour soutenir les '
                            'personnes qui en ont besoin.',
                        style: TextStyle(
                          color: CouleursApp.blanc.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Informations sur le matériel',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _label('Désignation du matériel'),
                TextFormField(
                  controller: _designationController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration(
                    'Ex. : Mil, riz, huile...',
                    Icons.inventory_2_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le matériel à donner.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _label('Quantité'),
                TextFormField(
                  controller: _quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration(
                    'Ex. : 10',
                    Icons.numbers,
                  ),
                  validator: (value) {
                    final quantite = int.tryParse(value?.trim() ?? '');

                    if (quantite == null || quantite <= 0) {
                      return 'Saisissez une quantité entière supérieure à 0.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _label('Unité de mesure'),
                DropdownButtonFormField<String>(
                  initialValue: _unite,
                  isExpanded: true,
                  dropdownColor: CouleursApp.blanc,
                  decoration: _decoration(
                    'Choisir une unité',
                    Icons.straighten,
                  ),
                  items: _unites.map((unite) {
                    return DropdownMenuItem<String>(
                      value: unite,
                      child: Text(
                        unite,
                        style: const TextStyle(
                          color: CouleursApp.noir,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _unite = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                _label('État du matériel'),
                DropdownButtonFormField<String>(
                  initialValue: _etatMateriel,
                  isExpanded: true,
                  dropdownColor: CouleursApp.blanc,
                  decoration: _decoration(
                    'Choisir un état',
                    Icons.check_circle_outline,
                  ),
                  items: _etats.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: CouleursApp.noir,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _etatMateriel = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                _label('Adresse de livraison'),
                TextFormField(
                  controller: _adresseController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: _decoration(
                    'Entrez votre adresse',
                    Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    value: _anonyme,
                    activeTrackColor: CouleursApp.vert,
                    title: const Text(
                      'Faire un don anonyme',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Votre identité ne sera pas affichée publiquement.',
                      style: TextStyle(
                        color: CouleursApp.noir,
                      ),
                    ),
                    secondary: const Icon(
                      Icons.visibility_off_outlined,
                      color: CouleursApp.vert,
                    ),
                    onChanged: (value) {
                      setState(() => _anonyme = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _chargement ? null : _envoyerDon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.vert,
                      foregroundColor: CouleursApp.blanc,
                      disabledBackgroundColor: CouleursApp.vert,
                      disabledForegroundColor: CouleursApp.blanc,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _chargement
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CouleursApp.blanc,
                      ),
                    )
                        : const Icon(Icons.volunteer_activism),
                    label: Text(
                      _chargement
                          ? 'Enregistrement...'
                          : 'Confirmer mon don',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Aucun prix ne vous sera demandé.',
                    style: TextStyle(
                      color: CouleursApp.noir,
                      fontSize: 13,
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

  Widget _label(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texte,
        style: const TextStyle(
          color: CouleursApp.noir,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icone) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: CouleursApp.noir.withValues(alpha: 0.55),
      ),
      prefixIcon: Icon(
        icone,
        color: CouleursApp.vert,
      ),
      filled: true,
      fillColor: CouleursApp.blanc,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CouleursApp.noir.withValues(alpha: 0.12),
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
          color: CouleursApp.jaune,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.jaune,
          width: 1.5,
        ),
      ),
    );
  }
}