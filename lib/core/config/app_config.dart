// lib/core/config/app_config.dart
//
// Fichier de configuration.
// Quand l'ami relance Colab et obtient une nouvelle URL ngrok,
// il suffit de changer UNIQUEMENT la valeur de apiBaseUrl ici.

class AppConfig {
  AppConfig._();

  // ── URL de l'API ───────────────────────────────────────
  // Remplacer par la nouvelle URL ngrok à chaque relance de Colab
  static const String apiBaseUrl =
      'https://agrismart-api-production.up.railway.app';

  // Endpoints
  static const String predictEndpoint = '/predict';
  static const String healthEndpoint  = '/';

  // Timeout pour les requêtes (en secondes)
  static const int timeoutSeconds = 30;

  // Taille image envoyée à l'API (doit correspondre au modèle)
  static const int imageSize = 160;
}