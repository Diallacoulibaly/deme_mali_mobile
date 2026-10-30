
import 'package:flutter/material.dart';

class FiltresUrgence extends StatelessWidget {
  final List<String> niveaux;
  final String selection;
  final ValueChanged<String> onSelectionChanged;

  const FiltresUrgence({
    super.key,
    required this.niveaux,
    required this.selection,
    required this.onSelectionChanged,
  });

  static const vert = Color(0xFF0F7A4B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: niveaux.map((niveau) {
          final actif =
              niveau.toLowerCase() == selection.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Material(
              color: actif ? vert : Colors.white,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                onTap: () => onSelectionChanged(niveau),
                borderRadius: BorderRadius.circular(25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Center(
                    child: Text(
                      niveau,
                      style: TextStyle(
                        color: actif
                            ? Colors.white
                            : const Color(0xFF1F1F1F),
                        fontSize: 12,
                        fontWeight: actif
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
