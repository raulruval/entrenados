import 'package:flutter/material.dart';

const List<EleccionBusqueda> eb = const <EleccionBusqueda>[
  const EleccionBusqueda(titulo: 'Entrenamientos', icono: Icons.directions_run),
  const EleccionBusqueda(titulo: 'Instructores', icono: Icons.people),
];

class EleccionBusqueda {
  const EleccionBusqueda({this.titulo, this.icono});
  final String titulo;
  final IconData icono;
}
