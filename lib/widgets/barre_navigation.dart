
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

class BarreNavigation extends StatelessWidget {
  final int indexSelectionne;
  final ValueChanged<int> onTap;

  const BarreNavigation({
    super.key,
    required this.indexSelectionne,
    required this.onTap,
  });

  static const Color vert = Color(0xFF0F7A4B);
  static const Color blanc = Colors.white;
  static const Color beige = Color(0xFFF7F3EA);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: indexSelectionne,
      height: 65,
      color: vert,
      buttonBackgroundColor: blanc,
      backgroundColor: beige,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),

      items: const [
        CurvedNavigationBarItem(
          child: Icon(
            Icons.home_rounded,
            color: vert,
          ),
          label: 'Accueil',
          labelStyle: TextStyle(
            color: vert,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            Icons.account_balance_outlined,
            color: blanc,
          ),
          label: 'Organisations',
          labelStyle: TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            Icons.handshake_outlined,
            color: blanc,
          ),
          label: 'Mes dons',
          labelStyle: TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            Icons.person_rounded,
            color: blanc,
          ),
          label: 'Profil',
          labelStyle: TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
      ],

      onTap: onTap,
    );
  }
}
