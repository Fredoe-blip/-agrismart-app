import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/pin_helper.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/routes.dart';
import 'fonctionnalites/auth/inscription_screen.dart';
import 'fonctionnalites/auth/pin_create_screen.dart';
import 'fonctionnalites/auth/login_screen.dart';
import 'fonctionnalites/welcome/welcome_screen.dart';
import 'fonctionnalites/scanner/scanner_screen.dart';
import 'fonctionnalites/resultat/resultat_screen.dart';
import 'fonctionnalites/historique/historique_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forcer l'orientation portrait (téléphone agriculteur)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Couleur de la barre de statut Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AgriSmartApp());
}

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        Routes.inscription: (_) => const InscriptionScreen(),
        Routes.pinCreate:   (_) => const PinCreateScreen(),
        Routes.login:       (_) => const LoginScreen(),
        Routes.welcome:     (_) => const WelcomeScreen(),
        Routes.scanner:     (_) => const ScannerScreen(),
        Routes.historique:  (_) => const HistoriqueScreen(),
      },
      onGenerateRoute: (settings) {
        // Résultat reçoit des arguments → route dynamique
        if (settings.name == Routes.resultat) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ResultatScreen(args: args),
          );
        }
        return null;
      },
    );
  }
}

// ── Splash screen ─────────────────────────────────────────────────────────────
// Affiche le logo + bouton pour aller à la connexion/inscription
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;
  bool _dejaConnecte = false;

  @override
  void initState() {
    super.initState();
    _verifierSession();
  }

  Future<void> _verifierSession() async {
    final loggedIn = await PinHelper.isLoggedIn();
    if (mounted) {
      setState(() {
        _dejaConnecte = loggedIn;
        _loading = false;
      });
    }
  }

  void _continuer() {
    Navigator.pushReplacementNamed(
      context,
      _dejaConnecte ? Routes.welcome : Routes.inscription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image de fond plein écran ──────────────────
          Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1B5E20),
            ),
          ),

          // ── Overlay sombre pour lisibilité ─────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                 const Color(0xFF1B5E20).withOpacity(0.65),
                const Color(0xFF0A2E0A).withOpacity(0.85),
                ],
              ),
            ),
          ),

          // ── Contenu par-dessus ─────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Espace haut — le logo de la maquette
                // est l'image de fond elle-même
                const Spacer(flex: 7),

                // Titre + sous-titre centré
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'AgriSmart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Diagnostic intelligent des plantes\nde maïs et de manioc',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Bouton Commencer ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : GestureDetector(
                          onTap: _continuer,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Commencer',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),

                SizedBox(height: size.height * 0.06),
              ],
            ),
          ),
        ],
      ),
    );
  }
}