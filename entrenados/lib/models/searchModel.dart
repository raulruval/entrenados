import 'package:entrenados/models/item.dart';

class SearchModel {
  String selectedDifficulty = "";
  String selectedDuration = "";
  List<String> selectedGroup = [];
  List<Item> selectedMuscles = [];
  List<Item> selectedEquipment = [];

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

  List<Item> muscles = [
    Item("assets/img/chest.jpg", Muscles.chest, 9, false),
    Item("assets/img/dorsales.jpg", Muscles.dorsal, 10, false),
    Item("assets/img/quadriceps.jpg", Muscles.quadriceps, 7, false),
    Item("assets/img/espalda.jpg", Muscles.back, 3, false),
    Item("assets/img/arm.jpg", Muscles.biceps, 1, false),
    Item("assets/img/triceps.jpg", Muscles.triceps, 5, false),
    Item("assets/img/shoulder.jpg", Muscles.shoulders, 6, false),
    Item("assets/img/isquios.jpg", Muscles.ischia, 12, false),
    Item("assets/img/gluteos.jpg", Muscles.glutes, 11, false),
    Item("assets/img/abs.jpg", Muscles.abs, 4, false),
    Item("assets/img/leg.jpg", Muscles.twins, 2, false),
    Item("assets/img/forearm.jpg", Muscles.forearm, 8, false),
  ];

  List<Item> equipment = [
    Item("assets/img/ball.jpg", EquipmentList.ball, 1, false),
    Item("assets/img/bank.jpg", EquipmentList.bench, 2, false),
    Item("assets/img/dumbell.jpg", EquipmentList.dumbbells, 3, false),
    Item("assets/img/rope.jpg", EquipmentList.rope, 4, false),
    Item("assets/img/sack.jpg", EquipmentList.boxing, 5, false),
    Item("assets/img/yoga.jpg", EquipmentList.mat, 6, false),
    Item("assets/img/box.jpg", EquipmentList.box, 7, false),
    Item("assets/img/resistenceband.jpg", EquipmentList.resistenceband, 8,
        false),
  ];

  getMuscles() {
    return this.muscles;
  }

  getEquipment() {
    return this.equipment;
  }
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
  static const String sixty = "< 60 min";
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
  static const String chest = "Pectoral";
  static const String dorsal = "Dorsal";
  static const String glutes = "Glúteos";
  static const String ischia = "Isquiotibiales";
}

class EquipmentList {
  static const String ball = "Balón";
  static const String bench = "Banco";
  static const String dumbbells = "Mancuernas";
  static const String rope = "Comba";
  static const String boxing = "Saco de boxeo";
  static const String mat = "Estera";
  static const String resistenceband = "Bandas elásticas";
  static const String box = "Caja pliométrica";
}
