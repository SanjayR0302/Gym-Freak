import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/progress.dart';
import 'web_storage_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static WebStorageHelper? _webStorage;

  DatabaseHelper._init();

  Future<dynamic> get database async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return _webStorage!;
    }

    if (_database != null) return _database!;
    _database = await _initDB('fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE workouts (
        id $idType,
        name $textType,
        date $textType,
        duration $integerType,
        calories $integerType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        workout_id $integerType,
        name $textType,
        sets $integerType,
        reps $integerType,
        weight $realType,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');
  }

  // Workout CRUD operations
  Future<int> createWorkout(Workout workout) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.createWorkout(workout);
    }

    final db = await database as Database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<Workout?> readWorkout(int id) async {
    if (kIsWeb) {
      final workouts = await _webStorage!.readAllWorkouts();
      return workouts.firstWhere((w) => w.id == id);
    }

    final db = await database as Database;
    final maps = await db.query('workouts', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Workout.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Workout>> readAllWorkouts() async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.readAllWorkouts();
    }

    final db = await database as Database;
    const orderBy = 'date DESC';
    final result = await db.query('workouts', orderBy: orderBy);
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  Future<List<Workout>> readWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (kIsWeb) {
      return await _webStorage!.readWorkoutsByDateRange(start, end);
    }

    final db = await database as Database;
    final result = await db.query(
      'workouts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Workout.fromMap(json)).toList();
  }

  Future<int> updateWorkout(Workout workout) async {
    if (kIsWeb) {
      // For web, delete and recreate
      await _webStorage!.deleteWorkout(workout.id!);
      return await _webStorage!.createWorkout(workout);
    }

    final db = await database as Database;
    return db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    if (kIsWeb) {
      return await _webStorage!.deleteWorkout(id);
    }

    final db = await database as Database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // Exercise CRUD operations
  Future<int> createExercise(Exercise exercise) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.createExercise(exercise);
    }

    final db = await database as Database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> readExercisesByWorkout(int workoutId) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.readExercisesByWorkout(workoutId);
    }

    final db = await database as Database;
    final result = await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
    return result.map((json) => Exercise.fromMap(json)).toList();
  }

  Future<int> updateExercise(Exercise exercise) async {
    if (kIsWeb) {
      // Not implemented for web yet
      return 0;
    }

    final db = await database as Database;
    return db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    if (kIsWeb) {
      // Not implemented for web yet
      return 0;
    }

    final db = await database as Database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // Progress/Statistics queries
  Future<List<Progress>> getWeeklyProgress() async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.getWeeklyProgress();
    }

    final db = await database as Database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final result = await db.rawQuery(
      '''
      SELECT 
        date(date) as date,
        COUNT(*) as workout_count,
        SUM(calories) as total_calories,
        SUM(duration) as total_duration
      FROM workouts
      WHERE date >= ?
      GROUP BY date(date)
      ORDER BY date DESC
    ''',
      [weekAgo.toIso8601String()],
    );

    return result.map((json) => Progress.fromMap(json)).toList();
  }

  Future<Map<String, int>> getTotalStats() async {
    if (kIsWeb) {
      _webStorage ??= WebStorageHelper();
      return await _webStorage!.getTotalStats();
    }

    final db = await database as Database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_workouts,
        COALESCE(SUM(calories), 0) as total_calories,
        COALESCE(SUM(duration), 0) as total_duration
      FROM workouts
    ''');

    if (result.isNotEmpty) {
      return {
        'total_workouts': result.first['total_workouts'] as int,
        'total_calories': result.first['total_calories'] as int,
        'total_duration': result.first['total_duration'] as int,
      };
    }
    return {'total_workouts': 0, 'total_calories': 0, 'total_duration': 0};
  }

  Future close() async {
    if (kIsWeb) return;

    final db = await database as Database;
    db.close();
  }
}
