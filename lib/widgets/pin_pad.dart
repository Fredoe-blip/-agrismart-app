// lib/widgets/pin_pad.dart
//
// Clavier numérique PIN réutilisable.
// Utilisé par pin_create_screen.dart et login_screen.dart.

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PinPad extends StatefulWidget {
  /// Appelé quand les 4 chiffres sont saisis
  final void Function(String pin) onComplete;

  /// Message d'erreur à afficher sous les cases (null = rien)
  final String? errorMessage;

  const PinPad({super.key, required this.onComplete, this.errorMessage});

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  final List<int> _digits = [];

  void _onKey(int chiffre) {
    if (_digits.length >= 4) return;
    setState(() => _digits.add(chiffre));

    if (_digits.length == 4) {
      // Légère pause pour que l'animation soit visible
      Future.delayed(const Duration(milliseconds: 150), () {
        widget.onComplete(_digits.join());
      });
    }
  }

  void _onSupprimer() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Indicateurs 4 cases ───────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final rempli = i < _digits.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 52,
              height: 58,
              decoration: BoxDecoration(
                color: rempli ? AppTheme.greenLight : Colors.white,
                border: Border.all(
                  color: rempli ? AppTheme.green : Colors.grey.shade300,
                  width: rempli ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  rempli ? '●' : '○',
                  style: TextStyle(
                    fontSize: 20,
                    color: rempli ? AppTheme.green : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }),
        ),

        // ── Message d'erreur ──────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: widget.errorMessage != null
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.error,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 12),
        ),

        const SizedBox(height: 20),

        // ── Clavier numérique ─────────────────────────────
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Chiffres 1 à 9
            ...List.generate(
              9,
              (i) => _Touche(label: '${i + 1}', onTap: () => _onKey(i + 1)),
            ),
            // Vide | 0 | Supprimer
            const SizedBox.shrink(),
            _Touche(label: '0', onTap: () => _onKey(0)),
            _Touche(label: '⌫', onTap: _onSupprimer, fontSize: 22),
          ],
        ),
      ],
    );
  }
}

// ── Touche individuelle ──────────────────────────────────────────────────────
class _Touche extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _Touche({required this.label, required this.onTap, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF222222),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
