import 'package:entrenados/widgets/header.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isAppTitle: false,titleText: "Actividad"),
      body: Text("Notificaciones"),
    );
  }
}