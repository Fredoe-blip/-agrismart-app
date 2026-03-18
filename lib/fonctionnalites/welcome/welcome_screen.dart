import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/utils/pin_helper.dart';
import '../../widgets/bottom_nav_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _prenom = '';
  final PageController _pageController = PageController();
  int _pageActuelle = 0;
  Timer? _timer;

  //Tes 3 photos dans assets/images/

  final List<String> _photos = [
    'assets/images/slide1.png',
    'assets/images/slide2.jpeg',
    'assets/images/slide3.jpg',
  ];

  final List<String> _labels = [
    'Prends une photo de la feuille',
    'L\'IA analyse en quelques secondes',
    'Reçois le diagnostic et les conseils',
  ];

  @override
  void initState() {
    super.initState();
    _chargerPrenom();
    _demarrerCarrousel();
  }

  Future<void> _chargerPrenom() async {
    final p = await PinHelper.getSessionPrenom();
    if (mounted && p != null) setState(() => _prenom = p);
  }

  void _demarrerCarrousel() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_pageActuelle + 1) % _photos.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _deconnecter() async {
    await PinHelper.clearSession();
    if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // INTACT — bannière verte
                  _buildBanniere(),

                  // NOUVEAU — carrousel de photos
                  _buildCarrousel(),

                  // INTACT — actions + cultures
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Que veux-tu faire ?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 1. Scanner
                        _ActionCard(
                          icon: Icons.camera_alt_rounded,
                          titre: 'Scanner une feuille',
                          description:
                              'Prends une photo pour détecter les maladies',
                          couleur: AppTheme.green,
                          texteCouleur: Colors.white,
                          iconBg: Colors.white.withOpacity(0.18),
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.scanner),
                        ),
                        const SizedBox(height: 12),

                        // 2. Écouter en audio
                        _ActionCard(
                          icon: Icons.volume_up_rounded,
                          titre: 'Écouter en audio',
                          description: 'Écoute les instructions à voix haute',
                          couleur: Colors.white,
                          texteCouleur: const Color(0xFF222222),
                          iconBg: AppTheme.greenLight,
                          bordure: true,
                          onTap: () {
                            // TODO: flutter_tts
                          },
                        ),
                        const SizedBox(height: 12),

                        // 3. Mes analyses
                        _ActionCard(
                          icon: Icons.history_rounded,
                          titre: 'Mes analyses',
                          description:
                              'Consulter l\'historique de tes scans',
                          couleur: Colors.white,
                          texteCouleur: const Color(0xFF222222),
                          iconBg: AppTheme.greenLight,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.historique),
                          bordure: true,
                        ),
                        const SizedBox(height: 24),

                        // 4. Cultures — en dernier
                        _buildCulturesChips(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavBar(current: 0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.green,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 16, 16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prenom.isNotEmpty
                      ? 'Bonjour, $_prenom '
                      : 'Bonjour ! ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Diagnostic intelligent des plantes',
                  style: TextStyle(
                    color: AppTheme.greenPale,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          TextButton.icon(
            onPressed: _deconnecter,
            icon: const Icon(Icons.logout_rounded,
                color: Colors.white70, size: 18),
            label: const Text(
              'Déconnexion',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanniere() {
    return Container(
      width: double.infinity,
      color: AppTheme.green,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF1F4F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Scanne une feuille',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Détecte les maladies sur\nmaïs et manioc',
                          style: TextStyle(
                            color: AppTheme.greenPale,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.scanner),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Commencer →',
                              style: TextStyle(
                                color: AppTheme.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      'assets/icons/agrismart_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_rounded,
                        color: Colors.white24,
                        size: 80,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCarrousel() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Comment ça marche',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Photos qui défilent
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _photos.length,
              onPageChanged: (i) => setState(() => _pageActuelle = i),
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Photo réelle
                        Image.asset(
                          _photos[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F4F1F),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  [
                                    Icons.camera_alt_outlined,
                                    Icons.auto_fix_high_outlined,
                                    Icons.check_circle_outline,
                                  ][i],
                                  color: Colors.white38,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ajoute slide${i + 1}.jpg\ndans assets/images/',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Overlay gradient bas
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Text(
                              _labels[i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Indicateurs 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_photos.length, (i) {
              final actif = i == _pageActuelle;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: actif ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: actif ? AppTheme.green : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturesChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cultures analysées',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: ['Maïs', 'Manioc'].map((nom) {
            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.green.withOpacity(0.3)),
              ),
              child: Text(
                nom,
                style: const TextStyle(
                  color: AppTheme.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData     icon;
  final String       titre;
  final String       description;
  final Color        couleur;
  final Color        texteCouleur;
  final Color        iconBg;
  final VoidCallback onTap;
  final bool         bordure;

  const _ActionCard({
    required this.icon,
    required this.titre,
    required this.description,
    required this.couleur,
    required this.texteCouleur,
    required this.iconBg,
    required this.onTap,
    this.bordure = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(14),
          border: bordure
              ? Border.all(color: Colors.grey.shade200, width: 0.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: texteCouleur, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: texteCouleur,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: texteCouleur.withOpacity(
                          texteCouleur == Colors.white ? 0.75 : 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: texteCouleur.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}