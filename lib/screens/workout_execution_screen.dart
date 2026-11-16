import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../provider/workout_provider.dart';

enum WorkoutExecutionTab { exercises, muscles, tips }

class WorkoutExecutionScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutExecutionScreen({super.key, required this.workout});

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _selectedTabIndex = 0;
  bool _timerRunning = false;
  int _restSeconds = 60;
  Timer? _timer;

  WorkoutExecutionTab get _selectedTab =>
      WorkoutExecutionTab.values[_selectedTabIndex];

  WorkoutExerciseConfig get _currentExercise =>
      widget.workout.exercises[_currentExerciseIndex];

  bool get _isFinalSet => _currentSet >= _currentExercise.sets;

  bool get _isFinalExercise =>
      _currentExerciseIndex == widget.workout.exercises.length - 1;

  String get _continueButtonLabel {
    if (!_isFinalSet) return 'Completo';
    return _isFinalExercise ? 'Finalizar treino' : 'Próximo';
  }

  IconData get _continueButtonIcon {
    if (!_isFinalSet) return Icons.check_circle;
    return _isFinalExercise ? Icons.done_all : Icons.arrow_forward;
  }

  ExerciseModel? _exerciseDetails(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    return provider.allExercises.firstWhere(
      (exercise) => exercise.id == _currentExercise.exerciseId,
      orElse: () => ExerciseModel(
        id: _currentExercise.exerciseId,
        name: _currentExercise.exerciseName,
        muscleGroup: _currentExercise.muscleGroup,
        description: 'Treino funcional para ${_currentExercise.muscleGroup}.',
        instructions: const ['Execução controlada', 'Mantenha postura estável'],
        primaryMuscle: _currentExercise.muscleGroup,
        secondaryMuscles: const ['Core'],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _restSeconds = _currentExercise.restTimeSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startRestTimer({int? customSeconds}) {
    final seconds = customSeconds ?? _currentExercise.restTimeSeconds;
    _timer?.cancel();
    setState(() {
      _restSeconds = seconds;
      _timerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restSeconds <= 1) {
        timer.cancel();
        setState(() {
          _restSeconds = 0;
          _timerRunning = false;
        });
        return;
      }
      setState(() => _restSeconds--);
    });
  }

  void _toggleRest() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
      return;
    }
    _startRestTimer();
  }

  void _concludeSeries() {
    final current = _currentExercise;
    if (_currentSet < current.sets) {
      setState(() {
        _currentSet++;
      });
      _startRestTimer(customSeconds: current.restTimeSeconds);
      return;
    }

    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _selectedTabIndex = 0;
        _restSeconds =
            widget.workout.exercises[_currentExerciseIndex].restTimeSeconds;
      });
      _timer?.cancel();
      setState(() => _timerRunning = false);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Treino concluído!'),
        content: const Text('Parabéns, você finalizou o treino com sucesso.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateExerciseValue(String field, String value) {
    final exercise = widget.workout.exercises[_currentExerciseIndex];
    switch (field) {
      case 'weight':
        exercise.weight = double.tryParse(value) ?? exercise.weight;
        break;
      case 'reps':
        exercise.reps = int.tryParse(value) ?? exercise.reps;
        break;
      case 'rest':
        exercise.restTimeSeconds =
            int.tryParse(value) ?? exercise.restTimeSeconds;
        _restSeconds = exercise.restTimeSeconds;
        break;
      case 'notes':
        exercise.notes = value;
        break;
    }
    setState(() {});
  }

  Widget _buildTabContent(BuildContext context) {
    final details = _exerciseDetails(context);
    final primary = Theme.of(context).primaryColor;

    switch (_selectedTab) {
      case WorkoutExecutionTab.exercises:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercício ${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _currentExercise.exerciseName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(_currentExercise.muscleGroup),
                  avatar: const Icon(Icons.fitness_center, size: 16),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Série $_currentSet/${_currentExercise.sets}'),
                  avatar: const Icon(Icons.repeat, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _currentExercise.weight == 0
                                ? ''
                                : _currentExercise.weight.toStringAsFixed(1),
                            onChanged: (value) =>
                                _updateExerciseValue('weight', value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _currentExercise.reps.toString(),
                            onChanged: (value) =>
                                _updateExerciseValue('reps', value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _currentExercise.notes,
                      onChanged: (value) =>
                          _updateExerciseValue('notes', value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _concludeSeries,
                      icon: Icon(_continueButtonIcon),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Text(
                          _continueButtonLabel,
                          key: ValueKey(_continueButtonLabel),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case WorkoutExecutionTab.muscles:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details != null) ...[
              Text(
                'Músculos trabalhados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...details.primaryMuscle
                      .split(',')
                      .map((item) => Chip(label: Text(item.trim()))),
                  ...details.secondaryMuscles
                      .map((item) => Chip(label: Text(item))),
                ],
              ),
            ] else
              const Text('Nenhuma informação do músculo disponível.'),
          ],
        );
      case WorkoutExecutionTab.tips:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dicas e instruções',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (details != null)
              ...details.instructions.map(
                (instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(instruction)),
                    ],
                  ),
                ),
              )
            else
              const Text('Sem instruções detalhadas para este exercício.'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final details = _exerciseDetails(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          IconButton(
            icon: Icon(_timerRunning ? Icons.pause_circle : Icons.timer),
            onPressed: _toggleRest,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentExerciseIndex + 1) /
                    widget.workout.exercises.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      'Descanso',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_restSeconds),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 180,
                      child: ElevatedButton.icon(
                        onPressed: _toggleRest,
                        icon: Icon(
                            _timerRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_timerRunning ? 'Pausar' : 'Iniciar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Exercícios')),
                        ButtonSegment(value: 1, label: Text('Músculos')),
                        ButtonSegment(value: 2, label: Text('Dicas')),
                      ],
                      selected: {_selectedTabIndex},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedTabIndex = selection.first);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_currentExerciseIndex),
                    child: _buildTabContent(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (details != null)
                Text(
                  details.description,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
