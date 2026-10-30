import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';
import '../don/faire_un_don_page.dart';

class BanniereDonGeneral extends StatelessWidget {
  final int donateurId;

  const BanniereDonGeneral({
    super.key,
    required this.donateurId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaireUnDonPage(
                  donateurId: donateurId,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: CouleursApp.vert,
            foregroundColor: CouleursApp.blanc,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              vertical: 17,
              horizontal: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Faire un don',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}