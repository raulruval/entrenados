import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_svg/svg.dart';

class CreateGoogleAccount extends StatefulWidget {
  @override
  _CreateGoogleAccountState createState() => _CreateGoogleAccountState();
}

class _CreateGoogleAccountState extends State<CreateGoogleAccount> {
  String username;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool oldUser = false;

  Future<void> showAlertRegister(String texto) async {
    return showAnimatedDialog<void>(
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuario existente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(texto),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Volver a intentarlo'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      oldUser = await _checkIfExists(username);
      if (oldUser) {
        showAlertRegister(
            'El usuario introducido ya existe, por favor, intentelo de nuevo con uno distinto.');
      } else {
        SnackBar snackbar = SnackBar(
          content: Text("¡Bienvenido $username!"),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop(username);
        });
      }
    }
  }

  _checkIfExists(String username) async {
    QuerySnapshot query =
        await usersRef.where("username", isEqualTo: username).getDocuments();
    return query.documents.isNotEmpty;
  }

  @override
  Widget build(BuildContext parentContext) {
    return WillPopScope(
          child: Scaffold(
        key: _scaffoldKey,
        appBar: header(
          context,
          titleText: "Configura tu perfil",
          removeBackButton: true,
        ),
        body: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? Center(
                        child: Padding(
                          child: SvgPicture.asset(
                            'assets/img/username.svg',
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                          padding: EdgeInsets.only(top: 20),
                        ),
                      )
                    : SizedBox.shrink(),
                AutoSizeText(
                  "Introduce un nombre de usuario",
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                  maxLines: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        autovalidate: true,
                        validator: (val) {
                          if (val.trim().length < 3 || val.isEmpty) {
                            return 'Usuario demasiado corto';
                          } else if (val.trim().length > 12) {
                            return 'Usuario demasiado largo';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Usuario",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Deben ser al menos 3 caracteres",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ), onWillPop: () async => false
    );
  }
}
