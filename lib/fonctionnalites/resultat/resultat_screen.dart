import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/diagnostic_model.dart';
import '../../core/utils/pin_helper.dart';
import '../../widgets/bottom_nav_bar.dart';

class ResultatScreen extends StatelessWidget {
  final Map<String, dynamic> args;

  const ResultatScreen({super.key, required this.args});

  bool   get _estSain    => args['statut'] == 'sain';
  double get _confiance  => (args['confiance'] as num).toDouble();
  String get _culture    => args['culture']  as String;
  String get _maladie    => args['maladie']  as String;
  String get _conseils   => args['conseils'] as String;

  String get _confianceLabel {
    if (_confiance >= 0.80) return 'ÉLEVÉE';
    if (_confiance >= 0.50) return 'MOYENNE';
    return 'FAIBLE';
  }

  Future<void> _sauvegarder(BuildContext context) async {
    final userId = await PinHelper.getSessionUserId();
    if (userId == null) return;

    final diagnostic = DiagnosticModel(
      userId:    userId,
      culture:   _culture,
      maladie:   _maladie,
      confiance: _confiance,
      statut:    args['statut'],
      conseils:  _conseils,
      date:      DateTime.now().toIso8601String(),
    );

    await DbHelper.instance.insertDiagnostic(diagnostic);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sauvegardé dans l\'historique'),
          backgroundColor: AppTheme.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Carte conseils
                  _buildConseils(),

                  const SizedBox(height: 12),

                  // Alerte si malade
                  if (!_estSain) _buildAlerte(),

                  const SizedBox(height: 16),

                  // Boutons action
                  _buildBoutons(context),

                  const SizedBox(height: 12),

                  // Bouton nouvelle analyse
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, Routes.scanner),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Nouvelle analyse'),
                  ),
                ],
              ),
            ),
          ),

          const BottomNavBar(current: 1),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.green,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flèche retour + titre
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child:
                    const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'Résultat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Badge maladie / sain
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _estSain
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0x40FFC800),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _estSain ? '✓  Plante saine' : '$_maladie (probable)',
              style: TextStyle(
                color: _estSain ? Colors.white : const Color(0xFFFFE066),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Confiance + culture
          Text(
            'Confiance : $_confianceLabel  ·  $_culture',
            style: const TextStyle(
              color: AppTheme.greenPale,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConseils() {
    final lignes = _conseils
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded,
                  color: AppTheme.green, size: 18),
              SizedBox(width: 6),
              Text(
                'À faire maintenant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...lignes.asMap().entries.map((e) {
            final texte =
                e.value.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      texte,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlerte() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFFFC107), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Maladie détectée sur $_culture. Agis rapidement pour protéger le reste de ton champ.',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.warning,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sauvegarder(context),
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Sauvegarder'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: partager via Share plugin
            },
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Partager'),
          ),
        ),
      ],
    );
  }
}