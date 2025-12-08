class Workout {
  int? id;
  String name;
  DateTime date;
  int duration; // in minutes
  String notes;
  List<Exercise> exercises;
  
  Workout({
    this.id,
    required this.name,
    required this.date,
    required this.duration,
    this.notes = '',
    required this.exercises,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
      'notes': notes,
    };
  }
}

class Exercise {
  int? id;
  int workoutId;
  String name;
  int sets;
  int reps;
  double weight;
  
  Exercise({
    this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}

class DailyProgress {
  DateTime date;
  int steps;
  double weight;
  int caloriesBurned;
  
  DailyProgress({
    required this.date,
    required this.steps,
    required this.weight,
    required this.caloriesBurned,
  });
}