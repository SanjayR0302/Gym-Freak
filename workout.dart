class Workout {
  final int? id;
  final String name;
  final DateTime date;
  final int duration; // in minutes
  final int calories;
  final String? notes;

  Workout({
    this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.calories,
    this.notes,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
      'calories': calories,
      'notes': notes,
    };
  }

  // Create from Map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] is int
          ? map['duration'] as int
          : int.parse(map['duration'].toString()),
      calories: map['calories'] is int
          ? map['calories'] as int
          : int.parse(map['calories'].toString()),
      notes: map['notes'] as String?,
    );
  }

  // Copy with method for updates
  Workout copyWith({
    int? id,
    String? name,
    DateTime? date,
    int? duration,
    int? calories,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
    );
  }
}
