import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/user_profile_model.dart';

class LocalStorage {
  static const String _workoutsKey = 'saved_workouts';
  static const String _profileKey = 'user_profile';
  static const String _cardioHistoryKey = 'cardio_history';

  static Future<List<WorkoutModel>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_workoutsKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => WorkoutModel.fromJson(e)).toList();
  }

  static Future<void> saveWorkouts(List<WorkoutModel> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(workouts.map((e) => e.toJson()).toList());
    await prefs.setString(_workoutsKey, encoded);
  }

  static Future<UserProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_profileKey);
    if (data == null) {
      final profile = UserProfileModel(
        name: 'Carlos Silva',
        email: 'carlos@fitway.com',
        height: 1.78,
        weight: 80.0,
        age: 28,
        sex: 'Masculino',
        objective: 'Hipertrofia',
        level: 'Intermediário',
        monthlyHistory: UserProfileModel.buildDefaultHistory(80.0, 1.78),
      );
      await saveProfile(profile);
      return profile;
    }
    return UserProfileModel.fromJson(jsonDecode(data));
  }

  static Future<void> saveProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<List<Map<String, dynamic>>> getCardioHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cardioHistoryKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveCardioHistory(
      List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardioHistoryKey, jsonEncode(history));
  }

  static List<ExerciseModel> getInitialExercises() {
    List<ExerciseModel> list = [];
    List<Map<String, dynamic>> rawData = [
      {
        "name": "Supino Reto com Barra",
        "group": "Peito",
        "primary": "Peitoral maior",
        "secondary": ["Tríceps", "Ombros"],
        "desc": "Exercício fundamental para desenvolvimento peitoral.",
        "instructions": [
          "Posicione a barra com pegada ampla",
          "Desça controlando",
          "Empurre até extensão completa"
        ]
      },
      {
        "name": "Supino Inclinado com Halteres",
        "group": "Peito",
        "primary": "Peitoral superior",
        "secondary": ["Tríceps", "Ombros"],
        "desc": "Foco na porção superior do peitoral.",
        "instructions": [
          "Banco inclinado entre 30 e 45°",
          "Controle a descida",
          "Retorne sem perder postura"
        ]
      },
      {
        "name": "Crucifixo na Polia",
        "group": "Peito",
        "primary": "Peitoral",
        "secondary": ["Deltoide anterior"],
        "desc": "Isolamento com tensão contínua.",
        "instructions": [
          "Mantenha cotovelos levemente flexionados",
          "Movimento controlado",
          "Feche sem exagerar"
        ]
      },
      {
        "name": "Flexão de Braço",
        "group": "Peito",
        "primary": "Peitoral",
        "secondary": ["Tríceps", "Core"],
        "desc": "Excelente exercício com peso corporal.",
        "instructions": [
          "Corpo alinhado",
          "Desça até o peito",
          "Empurre para cima sem arquejar"
        ]
      },
      {
        "name": "Puxada Alta na Polia",
        "group": "Costas",
        "primary": "Latíssimo do dorso",
        "secondary": ["Bíceps", "Trapézio"],
        "desc": "Desenvolvimento da largura dorsal.",
        "instructions": [
          "Puxada até o peito",
          "Retraia ombros",
          "Desacelere na subida"
        ]
      },
      {
        "name": "Remada Curvada com Barra",
        "group": "Costas",
        "primary": "Trapézio",
        "secondary": ["Latíssimo", "Bíceps"],
        "desc": "Espessura e densidade das costas.",
        "instructions": [
          "Costas retas",
          "Puxar cotovelos para trás",
          "Segurar o core firme"
        ]
      },
      {
        "name": "Remada Baixa",
        "group": "Costas",
        "primary": "Dorsal",
        "secondary": ["Bíceps", "Posterior do ombro"],
        "desc": "Trabalho focado no meio das costas.",
        "instructions": [
          "Puxada com controle",
          "Travar ombros",
          "Elevar a barra sem perder postura"
        ]
      },
      {
        "name": "Barra Fixa",
        "group": "Costas",
        "primary": "Dorsal",
        "secondary": ["Bíceps", "Antebraço"],
        "desc": "Exercício clássico de tração.",
        "instructions": [
          "Puxar até o queixo",
          "Baixar lentamente",
          "Sem balanço"
        ]
      },
      {
        "name": "Desenvolvimento com Halteres",
        "group": "Ombros",
        "primary": "Deltóide medial",
        "secondary": ["Trapézio", "Tríceps"],
        "desc": "Força e volume para os deltóides.",
        "instructions": [
          "Halteres na linha do peito",
          "Eleve sem arquejar",
          "Controle na descida"
        ]
      },
      {
        "name": "Elevação Lateral",
        "group": "Ombros",
        "primary": "Deltóide lateral",
        "secondary": ["Trapézio", "Supra-espinhoso"],
        "desc": "Isolamento do deltóide lateral.",
        "instructions": [
          "Braços levemente flexionados",
          "Elevar até ombros",
          "Descer sem balanço"
        ]
      },
      {
        "name": "Elevação Frontal",
        "group": "Ombros",
        "primary": "Deltóide anterior",
        "secondary": ["Tríceps", "Peitoral"],
        "desc": "Foco na porção anterior.",
        "instructions": [
          "Elevar até ombro",
          "Mantenha coluna neutra",
          "Controle total"
        ]
      },
      {
        "name": "Crucifixo Inverso",
        "group": "Ombros",
        "primary": "Posterior do ombro",
        "secondary": ["Trapézio", "Dorsal"],
        "desc": "Deltóide posterior e postura.",
        "instructions": ["Pés no chão", "Braços abertos", "Retraia ombros"]
      },
      {
        "name": "Rosca Direta com Barra",
        "group": "Bíceps",
        "primary": "Bíceps braquial",
        "secondary": ["Antebraço", "Supinadores"],
        "desc": "Construtor clássico de bíceps.",
        "instructions": [
          "Cotovelos próximos",
          "Elevar até máximo",
          "Descer sem impulso"
        ]
      },
      {
        "name": "Rosca Alternada",
        "group": "Bíceps",
        "primary": "Bíceps",
        "secondary": ["Antebraço", "Supinadores"],
        "desc": "Ênfase na supinação e simetria.",
        "instructions": [
          "Supine ao subir",
          "Desça controlado",
          "Respire de forma estável"
        ]
      },
      {
        "name": "Rosca Martelo",
        "group": "Bíceps",
        "primary": "Braquial",
        "secondary": ["Antebraço", "Bíceps"],
        "desc": "Trabalha braquial e antebraço.",
        "instructions": ["Pegada neutra", "Braços fixos", "Controle completo"]
      },
      {
        "name": "Rosca Concentrada",
        "group": "Bíceps",
        "primary": "Bíceps",
        "secondary": ["Antebraço", "Supinador"],
        "desc": "Pico do bíceps isolado.",
        "instructions": [
          "Braço apoiado",
          "Elevar com foco",
          "Concentre a contração"
        ]
      },
      {
        "name": "Tríceps Testa com Barra W",
        "group": "Tríceps",
        "primary": "Tríceps",
        "secondary": ["Peitoral", "Ombros"],
        "desc": "Massa total para o tríceps.",
        "instructions": [
          "Cotovelos imóveis",
          "Baixe controlado",
          "Extensão completa"
        ]
      },
      {
        "name": "Tríceps na Polia com Corda",
        "group": "Tríceps",
        "primary": "Tríceps",
        "secondary": ["Antebraço", "Core"],
        "desc": "Isolamento excelente.",
        "instructions": [
          "Braços próximos ao corpo",
          "Estique sem vencer",
          "Desacelere na volta"
        ]
      },
      {
        "name": "Tríceps Paralelas",
        "group": "Tríceps",
        "primary": "Tríceps",
        "secondary": ["Peitoral", "Antebraço"],
        "desc": "Composto pesado.",
        "instructions": [
          "Cotovelos junto ao corpo",
          "Baixar com controle",
          "Empurre totalmente"
        ]
      },
      {
        "name": "Mergulho no Banco",
        "group": "Tríceps",
        "primary": "Tríceps",
        "secondary": ["Peitoral", "Ombros"],
        "desc": "Acessível e eficiente.",
        "instructions": [
          "Costas no banco",
          "Descer em linha reta",
          "Voltar sem perder controle"
        ]
      },
      {
        "name": "Agachamento Livre",
        "group": "Quadríceps",
        "primary": "Quadríceps",
        "secondary": ["Glúteos", "Core"],
        "desc": "O rei dos exercícios para pernas.",
        "instructions": [
          "Quadril para trás",
          "Joelhos alinhados",
          "Descer e subir com controle"
        ]
      },
      {
        "name": "Leg Press 45º",
        "group": "Quadríceps",
        "primary": "Quadríceps",
        "secondary": ["Glúteos", "Core"],
        "desc": "Carga alta com segurança.",
        "instructions": [
          "Descida controlada",
          "Joelhos fora da linha",
          "Empurre sem virada de tronco"
        ]
      },
      {
        "name": "Cadeira Extensora",
        "group": "Quadríceps",
        "primary": "Quadríceps",
        "secondary": ["Glúteos", "Core"],
        "desc": "Isolamento de quadríceps.",
        "instructions": ["Assento firme", "Extensão total", "Descer devagar"]
      },
      {
        "name": "Afundo com Halteres",
        "group": "Quadríceps",
        "primary": "Quadríceps",
        "secondary": ["Glúteos", "Core"],
        "desc": "Trabalho unilateral intenso.",
        "instructions": [
          "Pé dianteiro firme",
          "Descer até 90°",
          "Estabilize no retorno"
        ]
      },
      {
        "name": "Mesa Flexora",
        "group": "Posterior",
        "primary": "Isquiotibiais",
        "secondary": ["Glúteos", "Core"],
        "desc": "Isolamento posterior da coxa.",
        "instructions": [
          "Assento confortável",
          "Flexionar até limite",
          "Voltar lento"
        ]
      },
      {
        "name": "Stiff com Barra",
        "group": "Posterior",
        "primary": "Posterior da coxa",
        "secondary": ["Glúteos", "Core"],
        "desc": "Alongamento e força posterior.",
        "instructions": [
          "Costas retas",
          "Flexão de quadril",
          "Alongamento controlado"
        ]
      },
      {
        "name": "Flexor Vertical",
        "group": "Posterior",
        "primary": "Isquiotibiais",
        "secondary": ["Gastrocnêmio", "Core"],
        "desc": "Variação para posteriores.",
        "instructions": [
          "Pernas estendidas",
          "Flexão completa",
          "Retorno controlado"
        ]
      },
      {
        "name": "Elevação Pélvica",
        "group": "Glúteos",
        "primary": "Glúteos",
        "secondary": ["Hamstrings", "Core"],
        "desc": "Máximo recrutamento glúteo.",
        "instructions": ["Pés apoiados", "Elevação total", "Contrair no topo"]
      },
      {
        "name": "Abdução de Quadril",
        "group": "Glúteos",
        "primary": "Glúteos médios",
        "secondary": ["Glúteo mínimo", "Core"],
        "desc": "Glúteo médio e mínimo.",
        "instructions": ["Pés alinhados", "Abduzir sem rotações", "Sem oscilar"]
      },
      {
        "name": "Quatro Apoios na Polia",
        "group": "Glúteos",
        "primary": "Glúteos",
        "secondary": ["Core", "Posterior"],
        "desc": "Isolamento avançado.",
        "instructions": [
          "Quadril alinhado",
          "Puxar com glúteo",
          "Sem inclinar tronco"
        ]
      },
      {
        "name": "Panturrilha em Pé na Máquina",
        "group": "Panturrilha",
        "primary": "Gastrocnêmio",
        "secondary": ["Sóleo", "Core"],
        "desc": "Trabalho de panturrilha com carga controlada.",
        "instructions": [
          "Pés no chão",
          "Elevar até estirar",
          "Descer pausadamente"
        ]
      },
      {
        "name": "Panturrilha Sentado",
        "group": "Panturrilha",
        "primary": "Sóleo",
        "secondary": ["Gastrocnêmio", "Core"],
        "desc": "Isolamento do músculo soleo.",
        "instructions": [
          "Joelho flexionado",
          "Elevar mantendo postura",
          "Descer em ritmo lento"
        ]
      },
      {
        "name": "Abdominal Supra na Mat",
        "group": "Abdômen",
        "primary": "Reto abdominal",
        "secondary": ["Oblíquos", "Core"],
        "desc": "Reto abdominal básico.",
        "instructions": [
          "Costas apoiadas",
          "Elevar tronco",
          "Descer lentamente"
        ]
      },
      {
        "name": "Elevação de Pernas na Barra",
        "group": "Abdômen",
        "primary": "Infra-abdominal",
        "secondary": ["Quadril", "Core"],
        "desc": "Infra abdominal avançado.",
        "instructions": [
          "Pernas estendidas",
          "Elevar sem arquejar",
          "Controle total"
        ]
      },
      {
        "name": "Abdominal Supra na Polia",
        "group": "Abdômen",
        "primary": "Reto abdominal",
        "secondary": ["Oblíquos", "Core"],
        "desc": "Carga progressiva.",
        "instructions": [
          "Puxar com tronco",
          "Sem forçar cervicais",
          "Controle de execução"
        ]
      },
      {
        "name": "Prancha Abdominal",
        "group": "Abdômen",
        "primary": "Core",
        "secondary": ["Glúteos", "Oblíquos"],
        "desc": "Core e estabilização.",
        "instructions": [
          "Linha reta",
          "Abdômen em tensão",
          "Respire sem perder alinhamento"
        ]
      },
      {
        "name": "Esteira (Corrida/Caminhada)",
        "group": "Cardio",
        "primary": "Sistema cardiovascular",
        "secondary": ["Core", "Glúteos"],
        "desc": "Resistência aeróbica.",
        "instructions": [
          "Escolha intensidade adequada",
          "Mantenha cadência",
          "Aqueça e resfrie"
        ]
      },
      {
        "name": "Bicicleta Ergométrica",
        "group": "Cardio",
        "primary": "Cardiorespiratório",
        "secondary": ["Quadríceps", "Glúteos"],
        "desc": "Baixo impacto.",
        "instructions": [
          "Cadência estável",
          "Mantenha postura",
          "Ajuste resistência"
        ]
      },
      {
        "name": "Elíptico",
        "group": "Cardio",
        "primary": "Cardiorespiratório",
        "secondary": ["Pernas", "Core"],
        "desc": "Trabalho corporal completo.",
        "instructions": [
          "Movimento contínuo",
          "Respiração regular",
          "Ajuste para conforto"
        ]
      },
      {
        "name": "Pular Corda",
        "group": "Cardio",
        "primary": "Cardiorespiratório",
        "secondary": ["Pernas", "Core"],
        "desc": "Agilidade e queima calórica.",
        "instructions": [
          "Pés juntos",
          "Saltos curtos",
          "Mantenha ombros relaxados"
        ]
      }
    ];

    for (int i = 0; i < rawData.length; i++) {
      final item = rawData[i];
      list.add(ExerciseModel(
        id: 'ex_${i + 1}',
        name: item['name']!,
        muscleGroup: item['group']!,
        description: item['desc']!,
        instructions: List<String>.from(item['instructions'] as List),
        primaryMuscle: item['primary']!,
        secondaryMuscles: List<String>.from(item['secondary'] as List),
      ));
    }
    return list;
  }
}
