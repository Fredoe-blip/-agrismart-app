// lib/core/navigation/routes.dart
//
// Toutes les routes de l'app dans un seul endroit.
// Utilisation : Navigator.pushNamed(context, Routes.welcome)

class Routes {
  Routes._(); // empêche l'instanciation

  static const inscription = '/inscription';
  static const pinCreate   = '/pin-create';
  static const login       = '/login';
  static const welcome     = '/welcome';
  static const scanner     = '/scanner';
  static const resultat    = '/resultat';
  static const historique  = '/historique';
}