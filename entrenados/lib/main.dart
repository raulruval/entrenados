import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/home.dart';
import 'package:flutter/material.dart';

void main(){
   runApp(MyApp());
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then( (_) {
    print("Timestamps funcionando");
  }, onError: (_) {
    print("Timestamps no funcionan");
  });
} 

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entrenados',
      theme: ThemeData(
        fontFamily: 'Open Sans',
        primarySwatch: Colors.teal
      ),
      home: Home(),
      
      
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
