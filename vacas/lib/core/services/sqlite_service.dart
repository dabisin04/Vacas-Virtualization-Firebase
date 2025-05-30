import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteService {
  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDB('ganado.db');
    return _database!;
  }

  static Future<Database> _initDB(String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite no está disponible en Flutter web.');
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE farms (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      ubicacion TEXT NOT NULL,
      descripcion TEXT,
      propietario_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0,
      foto_url TEXT,
      local_foto_url TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE usuarios (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      rol TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE usuario_finca (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      farm_id TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE animals (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      nombre TEXT NOT NULL,
      tipo TEXT NOT NULL,
      raza TEXT,
      proposito TEXT,
      ganaderia TEXT,
      foto_url TEXT,
      local_foto_url TEXT,
      corral TEXT,
      num_animal TEXT,
      codigo_referencia TEXT,
      fecha_nacimiento TEXT,
      peso_nacimiento REAL,
      padre_id TEXT,
      madre_id TEXT,
      created_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE chequeos_salud (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      fecha TEXT NOT NULL,
      diagnostico TEXT,
      tratamiento TEXT,
      observaciones TEXT,
      realizado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE eventos_reproductivos (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      tipo TEXT NOT NULL,
      resultado TEXT,
      fecha TEXT NOT NULL,
      realizado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE produccion_leche (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      fecha TEXT NOT NULL,
      cantidad_litros REAL NOT NULL,
      registrado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE tratamientos (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      medicamento TEXT NOT NULL,
      motivo TEXT,
      fecha TEXT NOT NULL,
      registrado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE vacunas (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      nombre TEXT NOT NULL,
      motivo TEXT,
      fecha TEXT NOT NULL,
      registrado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE pesos (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      animal_id TEXT NOT NULL,
      peso_kg REAL NOT NULL,
      fecha TEXT NOT NULL,
      registrado_por TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sincronizado INTEGER DEFAULT 0
    );
  ''');

    await db.execute('CREATE INDEX idx_animals_farm_id ON animals(farm_id);');
    await db.execute(
        'CREATE INDEX idx_user_farm_user_id ON usuario_finca(user_id);');
    await db.execute(
        'CREATE INDEX idx_user_farm_farm_id ON usuario_finca(farm_id);');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      //await db.execute('ALTER TABLE farms ADD COLUMN foto_url TEXT');
      //await db.execute('ALTER TABLE animals ADD COLUMN local_foto_url TEXT');
      //await db.execute('ALTER TABLE farms ADD COLUMN local_foto_url TEXT');
    }
  }
}
