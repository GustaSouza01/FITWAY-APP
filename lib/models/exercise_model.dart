class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String description;
  final List<String> instructions;
  final String primaryMuscle;
  final List<String> secondaryMuscles;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    required this.instructions,
    required this.primaryMuscle,
    required this.secondaryMuscles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'description': description,
        'instructions': instructions,
        'primaryMuscle': primaryMuscle,
        'secondaryMuscles': secondaryMuscles,
      };

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'],
        name: json['name'],
        muscleGroup: json['muscleGroup'],
        description: json['description'],
        instructions: List<String>.from(json['instructions']),
        primaryMuscle: json['primaryMuscle'],
        secondaryMuscles: List<String>.from(json['secondaryMuscles']),
      );
}
