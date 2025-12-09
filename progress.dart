class Progress {
  final DateTime date;
  final int workoutCount;
  final int totalCalories;
  final int totalDuration; // in minutes

  Progress({
    required this.date,
    required this.workoutCount,
    required this.totalCalories,
    required this.totalDuration,
  });

  // Create from Map
  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      date: DateTime.parse(map['date'] as String),
      workoutCount: map['workout_count'] as int,
      totalCalories: map['total_calories'] as int,
      totalDuration: map['total_duration'] as int,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'workout_count': workoutCount,
      'total_calories': totalCalories,
      'total_duration': totalDuration,
    };
  }
}
