// lib/core/theme/app_theme.dart
//
// Toutes les couleurs et le thème Material de l'app.
// Utilisation : AppTheme.green, AppTheme.light

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Couleurs principales ──────────────────────────────
  static const green       = Color(0xFF2D6A2D); // vert principal
  static const greenLight  = Color(0xFFF0F8F0); // fond vert clair
  static const greenPale   = Color(0xFFC8E6C8); // texte sur fond vert
  static const greenDark   = Color(0xFF1A4A1A); // vert foncé (scanner)
  static const bg          = Color(0xFFF9FAF7); // fond général de l'app

  // ── Couleurs sémantiques ──────────────────────────────
  static const success     = Color(0xFF155724); // texte "Sain"
  static const successBg   = Color(0xFFD4EDDA); // fond badge "Sain"
  static const warning     = Color(0xFF856404); // texte "Malade"
  static const warningBg   = Color(0xFFFFF3CD); // fond badge "Malade"
  static const error       = Color(0xFFC0392B); // texte erreur
  static const errorBg     = Color(0xFFFDECEA); // fond message erreur

  // ── Thème Material ────────────────────────────────────
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: green,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: green,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: green,
        side: const BorderSide(color: green),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13,
      ),
    ),
  );
}