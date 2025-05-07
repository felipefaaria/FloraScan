import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  DB._();
  static final DB instance = DB._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'plantas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createPlantaTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Exemplo de upgrade: recriar a tabela
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS plantas');
      await _onCreate(db, newVersion);
    }
  }

  String get _createPlantaTable => '''
    CREATE TABLE plantas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT,
      descricao TEXT,
      imagemPath TEXT
    )
  ''';

  Future<int> insertPlanta(Map<String, dynamic> planta) async {
    final db = await database;
    return await db.insert('plantas', planta);
  }

  Future<List<Map<String, dynamic>>> getPlantas() async {
    final db = await database;
    return await db.query('plantas');
  }

  Future<int> deletePlanta(int id) async {
    final db = await database;
    return await db.delete('plantas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePlanta(Map<String, dynamic> planta) async {
    final db = await database;
    return await db.update(
      'plantas',
      planta,
      where: 'id = ?',
      whereArgs: [planta['id']],
    );
  }
}
