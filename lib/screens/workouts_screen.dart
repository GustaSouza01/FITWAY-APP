import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/workout_provider.dart';
import 'workout_execution_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final groups = {
      'Hipertrofia': provider.presetWorkouts
          .where((w) => w.name.startsWith('Hipertrofia'))
          .toList(),
      'Emagrecimento': provider.presetWorkouts
          .where((w) => w.name.startsWith('Emagrecimento'))
          .toList(),
      'Mobilidade': provider.presetWorkouts
          .where((w) => w.name.startsWith('Mobilidade'))
          .toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Banco de Treinos & Exercícios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groups.entries.map((entry) {
          final title = entry.key;
          final workouts = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${workouts.length} dias de treino'),
              children: workouts
                  .map((workout) => ListTile(
                        title: Text(workout.name),
                        subtitle: Text('${workout.exercises.length} exercícios'),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutExecutionScreen(workout: workout),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
