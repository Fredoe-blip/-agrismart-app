// lib/fonctionnalites/auth/inscription_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _prenomCtrl = TextEditingController();
  final _telCtrl    = TextEditingController();
  String? _erreur;

  void _continuer() {
    final prenom = _prenomCtrl.text.trim();
    final tel    = _telCtrl.text.trim();

    // Validations simples
    if (prenom.isEmpty) {
      setState(() => _erreur = 'Entre ton prénom');
      return;
    }
    if (tel.isEmpty || tel.length < 8) {
      setState(() => _erreur = 'Entre un numéro valide (8 chiffres)');
      return;
    }

    setState(() => _erreur = null);

    // On passe prénom + numéro complet à l'écran suivant
    Navigator.pushNamed(
      context,
      Routes.pinCreate,
      arguments: {
        'prenom':     prenom,
        'telephone':  '+228$tel',
      },
    );
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
                  // Champ prénom
                  _label('Ton prénom'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _prenomCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'ex : Kofi',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Champ téléphone avec indicatif
                  _label('Ton numéro de téléphone'),
                  const SizedBox(height: 6),
                  _buildPhoneField(),

                  const SizedBox(height: 14),

                  // Message d'erreur
                  if (_erreur != null) _buildErreur(_erreur!),

                  // Info
                  _buildInfo(
                    'Ton numéro sert à retrouver ton compte.\nPas besoin d\'internet pour te connecter.',
                  ),

                  const SizedBox(height: 20),

                  // Bouton continuer
                  ElevatedButton(
                    onPressed: _continuer,
                    child: const Text('Continuer →'),
                  ),

                  const SizedBox(height: 12),

                  // Séparateur
                  _buildDivider(),

                  const SizedBox(height: 12),

                  // Lien vers connexion
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                    child: const Text("J'ai déjà un compte"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets locaux ───────────────────────────────────────────────────────────

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
          'Créer mon compte',
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
          // Indicatif fixe Togo
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

  Widget _label(String texte) {
    return Text(
      texte,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF444444),
      ),
    );
  }

  Widget _buildErreur(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                  color: AppTheme.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String texte) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.greenLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppTheme.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3A5F3A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }
}