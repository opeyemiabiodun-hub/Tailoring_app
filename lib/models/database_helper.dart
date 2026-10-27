import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tailor_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tailor_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        clientId TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        gender TEXT NOT NULL,
        email TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        measurementId TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        outfitPart TEXT NOT NULL,
        fieldName TEXT NOT NULL,
        measurementValue REAL NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (clientId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        orderId TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        orderDescription TEXT NOT NULL,
        stylePhotoPath TEXT,
        fabricPhotoPath TEXT,
        totalAmount REAL NOT NULL,
        depositPaid REAL NOT NULL,
        balanceRemaining REAL NOT NULL,
        deliveryDate TEXT NOT NULL,
        orderStatus TEXT NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (clientId) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertClient(Client client) async {
    final db = await instance.database;
    return await db.insert('clients', client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMeasurement(Measurement measurement) async {
    final db = await instance.database;
    return await db.insert('measurements', measurement.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertOrder(Order order) async {
    final db = await instance.database;
    return await db.insert('orders', order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Client>> getClients() async {
    final db = await instance.database;
    final result = await db.query('clients');
    return result.map((json) => Client.fromMap(json)).toList();
  }

  // Get measurements for a specific client
  Future<List<Measurement>> getMeasurementsForClient(String clientId) async {
    final db = await instance.database;
    final result = await db.query(
      'measurements',
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
    return result.map((json) => Measurement.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
