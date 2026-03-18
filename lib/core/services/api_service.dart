// lib/core/services/api_service.dart
//
// Service qui envoie les photos à l'API FastAPI
// et retourne un DiagnosticResult prêt à afficher.

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// ── Résultat retourné à l'app ────────────────────────────────────────────────
class DiagnosticResult {
  final String maladie;        // nom traduit en français
  final String maladieEn;      // nom original de l'API
  final double confiance;      // 0.0 → 1.0
  final String statut;         // 'sain' ou 'malade'
  final String culture;        // 'Maïs' (manioc plus tard)
  final String conseils;       // texte des actions à faire
  final String description;    // description courte de la maladie

  const DiagnosticResult({
    required this.maladie,
    required this.maladieEn,
    required this.confiance,
    required this.statut,
    required this.culture,
    required this.conseils,
    required this.description,
  });
}

// ── Erreurs possibles ────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

// ── Service principal ────────────────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Envoie une image à l'API et retourne le diagnostic
  Future<DiagnosticResult> analyserImage(File imageFile) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}${AppConfig.predictEndpoint}');

      // Construire la requête multipart
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        )
        // Header requis par ngrok pour éviter le browser warning
        ..headers['ngrok-skip-browser-warning'] = 'true';

      // Envoyer avec timeout
      final streamedResponse = await request.send().timeout(
        Duration(seconds: AppConfig.timeoutSeconds),
        onTimeout: () => throw const ApiException(
            'Délai dépassé. Vérifie ta connexion internet.'),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw ApiException(
            'Erreur serveur (${response.statusCode}). Réessaie.');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final maladieEn  = json['maladie']   as String;
      final confiancePct = (json['confiance'] as num).toDouble();

      // Convertir en 0.0–1.0
      final confiance = confiancePct / 100.0;

      return _construireResultat(
        maladieEn: maladieEn,
        confiance: confiance,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
          'Pas de connexion internet. Vérifie ton réseau.');
    } catch (e) {
      throw ApiException('Erreur inattendue : $e');
    }
  }

  /// Vérifie si l'API est accessible
  Future<bool> estAccessible() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.healthEndpoint}'),
            headers: {'ngrok-skip-browser-warning': 'true'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Traduction et conseils ───────────────────────────────────────────────────

  DiagnosticResult _construireResultat({
    required String maladieEn,
    required double confiance,
  }) {
    switch (maladieEn) {

      case 'Healthy':
        return DiagnosticResult(
          maladie:     'Plante saine',
          maladieEn:   maladieEn,
          confiance:   confiance,
          statut:      'sain',
          culture:     'Maïs',
          description: 'Aucune maladie détectée sur cette feuille.',
          conseils:
              '1. Continue à surveiller tes plants régulièrement\n'
              '2. Assure un arrosage suffisant selon la saison\n'
              '3. Reviens scanner dans 1 à 2 semaines',
        );

      case 'Common Rust':
        return DiagnosticResult(
          maladie:     'Rouille commune',
          maladieEn:   maladieEn,
          confiance:   confiance,
          statut:      'malade',
          culture:     'Maïs',
          description:
              'Maladie fongique causant des pustules orange-brun sur les feuilles.',
          conseils:
              '1. Retire et brûle les feuilles très atteintes loin du champ\n'
              '2. Évite d\'arroser le soir pour réduire l\'humidité\n'
              '3. Applique un fongicide à base de mancozèbe si disponible\n'
              '4. Reviens observer dans 2 jours',
        );

      case 'Northern Leaf Blight':
        return DiagnosticResult(
          maladie:     'Brûlure foliaire du nord',
          maladieEn:   maladieEn,
          confiance:   confiance,
          statut:      'malade',
          culture:     'Maïs',
          description:
              'Maladie fongique causant de longues taches grises sur les feuilles.',
          conseils:
              '1. Retire les feuilles gravement touchées et éloigne-les du champ\n'
              '2. Améliore la circulation d\'air entre les plants si possible\n'
              '3. Applique un fongicide foliaire recommandé dans ta région\n'
              '4. Consulte un conseiller agricole si ça progresse',
        );

      default:
        // Classe inconnue — on affiche quand même quelque chose
        return DiagnosticResult(
          maladie:     maladieEn,
          maladieEn:   maladieEn,
          confiance:   confiance,
          statut:      'malade',
          culture:     'Maïs',
          description: 'Anomalie détectée sur la feuille.',
          conseils:
              '1. Prends une nouvelle photo avec plus de lumière\n'
              '2. Si le problème persiste, consulte un conseiller agricole',
        );
    }
  }
}