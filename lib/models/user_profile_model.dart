class MonthlyProgressEntry {
  final String month;
  final double weight;
  final double bmi;
  final double bodyEvolution;

  const MonthlyProgressEntry({
    required this.month,
    required this.weight,
    required this.bmi,
    required this.bodyEvolution,
  });

  Map<String, dynamic> toJson() => {
        'month': month,
        'weight': weight,
        'bmi': bmi,
        'bodyEvolution': bodyEvolution,
      };

  factory MonthlyProgressEntry.fromJson(Map<String, dynamic> json) =>
      MonthlyProgressEntry(
        month: json['month'] ?? '',
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
        bodyEvolution: (json['bodyEvolution'] as num?)?.toDouble() ?? 0.0,
      );
}

class UserProfileModel {
  String name;
  String email;
  double height;
  double weight;
  int age;
  String sex;
  String objective;
  String level;
  List<MonthlyProgressEntry> monthlyHistory;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    this.age = 28,
    this.sex = 'Masculino',
    required this.objective,
    required this.level,
    List<MonthlyProgressEntry>? monthlyHistory,
  }) : monthlyHistory = monthlyHistory ?? const [];

  double get bmi => height > 0 ? weight / (height * height) : 0.0;

  String get bmiClassification {
    final value = bmi;
    if (value < 18.5) return 'Abaixo do peso';
    if (value < 25) return 'Saudável';
    if (value < 30) return 'Sobrepeso';
    if (value < 35) return 'Obesidade I';
    if (value < 40) return 'Obesidade II';
    return 'Obesidade III';
  }

  static List<MonthlyProgressEntry> buildDefaultHistory(
      double weight, double height) {
    final now = DateTime.now();
    final baseWeight = weight > 0 ? weight : 75.0;
    final List<MonthlyProgressEntry> history = [];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final offset = 5 - i;
      final monthWeight = (baseWeight - (offset * 0.6)).clamp(45.0, 180.0);
      final monthBmi = height > 0 ? monthWeight / (height * height) : 0.0;
      history.add(
        MonthlyProgressEntry(
          month: _monthLabel(date.month),
          weight: monthWeight,
          bmi: monthBmi,
          bodyEvolution: (monthWeight - baseWeight).abs(),
        ),
      );
    }

    return history;
  }

  static String _monthLabel(int month) {
    const labels = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return labels[month - 1];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'height': height,
        'weight': weight,
        'age': age,
        'sex': sex,
        'objective': objective,
        'level': level,
        'monthlyHistory': monthlyHistory.map((e) => e.toJson()).toList(),
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final height = (json['height'] as num?)?.toDouble() ?? 1.75;
    final weight = (json['weight'] as num?)?.toDouble() ?? 75.0;
    final historyList = (json['monthlyHistory'] as List? ?? [])
        .map((e) => MonthlyProgressEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserProfileModel(
      name: json['name'] ?? 'Usuário Fitway',
      email: json['email'] ?? 'usuario@fitway.com',
      height: height,
      weight: weight,
      age: json['age'] ?? 28,
      sex: json['sex'] ?? 'Masculino',
      objective: json['objective'] ?? 'Hipertrofia',
      level: json['level'] ?? 'Intermediário',
      monthlyHistory: historyList.isNotEmpty
          ? historyList
          : buildDefaultHistory(weight, height),
    );
  }
}
