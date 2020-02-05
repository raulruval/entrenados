import 'dart:async';

import 'package:entrenados/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/header.dart';

class CrearCuenta extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CrearCuenta> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _id;
  String _username;
  String _photoURL;
  String _email;
  String _displayName;
  String _pwd;

  submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _id = "0";
      Usuario user = new Usuario(
          id: _id,
          username: _username,
          photoUrl: _photoURL,
          email: _email,
          displayName: _displayName,
          pwd: _pwd);
      SnackBar snackbar = SnackBar(
        content: Text("¡Bienvenido $_username!"),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, user);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
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
                    padding: EdgeInsets.only(left: 30.0, right: 30, top: 50.0),
                    child: Container(
                      child: TextFormField(
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Nombre requerido';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => _displayName = val,
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
                    padding: EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                    child: Container(
                      child: TextFormField(
                        validator: (val) {
                          if (val.trim().length < 3 || val.isEmpty) {
                            return 'Usuario demasiado corto';
                          } else if (val.trim().length > 12) {
                            return 'Usuario demasiado largo';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => _username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Usuario",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Deben ser al menos 3 caracteres",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
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
                        onSaved: (val) => _email = val,
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
                    padding: EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                    child: Container(
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        validator: (val) {
                          if (val.trim().length < 4 || val.isEmpty) {
                            return 'Contraseña demasiado corta';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => _pwd = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Contraseña",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Deben ser al menos 4 caracteres",
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
    );
  }
}
