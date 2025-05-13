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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgradeSafe,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cria tabela Categoria primeiro
    await db.execute('''
      CREATE TABLE categoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      );
    ''');

    // Cria tabela Plantas com relação 1:N
    await db.execute('''
      CREATE TABLE plantas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        cuidados TEXT,
        imagemPath TEXT,
        categoria_id INTEGER,
        FOREIGN KEY (categoria_id) REFERENCES categoria(id) ON DELETE SET NULL
      );
    ''');
  }

  Future<void> _onUpgradeSafe(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS plantas;');
      await db.execute('DROP TABLE IF EXISTS categoria;');
      await _onCreate(db, newVersion);
    }
  }

  // Inserir categoria
  Future<int> insertCategoria(String nome) async {
    final db = await database;
    return await db.insert('categoria', {'nome': nome});
  }

  // Inserir planta
  Future<int> insertPlanta(Map<String, dynamic> planta) async {
    final db = await database;
    return await db.insert('plantas', planta);
  }

  // Atualizar planta
  Future<int> updatePlanta(Map<String, dynamic> planta) async {
    final db = await database;
    return await db.update(
      'plantas',
      planta,
      where: 'id = ?',
      whereArgs: [planta['id']],
    );
  }

  // Deletar planta
  Future<int> deletePlanta(int id) async {
    final db = await database;
    return await db.delete('plantas', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar todas as plantas
  Future<List<Map<String, dynamic>>> getPlantas() async {
    final db = await database;
    return await db.query('plantas');
  }

  // Buscar plantas com o nome da categoria (JOIN)
  Future<List<Map<String, dynamic>>> getPlantasComCategoria() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT plantas.*, categoria.nome AS categoria_nome
      FROM plantas
      LEFT JOIN categoria ON plantas.categoria_id = categoria.id
    ''');
  }

  // Buscar todas as categorias
  Future<List<Map<String, dynamic>>> getCategorias() async {
    final db = await database;
    return await db.query('categoria');
  }
}
