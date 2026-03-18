// lib/core/utils/pin_helper.dart
//
// Gestion du PIN et de la session utilisateur.
// Le PIN est hashé en SHA-256 avant d'être stocké — jamais en clair.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinHelper {
  PinHelper._();

  static const _keyUserId = 'session_user_id';
  static const _keyPrenom = 'session_prenom';
  static const _keyTel    = 'session_telephone';

  // ── Hash ────────────────────────────────────────────────────────────────────

  /// Transforme le PIN en hash SHA-256 pour le stockage
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  /// Vérifie qu'un PIN correspond au hash stocké
  static bool verifyPin(String pin, String storedHash) {
    return hashPin(pin) == storedHash;
  }

  // ── Session ─────────────────────────────────────────────────────────────────

  /// Sauvegarde la session après connexion réussie
  static Future<void> saveSession({
    required int userId,
    required String prenom,
    required String telephone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyPrenom, prenom);
    await prefs.setString(_keyTel, telephone);
  }

  /// Récupère l'ID de l'utilisateur connecté (null si pas connecté)
  static Future<int?> getSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Récupère le prénom de l'utilisateur connecté
  static Future<String?> getSessionPrenom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrenom);
  }

  /// Récupère le numéro de téléphone de la session
  static Future<String?> getSessionTelephone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTel);
  }

  /// Vérifie si un utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final id = await getSessionUserId();
    return id != null;
  }

  /// Déconnecte l'utilisateur (efface la session)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPrenom);
    await prefs.remove(_keyTel);
  }
}