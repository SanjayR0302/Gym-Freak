class Exercise {
  final int? id;
  final int workoutId;
  final String name;
  final int sets;
  final int reps;
  final double weight; // in kg

  Exercise({
    this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  // Create from Map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] != null ? map['id'] as int : null,
      workoutId: map['workout_id'] is int
          ? map['workout_id'] as int
          : int.parse(map['workout_id'].toString()),
      name: map['name'] as String,
      sets: map['sets'] is int
          ? map['sets'] as int
          : int.parse(map['sets'].toString()),
      reps: map['reps'] is int
          ? map['reps'] as int
          : int.parse(map['reps'].toString()),
      weight: map['weight'] is double
          ? map['weight'] as double
          : double.parse(map['weight'].toString()),
    );
  }

  // Copy with method
  Exercise copyWith({
    int? id,
    int? workoutId,
    String? name,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
}
