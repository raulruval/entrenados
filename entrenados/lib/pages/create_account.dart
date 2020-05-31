import 'dart:async';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_svg/svg.dart';

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
    fUser.sendEmailVerification();
    return fUser.uid;
  }

  Future<void> saveUserOnDb() async {
    usersRef.document(user.id).setData({
      "id": user.id,
      "username": "",
      "photoUrl":
          "https://firebasestorage.googleapis.com/v0/b/entrenados-4621b.appspot.com/o/male.svg?alt=media&token=08fb96de-51d5-4e3a-b04a-aa52e6d21f9d",
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
    return showAnimatedDialog<void>(
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email existente'),
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
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      signUpUser()
          .then((uid) => {user.id = uid.toString()})
          .then((_) => saveUserOnDb())
          .then((_) {
        SnackBar snackbar = SnackBar(
          content: Text(
              "¡Bienvenido! Por favor, verifique su cuenta de correo electrónico para poder iniciar sesión."),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
        Timer(Duration(seconds: 3), () {
          Navigator.pop(context, user);
        });
      }).catchError((onError) {
        // print(onError);
        showAlertRegister(
            'El email introducido ya existe, por favor, intentelo de nuevo con uno distinto.');
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
        removeBackButton: true,
      ),
      body: ListView(children: <Widget>[
        Container(
            margin: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Center(
                          child: SvgPicture.asset(
                            'assets/img/start.svg',
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                        )
                      : SizedBox.shrink(),
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
                        onSaved: (val) =>
                            user.displayName = val.trim().toUpperCase(),
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
                          if (!RegExp(
                                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                              .hasMatch(val)) {
                            return 'Por favor, introduce un email válido';
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
                    padding: EdgeInsets.only(left: 30.0, right: 30, top: 10.0),
                    child: Container(
                      child: TextFormField(
                        obscureText: true,
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
    );
  }
}
