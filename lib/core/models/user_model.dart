// lib/core/models/user_model.dart

class UserModel {
  final int?   id;
  final String prenom;
  final String telephone;
  final String pinHash;
  final String createdAt;

  const UserModel({
    this.id,
    required this.prenom,
    required this.telephone,
    required this.pinHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'prenom':     prenom,
    'telephone':  telephone,
    'pin_hash':   pinHash,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id:        m['id'] as int?,
    prenom:    m['prenom'] as String,
    telephone: m['telephone'] as String,
    pinHash:   m['pin_hash'] as String,
    createdAt: m['created_at'] as String,
  );
}