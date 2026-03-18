import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/api_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = [];
  static const int _totalPhotos = 3;
  bool _analyse = false;
  String? _erreur;

  // ── Prendre une photo avec la caméra 
  Future<void> _prendrePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;
      setState(() {
        _photos.add(File(picked.path));
        _erreur = null;
      });
      if (_photos.length == _totalPhotos) await _analyser();
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'accéder à la caméra.');
    }
  }

  // ── Choisir depuis la galerie ──────────────────────────
  Future<void> _choisirGalerie() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;
      setState(() {
        _photos.add(File(picked.path));
        _erreur = null;
      });
      if (_photos.length == _totalPhotos) await _analyser();
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'accéder à la galerie.');
    }
  }

  void _reprendrePhoto() {
    if (_photos.isNotEmpty) {
      setState(() {
        _photos.removeLast();
        _erreur = null;
      });
    }
  }

  Future<void> _analyser() async {
    if (_photos.isEmpty) return;
    setState(() {
      _analyse = true;
      _erreur  = null;
    });
    try {
      final result = await ApiService.instance.analyserImage(_photos.first);
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.resultat, arguments: {
        'culture':     result.culture,
        'maladie':     result.maladie,
        'maladieEn':   result.maladieEn,
        'confiance':   result.confiance,
        'statut':      result.statut,
        'conseils':    result.conseils,
        'description': result.description,
      });
    } on ApiException catch (e) {
      setState(() {
        _analyse = false;
        _erreur  = e.message;
      });
    } catch (e) {
      setState(() {
        _analyse = false;
        _erreur  = 'Une erreur est survenue. Réessaie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Feuilles décoratives en fond (coins)
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.eco_rounded,
                  size: 180, color: AppTheme.green),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.eco_rounded,
                  size: 140, color: AppTheme.green),
            ),
          ),

          // Contenu principal
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _analyse
                    ? _buildChargement()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            _buildProgression(),
                            const SizedBox(height: 10),
                            _buildInstruction(),
                            const SizedBox(height: 14),
                            _buildZoneCamera(),
                            const SizedBox(height: 14),
                            if (_erreur != null) _buildErreur(),
                            _buildBoutons(),
                            const SizedBox(height: 16),
                            _buildConseils(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
              ),
              const BottomNavBar(current: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.green,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 14),
      child: Row(
        children: [
         Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/icon.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.green,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Scanner une feuille',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progression ──────────────────────────────────────────────────────────────
  Widget _buildProgression() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _photos.length / _totalPhotos,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.green,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_totalPhotos, (i) {
            final fait = i < _photos.length;
            final actuel = i == _photos.length;
            return Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fait
                        ? AppTheme.green
                        : actuel
                            ? Colors.white
                            : Colors.transparent,
                    border: Border.all(
                      color: fait || actuel
                          ? AppTheme.green
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: fait
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  'Photo ${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: fait || actuel
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: fait || actuel
                        ? AppTheme.green
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // ── Instruction ──────────────────────────────────────────────────────────────
  Widget _buildInstruction() {
    final String texte;
    if (_photos.isEmpty) {
      texte = 'Place la feuille au centre et prends une photo';
    } else if (_photos.length < _totalPhotos) {
      texte =
          'Photo ${_photos.length}/$_totalPhotos prise ✓  — Continue pour plus de précision';
    } else {
      texte = '3 photos prises — Analyse en cours...';
    }

    return Text(
      texte,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      textAlign: TextAlign.center,
    );
  }

  // ── Zone caméra ──────────────────────────────────────────────────────────────
  Widget _buildZoneCamera() {
    return GestureDetector(
      onTap: _prendrePhoto,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1A4A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Grille verte
              CustomPaint(painter: _GridPainter()),

              // Aperçu photo ou placeholder
              if (_photos.isNotEmpty)
                Image.file(_photos.last, fit: BoxFit.cover)
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Appuie pour prendre une photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Utilise la lumière naturelle',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

              // Coins du cadre de visée
              if (_photos.isEmpty) ...[
                Positioned(top: 16, left: 16,
                    child: _coin(topLeft: true)),
                Positioned(top: 16, right: 16,
                    child: _coin(topRight: true)),
                Positioned(bottom: 16, left: 16,
                    child: _coin(bottomLeft: true)),
                Positioned(bottom: 16, right: 16,
                    child: _coin(bottomRight: true)),
              ],

              // Badge nombre de photos si photo prise
              if (_photos.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_photos.length}/$_totalPhotos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Coin du cadre de visée
  Widget _coin({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerPainter(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  // ── Erreur ───────────────────────────────────────────────────────────────────
  Widget _buildErreur() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_erreur!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12)),
          ),
          GestureDetector(
            onTap: () => setState(() => _erreur = null),
            child: const Icon(Icons.close, color: AppTheme.error, size: 16),
          ),
        ],
      ),
    );
  }

  // ── Boutons ──────────────────────────────────────────────────────────────────
  Widget _buildBoutons() {
    return Column(
      children: [
        // Bouton principal — Prendre photo (grand, vert)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _prendrePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 20),
            label: Text(
              _photos.isEmpty
                  ? 'Prendre photo'
                  : 'Photo ${_photos.length + 1}/$_totalPhotos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Boutons secondaires — Galerie + Reprendre + Analyser
        Row(
          children: [
            // Galerie
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _choisirGalerie,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Galerie',
                    style: TextStyle(fontSize: 13)),
              ),
            ),

            if (_photos.isNotEmpty) ...[
              const SizedBox(width: 8),

              // Reprendre
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reprendrePhoto,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reprendre',
                      style: TextStyle(fontSize: 13)),
                ),
              ),

              const SizedBox(width: 8),

              // Analyser maintenant
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _analyser,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.greenLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_fix_high_rounded,
                      size: 16, color: AppTheme.green),
                  label: const Text('Analyser',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.green)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Chargement ───────────────────────────────────────────────────────────────
  Widget _buildChargement() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.green),
          SizedBox(height: 20),
          Text(
            'Analyse en cours...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le modèle examine ta photo',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Conseils ─────────────────────────────────────────────────────────────────
  Widget _buildConseils() {
    final conseils = [
      ('Utilise la lumière naturelle du soleil'),
      ('La feuille doit être entièrement visible'),
      ('Évite les reflets et les ombres'),
      ('Tiens le téléphone à 20 cm de la feuille'),
      ('3 photos = analyse plus précise'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              const Text(
                'Pour une meilleure analyse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...conseils.map((texte) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('•',
          style: TextStyle(
              color: AppTheme.green,
              fontSize: 16,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          texte,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF444444),
            height: 1.4,
          ),
        ),
      ),
    ],
  ),
)),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Ligne horizontale verte au centre
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const _CornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    if (topLeft) {
      canvas.drawLine(Offset(0, h), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}