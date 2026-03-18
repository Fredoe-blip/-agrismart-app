// lib/fonctionnalites/auth/pin_create_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/routes.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/pin_helper.dart';
import '../../widgets/pin_pad.dart';

class PinCreateScreen extends StatefulWidget {
  const PinCreateScreen({super.key});

  @override
  State<PinCreateScreen> createState() => _PinCreateScreenState();
}

class _PinCreateScreenState extends State<PinCreateScreen> {
  // Étape 1 : choisir le PIN  |  Étape 2 : confirmer le PIN
  String? _premierPin;
  bool    _enConfirmation = false;
  String? _erreur;
  bool    _loading = false;

  Future<void> _onPinSaisi(String pin) async {
    // ── Étape 1 : mémoriser le premier PIN ──────────────
    if (!_enConfirmation) {
      setState(() {
        _premierPin     = pin;
        _enConfirmation = true;
        _erreur         = null;
      });
      return;
    }

    // ── Étape 2 : vérifier la confirmation ──────────────
    if (pin != _premierPin) {
      setState(() {
        _erreur         = 'Les codes ne correspondent pas. Réessaie.';
        _premierPin     = null;
        _enConfirmation = false;
      });
      return;
    }

    // ── Créer le compte ──────────────────────────────────
    setState(() => _loading = true);

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final prenom    = args['prenom']    as String;
    final telephone = args['telephone'] as String;

    // Vérifier que le numéro n'est pas déjà pris
    final existe = await DbHelper.instance.telephoneExiste(telephone);
    if (existe) {
      setState(() {
        _loading        = false;
        _erreur         = 'Ce numéro est déjà utilisé.';
        _premierPin     = null;
        _enConfirmation = false;
      });
      return;
    }

    // Insérer l'utilisateur
    final user = UserModel(
      prenom:    prenom,
      telephone: telephone,
      pinHash:   PinHelper.hashPin(pin),
      createdAt: DateTime.now().toIso8601String(),
    );

    final userId = await DbHelper.instance.insertUser(user);

    // Sauvegarder la session
    await PinHelper.saveSession(
      userId:    userId,
      prenom:    prenom,
      telephone: telephone,
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Info contextuelle
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.greenLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock_outline,
                                  color: AppTheme.green, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ce code remplace le mot de passe.\nFacile à retenir, difficile à deviner.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF3A5F3A),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Clavier PIN — la key change quand on passe en confirmation
                        // pour réinitialiser automatiquement le widget
                        PinPad(
                          key: ValueKey(_enConfirmation),
                          onComplete: _onPinSaisi,
                          errorMessage: _erreur,
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
          Text(
            _enConfirmation ? 'Confirme ton code PIN' : 'Choisis ton code PIN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _enConfirmation
                ? 'Entre à nouveau le même code'
                : '4 chiffres pour sécuriser ton compte',
            style: const TextStyle(color: AppTheme.greenPale, fontSize: 12),
          ),
        ],
      ),
    );
  }
}