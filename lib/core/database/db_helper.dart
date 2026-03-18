// lib/core/database/db_helper.dart
//
// Toute la logique SQLite de l'app.
// Deux tables : users et diagnostics.
// Singleton : DbHelper.instance partout dans l'app.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/diagnostic_model.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ── Initialisation ───────────────────────────────────────────────────────────

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'agrismart.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        prenom      TEXT    NOT NULL,
        telephone   TEXT    NOT NULL UNIQUE,
        pin_hash    TEXT    NOT NULL,
        created_at  TEXT    NOT NULL
      )
    ''');

    // Table diagnostics (liée à un utilisateur)
    await db.execute('''
      CREATE TABLE diagnostics (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        culture     TEXT    NOT NULL,
        maladie     TEXT    NOT NULL,
        confiance   REAL    NOT NULL,
        statut      TEXT    NOT NULL,
        conseils    TEXT    NOT NULL,
        image_path  TEXT,
        date        TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Users ────────────────────────────────────────────────────────────────────

  /// Crée un nouveau compte — retourne l'ID généré
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Récupère un utilisateur par son numéro de téléphone
  Future<UserModel?> getUserByTelephone(String telephone) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'telephone = ?',
      whereArgs: [telephone],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// Vérifie si un numéro est déjà enregistré
  Future<bool> telephoneExiste(String telephone) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'telephone = ?',
      whereArgs: [telephone],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ── Diagnostics ──────────────────────────────────────────────────────────────

  /// Sauvegarde un diagnostic — retourne l'ID généré
  Future<int> insertDiagnostic(DiagnosticModel d) async {
    final db = await database;
    return db.insert('diagnostics', d.toMap());
  }

  /// Récupère tous les diagnostics d'un utilisateur, du plus récent au plus ancien
  Future<List<DiagnosticModel>> getDiagnosticsUser(int userId) async {
    final db = await database;
    final rows = await db.query(
      'diagnostics',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map(DiagnosticModel.fromMap).toList();
  }

  /// Supprime un diagnostic par son ID
  Future<void> deleteDiagnostic(int id) async {
    final db = await database;
    await db.delete('diagnostics', where: 'id = ?', whereArgs: [id]);
  }

  /// Compte le nombre de diagnostics d'un utilisateur
  Future<int> countDiagnostics(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM diagnostics WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}