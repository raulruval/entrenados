import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:flutter/material.dart';

 final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
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