import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/user_profile_model.dart';
import '../data/local_storage.dart';

class WorkoutProvider extends ChangeNotifier {
  List<ExerciseModel> allExercises = [];
  List<WorkoutModel> savedWorkouts = [];
  List<WorkoutModel> presetWorkouts = [];
  UserProfileModel? userProfile;
  List<Map<String, dynamic>> cardioHistory = [];
  bool isLoading = true;

  WorkoutProvider() {
    loadData();
  }

  String _normalizeName(String value) {
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
  }

  ExerciseModel? _resolveExercise(
    List<ExerciseModel> exercises,
    List<String> aliases,
  ) {
    final normalizedCandidates = aliases
        .map((alias) => _normalizeName(alias))
        .where((alias) => alias.isNotEmpty)
        .toList();

    for (final alias in normalizedCandidates) {
      for (final exercise in exercises) {
        final normalizedExercise = _normalizeName(exercise.name);
        if (normalizedExercise == alias ||
            normalizedExercise.contains(alias) ||
            alias.contains(normalizedExercise)) {
          return exercise;
        }
      }
    }

    return null;
  }

  List<WorkoutModel> _buildPresetWorkouts(List<ExerciseModel> exercises) {
    final plans = [
      (
        'hipertrofia-1',
        'Hipertrofia | Dia 1',
        [
          ['Supino Reto com Barra', 'Supino Reto'],
          ['Supino Inclinado com Halteres', 'Supino Inclinado'],
          ['Crucifixo na Polia', 'Crucifixo'],
          ['Desenvolvimento com Halteres', 'Desenvolvimento'],
          ['Elevação Lateral', 'Elevação lateral'],
          ['Tríceps na Polia com Corda', 'Tríceps corda'],
        ],
      ),
      (
        'hipertrofia-2',
        'Hipertrofia | Dia 2',
        [
          ['Puxada Alta na Polia', 'Puxada alta'],
          ['Remada Curvada com Barra', 'Remada curvada'],
          ['Remada Baixa', 'Remada baixa'],
          ['Barra Fixa', 'Barra fixa'],
          ['Rosca Direta com Barra', 'Rosca direta'],
          ['Rosca Martelo', 'Rosca martelo'],
        ],
      ),
      (
        'hipertrofia-3',
        'Hipertrofia | Dia 3',
        [
          ['Agachamento Livre', 'Agachamento'],
          ['Leg Press 45º', 'Leg Press'],
          ['Cadeira Extensora', 'Extensora'],
          ['Mesa Flexora', 'Flexora'],
          ['Stiff com Barra', 'Stiff'],
          ['Panturrilha em Pé na Máquina', 'Panturrilha em pé'],
        ],
      ),
      (
        'emagrecimento-1',
        'Emagrecimento | Dia 1',
        [
          ['Agachamento Livre', 'Agachamento'],
          ['Supino Inclinado com Halteres', 'Supino Inclinado'],
          ['Puxada Alta na Polia', 'Puxada alta'],
          ['Remada Baixa', 'Remada baixa'],
          ['Desenvolvimento com Halteres', 'Desenvolvimento'],
          ['Prancha Abdominal', 'Prancha'],
        ],
      ),
      (
        'emagrecimento-2',
        'Emagrecimento | Dia 2',
        [
          ['Leg Press 45º', 'Leg Press'],
          ['Afundo com Halteres', 'Afundo'],
          ['Cadeira Extensora', 'Extensora'],
          ['Mesa Flexora', 'Flexora'],
          ['Panturrilha em Pé na Máquina', 'Panturrilha em pé'],
          ['Bicicleta Ergométrica', 'Bicicleta'],
        ],
      ),
      (
        'emagrecimento-3',
        'Emagrecimento | Dia 3',
        [
          ['Supino Reto com Barra', 'Supino Reto'],
          ['Puxada Alta na Polia', 'Puxada alta'],
          ['Remada Baixa', 'Remada baixa'],
          ['Elevação Lateral', 'Elevação lateral'],
          ['Rosca Direta com Barra', 'Rosca direta'],
          ['Tríceps na Polia com Corda', 'Tríceps corda'],
        ],
      ),
      (
        'mobilidade-1',
        'Mobilidade | Dia 1',
        [
          ['Mobilidade 90/90', '90/90'],
          ['Alongamento do Flexor do Quadril', 'Flexor do quadril'],
          ['Agachamento Profundo Assistido', 'Agachamento profundo'],
          ['Ponte de Glúteos', 'Ponte'],
          ['Alongamento de Posteriores', 'Posteriores'],
          ['Rotação de Quadril', 'Quadril'],
        ],
      ),
      (
        'mobilidade-2',
        'Mobilidade | Dia 2',
        [
          ['Rotação Torácica', 'Torácica'],
          ['Wall Slides', 'Wall slide'],
          ['Passagem de Bastão', 'Bastão'],
          ['Gato-Vaca', 'Gato vaca'],
          ['Alongamento de Peitoral', 'Peitoral'],
          ['Mobilidade Escapular', 'Escapular'],
        ],
      ),
      (
        'mobilidade-3',
        'Mobilidade | Dia 3',
        [
          ['Saudação ao Sol Adaptada', 'Saudação ao sol'],
          ['World\'s Greatest Stretch', 'greater stretch'],
          ['Rotação de Quadril', 'Quadril'],
          ['Alongamento de Panturrilha', 'Panturrilha'],
          ['Rotação de Coluna deitado', 'Rotação de coluna'],
          ['Postura da Criança', 'criança'],
        ],
      ),
    ];

    return plans.map((plan) {
      final (id, name, aliasesList) = plan;
      final configuredExercises = aliasesList.map((aliases) {
        final exercise = _resolveExercise(exercises, aliases);
        if (exercise == null) {
          return WorkoutExerciseConfig(
            exerciseId: 'fallback_${aliases.first}',
            exerciseName: aliases.first,
            muscleGroup: 'Treino',
            sets: 3,
            reps: 12,
            weight: 0,
          );
        }
        return WorkoutExerciseConfig(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          muscleGroup: exercise.muscleGroup,
          sets: 3,
          reps: 12,
          weight: 0,
        );
      }).toList();

      return WorkoutModel(
        id: id,
        name: name,
        exercises: configuredExercises,
        isCustom: false,
      );
    }).toList();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    allExercises = LocalStorage.getInitialExercises();
    presetWorkouts = _buildPresetWorkouts(allExercises);
    savedWorkouts = await LocalStorage.getWorkouts();
    userProfile = await LocalStorage.getProfile();
    cardioHistory = await LocalStorage.getCardioHistory();

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveWorkout(WorkoutModel workout) async {
    final index = savedWorkouts.indexWhere((w) => w.id == workout.id);
    if (index >= 0) {
      savedWorkouts[index] = workout;
    } else {
      savedWorkouts.add(workout);
    }
    await LocalStorage.saveWorkouts(savedWorkouts);
    notifyListeners();
  }

  Future<void> deleteWorkout(String id) async {
    savedWorkouts.removeWhere((w) => w.id == id);
    await LocalStorage.saveWorkouts(savedWorkouts);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    final history = profile.monthlyHistory.isEmpty
        ? UserProfileModel.buildDefaultHistory(profile.weight, profile.height)
        : profile.monthlyHistory;

    userProfile = UserProfileModel(
      name: profile.name,
      email: profile.email,
      height: profile.height,
      weight: profile.weight,
      age: profile.age,
      sex: profile.sex,
      objective: profile.objective,
      level: profile.level,
      monthlyHistory: history,
    );

    await LocalStorage.saveProfile(userProfile!);
    notifyListeners();
  }

  Future<void> addCardioCompletion(
      String workoutName, int minutes, String exerciseName) async {
    final entry = {
      'workoutName': workoutName,
      'exerciseName': exerciseName,
      'minutes': minutes,
      'completedAt': DateTime.now().toIso8601String(),
    };
    cardioHistory.insert(0, entry);
    await LocalStorage.saveCardioHistory(cardioHistory);
    notifyListeners();
  }
}
