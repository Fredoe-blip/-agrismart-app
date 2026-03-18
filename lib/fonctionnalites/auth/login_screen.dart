// lib/fonctionnalites/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/database/db_helper.dart';
import '../../core/utils/pin_helper.dart';
import '../../widgets/pin_pad.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _telCtrl = TextEditingController();
  String? _erreur;
  bool    _loading = false;

  Future<void> _onPinSaisi(String pin) async {
    final tel = _telCtrl.text.trim();

    if (tel.isEmpty || tel.length < 8) {
      setState(() => _erreur = 'Entre ton numéro d\'abord');
      return;
    }

    setState(() {
      _loading = true;
      _erreur  = null;
    });

    final telephone = '+228$tel';

    // Chercher l'utilisateur
    final user = await DbHelper.instance.getUserByTelephone(telephone);

    if (user == null) {
      setState(() {
        _loading = false;
        _erreur  = 'Numéro non trouvé. Crée un compte.';
      });
      return;
    }

    // Vérifier le PIN
    if (!PinHelper.verifyPin(pin, user.pinHash)) {
      setState(() {
        _loading = false;
        _erreur  = 'Code PIN incorrect. Réessaie.';
      });
      return;
    }

    // Connexion réussie → sauvegarder la session
    await PinHelper.saveSession(
      userId:    user.id!,
      prenom:    user.prenom,
      telephone: user.telephone,
    );

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ téléphone
                  const Text(
                    'Ton numéro de téléphone',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildPhoneField(),

                  const SizedBox(height: 20),

                  // Label PIN
                  const Text(
                    'Ton code PIN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Clavier PIN
                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.green),
                        )
                      : PinPad(
                          onComplete: _onPinSaisi,
                          errorMessage: _erreur,
                        ),

                  const SizedBox(height: 20),

                  // Lien inscription
                  OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, Routes.inscription),
                    child: const Text('Créer un compte'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildHeader() {
  return Container(
    color: AppTheme.green,
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 52, 16, 22),
    child: Column(
      children: [
        // Logo de l'app dans un cercle blanc
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco_rounded,
                color: AppTheme.green,
                size: 36,
              ),
            ),
          ),
        ),
         const Text(
          'AgriSmart',
          style: TextStyle(color: AppTheme.greenPale, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          'Connecte-toi à ton compte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        
      ],
    ),
  );
}

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '🇹🇬  +228',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade200),
          Expanded(
            child: TextField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '90 00 00 00',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _telCtrl.dispose();
    super.dispose();
  }
}