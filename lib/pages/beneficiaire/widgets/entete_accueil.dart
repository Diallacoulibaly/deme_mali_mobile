import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class EnteteAccueil extends StatelessWidget {
  const EnteteAccueil({super.key, this.onNotificationTap});
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 44, height: 44,
      decoration: BoxDecoration(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(14)),
      child: const Icon(Icons.volunteer_activism, color: CouleursApp.vert, size: 27)),
    const SizedBox(width: 10),
    const Expanded(child: Text.rich(TextSpan(children: [
      TextSpan(text: 'Dèmè ', style: TextStyle(color: CouleursApp.vert, fontSize: 21, fontWeight: FontWeight.w800)),
      TextSpan(text: 'Mali', style: TextStyle(color: CouleursApp.jaune, fontSize: 21, fontWeight: FontWeight.w800)),
    ]))),
    Material(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(14),
      child: InkWell(onTap: onNotificationTap, borderRadius: BorderRadius.circular(14),
        child: const SizedBox(width: 44, height: 44,
          child: Icon(Icons.notifications_none, color: CouleursApp.vert)))),
  ]);
}
