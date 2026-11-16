class WorkoutExerciseConfig {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  int sets;
  int reps;
  double weight;
  int restTimeSeconds;
  String notes;

  WorkoutExerciseConfig({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.sets = 3,
    this.reps = 12,
    this.weight = 0.0,
    this.restTimeSeconds = 60,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'restTimeSeconds': restTimeSeconds,
        'notes': notes,
      };

  factory WorkoutExerciseConfig.fromJson(Map<String, dynamic> json) =>
      WorkoutExerciseConfig(
        exerciseId: json['exerciseId'],
        exerciseName: json['exerciseName'],
        muscleGroup: json['muscleGroup'],
        sets: json['sets'],
        reps: json['reps'],
        weight: (json['weight'] as num).toDouble(),
        restTimeSeconds: json['restTimeSeconds'],
        notes: json['notes'] ?? '',
      );
}

class WorkoutModel {
  final String id;
  String name;
  List<WorkoutExerciseConfig> exercises;
  bool isCustom;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.exercises,
    this.isCustom = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isCustom': isCustom,
      };

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['id'],
        name: json['name'],
        exercises: (json['exercises'] as List)
            .map((e) => WorkoutExerciseConfig.fromJson(e))
            .toList(),
        isCustom: json['isCustom'] ?? true,
      );
}
