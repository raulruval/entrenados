import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:flutter/material.dart';

 final userRef = Firestore.instance.collection('users');

class Tablon extends StatefulWidget {
  @override
  _TablonState createState() => _TablonState();
}

class _TablonState extends State<Tablon> {
  @override
  void initState() { 
   
    super.initState();
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Text('Tablón'),
    );
  }
}