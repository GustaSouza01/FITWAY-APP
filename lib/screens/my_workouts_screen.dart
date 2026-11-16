import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/workout_provider.dart';
import 'workout_execution_screen.dart';

class MyWorkoutsScreen extends StatelessWidget {
  const MyWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final workouts = provider.savedWorkouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      body: workouts.isEmpty
          ? const Center(
              child: Text('Nenhum treino personalizado salvo ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(w.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${w.exercises.length} exercícios'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.green),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    WorkoutExecutionScreen(workout: w)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.deleteWorkout(w.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
