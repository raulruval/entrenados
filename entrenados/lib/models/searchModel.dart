class SearchModel {
  String selectedDifficulty = "";
  String selectedDuration = "";
  List<String> selectedGroup = [];
  List<String> selectedMuscles = [];
  List<String> selectedEquipment = [];

  List<String> difficulty = [
    Difficulty.pricipiante,
    Difficulty.intermedio,
    Difficulty.avanzado,
  ];
  List<String> durationWorkout = [
    DurationWorkout.five,
    DurationWorkout.ten,
    DurationWorkout.twenty,
    DurationWorkout.thirty,
    DurationWorkout.fortyfive,
    DurationWorkout.sixty,
  ];

  List<String> group = [
    Group.resistence,
    Group.mobility,
    Group.strength,
    Group.yoga,
    Group.pilates,
    Group.hiit,
  ];

  List<String> muscles = [
    Muscles.abs,
    Muscles.back,
    Muscles.biceps,
    Muscles.forearm,
    Muscles.quadriceps,
    Muscles.shoulders,
    Muscles.triceps,
    Muscles.twins
  ];
  List<String> equipment = [
    EquipmentList.ball,
    EquipmentList.bench,
    EquipmentList.boxing,
    EquipmentList.dumbbells,
    EquipmentList.mat,
    EquipmentList.rope,
  ];
}

class Difficulty {
  static const String pricipiante = "Principiante";
  static const String intermedio = "Intermedio";
  static const String avanzado = "Avanzado";
}

class DurationWorkout {
  static const String five = "<   5 min";
  static const String ten = "< 10 min";
  static const String twenty = "< 20 min";
  static const String thirty = "< 30 min";
  static const String fortyfive = "< 45 min";
  static const String sixty = "> 60 min";
}

class Group {
  static const String resistence = "Resistencia";
  static const String mobility = "Movilidad";
  static const String strength = "Fuerza";
  static const String yoga = "Yoga";
  static const String pilates = "Pilates";
  static const String hiit = "HIIT";
}

class Muscles {
  static const String biceps = "Bíceps";
  static const String twins = "Gemelos";
  static const String back = "Espalda";
  static const String abs = "Abdominales";
  static const String triceps = "Tríceps";
  static const String shoulders = "Hombros";
  static const String quadriceps = "Cuádriceps";
  static const String forearm = "Antebrazo";
}

class EquipmentList {
  static const String ball = "Balón";
  static const String bench = "Banco";
  static const String dumbbells = "Mancuernas";
  static const String rope = "Comba";
  static const String boxing = "Saco de boxeo";
  static const String mat = "Estera";
}
