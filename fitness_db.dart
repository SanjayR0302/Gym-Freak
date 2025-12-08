import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class FitnessDatabase {
  static final FitnessDatabase _instance = FitnessDatabase._internal();
  factory FitnessDatabase() => _instance;
  FitnessDatabase._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        notes TEXT
      )
    ''');
    
    // Exercises table
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');
    
    // Daily progress table
    await db.execute('''
      CREATE TABLE daily_progress(
        date TEXT PRIMARY KEY,
        steps INTEGER DEFAULT 0,
        weight REAL,
        caloriesBurned INTEGER DEFAULT 0
      )
    ''');
  }
  
  // CRUD operations
  Future<int> insertWorkout(Workout workout) async {
    Database db = await database;
    return await db.insert('workouts', workout.toMap());
  }
  
  Future<List<Workout>> getWorkouts() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('workouts');
    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]);
    });
  }
}