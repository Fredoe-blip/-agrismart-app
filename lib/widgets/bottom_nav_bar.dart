// lib/widgets/bottom_nav_bar.dart
//
// Barre de navigation partagée entre Welcome, Scanner, Historique.
// current : 0 = Accueil, 1 = Scanner, 2 = Historique

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/navigation/routes.dart';

class BottomNavBar extends StatelessWidget {
  final int current;

  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined,      Icons.home_rounded,       'Accueil',    Routes.welcome),
      (Icons.camera_alt_outlined, Icons.camera_alt_rounded, 'Scanner',   Routes.scanner),
      (Icons.history_outlined,   Icons.history_rounded,    'Historique', Routes.historique),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 62, 124, 62),
        border: Border(
          top: BorderSide(color: const Color.fromARGB(255, 252, 249, 249), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: items.asMap().entries.map((e) {
            final index  = e.key;
            final item   = e.value;
            final active = index == current;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (active) return;
                  Navigator.pushReplacementNamed(context, item.$4);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$2 : item.$1,
                        size: 24,
                    color: active ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? Colors.white : Colors.white.withOpacity(0.5),
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}