import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    
    elevation: 0.0,
    bottomOpacity: 0.0,
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: AutoSizeText(
          isAppTitle ? 'Entrenados' : titleText,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isAppTitle ? "Viga" : "default",
            fontSize: isAppTitle ? 50.0 : 22.0,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ) ??
        'Defecto',
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: <Color>[Colors.teal[600], Colors.deepPurple[400]])),
    ),
  );
}
