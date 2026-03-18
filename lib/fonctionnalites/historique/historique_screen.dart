import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/diagnostic_model.dart';
import '../../core/utils/pin_helper.dart';
import '../../widgets/bottom_nav_bar.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  List<DiagnosticModel> _diagnostics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final userId = await PinHelper.getSessionUserId();
    if (userId == null) return;

    final liste = await DbHelper.instance.getDiagnosticsUser(userId);

    if (mounted) {
      setState(() {
        _diagnostics = liste;
        _loading     = false;
      });
    }
  }

  Future<void> _supprimer(DiagnosticModel d) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text(
            'Supprimer l\'analyse du ${d.dateFormatee} (${d.culture}) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirme == true && d.id != null) {
      await DbHelper.instance.deleteDiagnostic(d.id!);
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContenu(context)),
          const BottomNavBar(current: 2),
        ],
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
  return Container(
    color: AppTheme.green,
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 52, 20, 18),
    child: Row(
      children: [
        // Logo
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco_rounded,
                color: AppTheme.green,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _loading
                  ? 'Chargement...'
                  : '${_diagnostics.length} analyse${_diagnostics.length > 1 ? 's' : ''} enregistrée${_diagnostics.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppTheme.greenPale,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildContenu(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.green),
      );
    }

    if (_diagnostics.isEmpty) {
      return _buildVide(context);
    }

    return RefreshIndicator(
      color: AppTheme.green,
      onRefresh: _charger,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _diagnostics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _DiagnosticItem(
          diagnostic: _diagnostics[i],
          onTap: () => Navigator.pushNamed(
            context,
            Routes.resultat,
            arguments: _diagnostics[i].toArgs(),
          ),
          onSupprimer: () => _supprimer(_diagnostics[i]),
        ),
      ),
    );
  }

 Widget _buildVide(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.greenLight,
          ),
          child: const Icon(
            Icons.history_rounded,
            size: 56,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Aucune analyse pour l\'instant',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tes diagnostics apparaîtront ici\naprès ton premier scan',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Bouton arrondi style fond vert
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.scanner),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Scanner une feuille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

class _DiagnosticItem extends StatelessWidget {
  final DiagnosticModel diagnostic;
  final VoidCallback    onTap;
  final VoidCallback    onSupprimer;

  const _DiagnosticItem({
    required this.diagnostic,
    required this.onTap,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final d = diagnostic;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Row(
          children: [
            // Icône culture
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: d.estSain
                    ? AppTheme.successBg
                    : AppTheme.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  d.culture == 'Maïs' ? '🌽' : '🌿',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${d.culture}  —  ${d.maladie}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${d.dateFormatee}  ·  Confiance ${d.confianceLabel}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Badge statut
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: d.estSain
                    ? AppTheme.successBg
                    : AppTheme.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                d.estSain ? 'Sain' : 'Malade',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: d.estSain
                      ? AppTheme.success
                      : AppTheme.warning,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Bouton supprimer
            GestureDetector(
              onTap: onSupprimer,
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}