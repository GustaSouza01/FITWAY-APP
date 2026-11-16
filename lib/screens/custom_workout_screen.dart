import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../provider/workout_provider.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key});

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final _nameController = TextEditingController();
  final List<WorkoutExerciseConfig> _selectedExercises = [];
  String _searchQuery = '';
  String _filterMuscle = 'Todos';
  final List<String> _muscleFilters = [
    'Todos',
    'Peito',
    'Costas',
    'Ombros',
    'Bíceps',
    'Tríceps',
    'Quadríceps',
    'Posterior',
    'Glúteos',
    'Panturrilha',
    'Abdômen',
    'Cardio',
  ];

  void _addExercise(ExerciseModel ex) {
    setState(() {
      _selectedExercises.add(WorkoutExerciseConfig(
        exerciseId: ex.id,
        exerciseName: ex.name,
        muscleGroup: ex.muscleGroup,
      ));
    });
    Navigator.pop(context);
  }

  void _showExercisePicker(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          final filtered = provider.allExercises.where((e) {
            final matchesSearch =
                e.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesMuscle =
                _filterMuscle == 'Todos' || e.muscleGroup == _filterMuscle;
            return matchesSearch && matchesMuscle;
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Adicionar Exercício',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _muscleFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final value = _muscleFilters[index];
                      final selected = _filterMuscle == value;
                      return ChoiceChip(
                        label: Text(value),
                        selected: selected,
                        onSelected: (_) =>
                            setModalState(() => _filterMuscle = value),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search)),
                  onChanged: (v) => setModalState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return ListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.muscleGroup),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => _addExercise(ex),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _save() async {
    if (_nameController.text.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Informe o nome do treino e adicione pelo menos um exercício.')),
      );
      return;
    }

    final workout = WorkoutModel(
      id: const Uuid().v4(),
      name: _nameController.text,
      exercises: _selectedExercises,
      isCustom: true,
    );

    await Provider.of<WorkoutProvider>(context, listen: false)
        .saveWorkout(workout);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')));
    _nameController.clear();
    setState(() => _selectedExercises.clear());
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Do Seu Jeito - Criar Treino')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Nome do Treino Personalizado',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48)),
              onPressed: () => _showExercisePicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Exercícios'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _selectedExercises.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _selectedExercises.removeAt(oldIndex);
                    _selectedExercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final item = _selectedExercises[index];
                  return Card(
                    key: ValueKey(item.exerciseId + index.toString()),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.exerciseName),
                      subtitle: Text(
                          '${item.sets} séries x ${item.reps} repetições | ${item.weight} kg'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            setState(() => _selectedExercises.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50)),
              onPressed: _save,
              child: const Text('Salvar Treino',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
