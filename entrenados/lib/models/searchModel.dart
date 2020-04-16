class SearchModel {
  String selectedDifficulty = "";
  String selectedDuration = "";
    List<String> selectedGroup = [];

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
