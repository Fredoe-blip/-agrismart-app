// lib/core/models/diagnostic_model.dart

class DiagnosticModel {
  final int?   id;
  final int    userId;
  final String culture;     // 'Maïs' ou 'Manioc'
  final String maladie;     // 'Sain', 'Rouille', 'Cercospora', etc.
  final double confiance;   // 0.0 → 1.0
  final String statut;      // 'sain' ou 'malade'
  final String conseils;    // texte des actions à faire
  final String? imagePath;  // chemin local de la photo (optionnel)
  final String date;        // ISO 8601

  const DiagnosticModel({
    this.id,
    required this.userId,
    required this.culture,
    required this.maladie,
    required this.confiance,
    required this.statut,
    required this.conseils,
    this.imagePath,
    required this.date,
  });

  // ── Helpers ────────────────────────────────────────────

  bool get estSain => statut == 'sain';

  String get confianceLabel {
    if (confiance >= 0.80) return 'ÉLEVÉE';
    if (confiance >= 0.50) return 'MOYENNE';
    return 'FAIBLE';
  }

  String get dateFormatee {
    final d = DateTime.parse(date);
    final j = d.day.toString().padLeft(2, '0');
    final m = d.month.toString().padLeft(2, '0');
    return '$j/$m';
  }

  // ── Sérialisation ──────────────────────────────────────

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':    userId,
    'culture':    culture,
    'maladie':    maladie,
    'confiance':  confiance,
    'statut':     statut,
    'conseils':   conseils,
    'image_path': imagePath,
    'date':       date,
  };

  factory DiagnosticModel.fromMap(Map<String, dynamic> m) => DiagnosticModel(
    id:         m['id'] as int?,
    userId:     m['user_id'] as int,
    culture:    m['culture'] as String,
    maladie:    m['maladie'] as String,
    confiance:  (m['confiance'] as num).toDouble(),
    statut:     m['statut'] as String,
    conseils:   m['conseils'] as String,
    imagePath:  m['image_path'] as String?,
    date:       m['date'] as String,
  );

  /// Convertit en Map pour passer via Navigator.pushNamed arguments
  Map<String, dynamic> toArgs() => {
    'culture':   culture,
    'maladie':   maladie,
    'confiance': confiance,
    'statut':    statut,
    'conseils':  conseils,
  };
}