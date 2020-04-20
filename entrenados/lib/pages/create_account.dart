import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  User user = new User();
  String _pwd = "";
  bool oldUser = false;

  Future signUpUser() async {
    FirebaseUser fUser = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: _pwd);
    return fUser.uid;
  }

  Future<void> saveUserOnDb() async {
    usersRef.document(user.id).setData({
      "id": user.id,
      "username": user.username,
      "photoUrl":
          "https://firebasestorage.googleapis.com/v0/b/entrenados-4621b.appspot.com/o/profile.jpg?alt=media&token=26e5503d-53d7-4b3e-8d3a-43a9e4c9f479",
      "email": user.email,
      "displayName": user.displayName,
      "bio": "",
      "timestamp": timestamp,
    });
    // Hacer un usuario su propio seguidor para que le aparezcan en el timeline sus publicaciones.
    await followersRef
        .document(user.id)
        .collection('userFollowers')
        .document(user.id)
        .setData({});
  }

  Future<void> showAlertRegister(String texto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email existente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    texto),
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
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      oldUser = await _checkIfExists(user.username);
      if (oldUser) {
        showAlertRegister('El usuario introducido ya existe, por favor, intentelo de nuevo con uno distinto.');
      } else {
        signUpUser()
            .then((uid) => {user.id = uid.toString()})
            .then((_) => saveUserOnDb())
            .then((_) {
          SnackBar snackbar = SnackBar(
            content: Text("¡Bienvenido!"),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context, user);
          });
        }).catchError((onError) {
          print(onError);
          showAlertRegister('El email introducido ya existe, por favor, intentelo de nuevo con uno distinto.');
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
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: header(
          context,
          titleText: "Configura tu perfil",
          removeBackButton: false,
        ),
        body: ListView(children: <Widget>[
          Container(
              margin: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, right: 30, top: 50.0),
                      child: Container(
                        child: TextFormField(
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Nombre requerido';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => user.displayName = val.trim().toUpperCase(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Nombre",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Nombre que aparecerá en tu perfil",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                      child: Container(
                        child: TextFormField(
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Usuario demasiado corto';
                            } else if (val.trim().length > 10) {
                              return 'Usuario demasiado largo';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => user.username = val.trim(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Usuario",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Nombre por el que serás visible",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                      child: Container(
                        child: TextFormField(
                          validator: (val) {
                            if (!RegExp(
                                    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                .hasMatch(val)) {
                              return 'Por favor, introduce un email valido';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => user.email = val.trim(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Debe tener un formato de email",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          validator: (val) {
                            if (val.trim().length < 6 || val.isEmpty) {
                              return 'Contraseña demasiado corta';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => _pwd = val.trim(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Contraseña",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Deben ser al menos 6 caracteres",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: GestureDetector(
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
                      ),
                    )
                  ],
                ),
              )),
        ]),
      ),
    );
  }
}
