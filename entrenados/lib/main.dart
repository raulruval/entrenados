import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:entrenados/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

void main() {
  
  runApp(DevicePreview(enabled: false, builder: (context) => MyApp()));
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    // print("Timestamps funcionando");
  }, onError: (_) {
    // print("Timestamps no funcionan");
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder,
      title: 'Entrenados',
      theme: ThemeData(fontFamily: 'Manrope', primarySwatch: Colors.teal),
      home: Home(false),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
