import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/progress.dart';

/// Web-compatible storage helper using shared_preferences
class WebStorageHelper {
  static const String _workoutsKey = 'workouts';
  static const String _exercisesKey = 'exercises';

  // Create workout
  Future<int> createWorkout(Workout workout) async {
    final workouts = await _getWorkouts();

    // Generate ID
    final id = workouts.isEmpty
        ? 1
        : workouts.map((w) => w.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newWorkout = workout.copyWith(id: id);

    workouts.add(newWorkout);
    await _saveWorkouts(workouts);

    return id;
  }

  // Read all workouts
  Future<List<Workout>> readAllWorkouts() async {
    final workouts = await _getWorkouts();
    workouts.sort((a, b) => b.date.compareTo(a.date));
    return workouts;
  }

  // Read workouts by date range
  Future<List<Workout>> readWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final workouts = await _getWorkouts();
    return workouts.where((w) {
      return w.date.isAfter(start.subtract(const Duration(days: 1))) &&
          w.date.isBefore(end.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // Delete workout
  Future<int> deleteWorkout(int id) async {
    final workouts = await _getWorkouts();
    workouts.removeWhere((w) => w.id == id);
    await _saveWorkouts(workouts);

    // Also delete associated exercises
    final exercises = await _getExercises();
    exercises.removeWhere((e) => e.workoutId == id);
    await _saveExercises(exercises);

    return 1;
  }

  // Create exercise
  Future<int> createExercise(Exercise exercise) async {
    final exercises = await _getExercises();

    // Generate ID
    final id = exercises.isEmpty
        ? 1
        : exercises.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newExercise = exercise.copyWith(id: id);

    exercises.add(newExercise);
    await _saveExercises(exercises);

    return id;
  }

  // Read exercises by workout
  Future<List<Exercise>> readExercisesByWorkout(int workoutId) async {
    final exercises = await _getExercises();
    return exercises.where((e) => e.workoutId == workoutId).toList();
  }

  // Get weekly progress
  Future<List<Progress>> getWeeklyProgress() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final workouts = await readWorkoutsByDateRange(weekAgo, now);

    // Group by date
    final Map<String, List<Workout>> grouped = {};
    for (var workout in workouts) {
      final dateKey =
          '${workout.date.year}-${workout.date.month}-${workout.date.day}';
      grouped.putIfAbsent(dateKey, () => []).add(workout);
    }

    // Create progress entries
    final progress = <Progress>[];
    grouped.forEach((dateKey, dayWorkouts) {
      final date = dayWorkouts.first.date;
      final totalCalories = dayWorkouts.fold<int>(
        0,
        (sum, w) => sum + w.calories,
      );
      final totalDuration = dayWorkouts.fold<int>(
        0,
        (sum, w) => sum + w.duration,
      );

      progress.add(
        Progress(
          date: date,
          workoutCount: dayWorkouts.length,
          totalCalories: totalCalories,
          totalDuration: totalDuration,
        ),
      );
    });

    return progress;
  }

  // Get total stats
  Future<Map<String, int>> getTotalStats() async {
    final workouts = await _getWorkouts();

    if (workouts.isEmpty) {
      return {'total_workouts': 0, 'total_calories': 0, 'total_duration': 0};
    }

    return {
      'total_workouts': workouts.length,
      'total_calories': workouts.fold<int>(0, (sum, w) => sum + w.calories),
      'total_duration': workouts.fold<int>(0, (sum, w) => sum + w.duration),
    };
  }

  // Private helper methods
  Future<List<Workout>> _getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_workoutsKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Workout.fromMap(json)).toList();
  }

  Future<void> _saveWorkouts(List<Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = workouts.map((w) => w.toMap()).toList();
    await prefs.setString(_workoutsKey, json.encode(jsonList));
  }

  Future<List<Exercise>> _getExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_exercisesKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Exercise.fromMap(json)).toList();
  }

  Future<void> _saveExercises(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exercises.map((e) => e.toMap()).toList();
    await prefs.setString(_exercisesKey, json.encode(jsonList));
  }
}
