import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../provider/workout_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _levelController = TextEditingController();
  final _emailController = TextEditingController();
  String _sexValue = 'Masculino';

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _objectiveController.dispose();
    _levelController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncFields(UserProfileModel? user) {
    if (user == null) return;
    _nameController.text = user.name;
    _heightController.text = user.height.toStringAsFixed(2);
    _weightController.text = user.weight.toStringAsFixed(1);
    _ageController.text = user.age.toString();
    _objectiveController.text = user.objective;
    _levelController.text = user.level;
    _emailController.text = user.email;
    _sexValue = user.sex;
  }

  void _buildProfileModel(WorkoutProvider provider) {
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    if (height <= 0 || weight <= 0 || height > 3 || weight > 300) {
      return;
    }

    final updated = UserProfileModel(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Usuário Fitway',
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : 'usuario@fitway.com',
      height: height,
      weight: weight,
      age: int.tryParse(_ageController.text) ?? 28,
      sex: _sexValue,
      objective: _objectiveController.text.trim().isNotEmpty
          ? _objectiveController.text.trim()
          : 'Hipertrofia',
      level: _levelController.text.trim().isNotEmpty
          ? _levelController.text.trim()
          : 'Intermediário',
      monthlyHistory: UserProfileModel.buildDefaultHistory(weight, height),
    );

    provider.updateProfile(updated);
  }

  void _saveProfile(WorkoutProvider provider) {
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    if (height <= 0 || weight <= 0 || height > 3 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Altura e peso devem ser válidos.')),
      );
      return;
    }
    _buildProfileModel(provider);
    setState(() {});
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChart(UserProfileModel user) {
    final history = user.monthlyHistory.isEmpty
        ? UserProfileModel.buildDefaultHistory(user.weight, user.height)
        : user.monthlyHistory;
    final values = history.map((entry) => entry.weight).toList();
    final min = values.reduce((a, b) => a < b ? a : b) * 0.95;
    final max = values.reduce((a, b) => a > b ? a : b) * 1.05;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((entry) {
          final ratio = max > min
              ? ((entry.weight - min) / (max - min)).clamp(0.1, 1.0)
              : 0.5;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 120,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 18,
                        height: 120 * ratio,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.month, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final user = provider.userProfile;
    final primary = Theme.of(context).primaryColor;
    if (user != null) {
      _syncFields(user);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withValues(alpha: 0.16),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.22),
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.person, size: 52, color: primary),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nome'),
                              onChanged: (_) => _buildProfileModel(provider),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'E-mail'),
                              onChanged: (_) => _buildProfileModel(provider),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: 'Altura (m)'),
                                    onChanged: (_) => _buildProfileModel(provider),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: 'Peso (kg)'),
                                    onChanged: (_) => _buildProfileModel(provider),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Idade'),
                                    onChanged: (_) => _buildProfileModel(provider),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _sexValue,
                                    decoration: const InputDecoration(labelText: 'Sexo'),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Masculino',
                                          child: Text('Masculino')),
                                      DropdownMenuItem(
                                          value: 'Feminino',
                                          child: Text('Feminino')),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _sexValue = value ?? 'Masculino');
                                      _buildProfileModel(provider);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _objectiveController,
                              decoration: const InputDecoration(labelText: 'Objetivo'),
                              onChanged: (_) => _buildProfileModel(provider),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _levelController,
                              decoration: const InputDecoration(labelText: 'Nível'),
                              onChanged: (_) => _buildProfileModel(provider),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => _saveProfile(provider),
                                child: const Text('Salvar perfil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Resumo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStat('Altura',
                                        '${user.height.toStringAsFixed(2)} m')),
                                Expanded(
                                    child: _buildStat('Peso',
                                        '${user.weight.toStringAsFixed(1)} kg')),
                                Expanded(
                                    child: _buildStat('IMC', user.bmi.toStringAsFixed(1))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Classificação: ${user.bmiClassification}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Minha saúde',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStat('Proteína',
                                        '${((user.weight * 1.8) / 1).toStringAsFixed(0)} g/dia')),
                                Expanded(
                                    child: _buildStat('Água',
                                        '${(user.weight * 0.035).toStringAsFixed(1)} L/dia')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStat('Creatina',
                                        '${(user.weight * 0.03).toStringAsFixed(1)} g/dia')),
                                Expanded(
                                    child: _buildStat('Calorias',
                                        '${(user.weight * 22 + (user.sex == 'Masculino' ? 300 : 250)).toStringAsFixed(0)} kcal')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Estimativa geral: valores ajustados pela altura, peso, sexo e objetivo.',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Evolução mensal',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            _buildChart(user),
                            const SizedBox(height: 8),
                            Text(
                                'Peso atual: ${user.weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
