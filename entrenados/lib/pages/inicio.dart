import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();

class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  bool validacion = false;

  @override
  void initState() {
    super.initState();
    // Detecta cuando un usuario inicia sesión.
    googleSignIn.onCurrentUserChanged.listen((cuenta) {
      handleSignIn(cuenta);
    }, onError: (err) {
      print('Error al iniciar session: $err');
    });
    // Reautenticar usuario cuando vuelve a reabrir la app

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((cuenta) {})
        .catchError((err) {
      print('Error al iniciar session: $err');
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      // await crearUsuarioEnFirestore();
      setState(() {
        validacion = true;
      });
      // configurePushNotification();
    } else {
      setState(() {
        validacion = false;
      });
    }
  }

  // crearUsuarioEnFirestore() async{
  //   // 1)Comprueba si el usuario existe en la colección de firebase.
  //   final GoogleSignInAccount user = googleSignIn.currentUser;
  //   DocumentSnapshot doc = await usersRef.document(user.id).get();
  //   // 2) Si el usuario no existe, lo llevamos a la página de crear cuenta(google).
  //   if (!doc.exists) {
  //     final username = await Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => CrearCuenta()));
  //   // 3) Cogemos el nombre del usuario y lo metemos en la colección.
  //    usersRef.document(user.id).setData({
  //       "id": user.id,
  //       "username": username,
  //       "photoUrl": user.photoUrl,
  //       "email": user.email,
  //       "displayName": user.displayName,
  //       "bio": "",
  //       "timestamp": timestamp,
  //     });
  // }
  // }

  Widget buildValiacionScreen() {
    return RaisedButton(
      child: Text('Salir'),
      onPressed: logout,
    );
  }

  Widget _buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Correo electrónico',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Introduce tu correo electrónico',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Contraseña',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Introduce tu contraseña',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: () => print('Botón has olvidado tu contraseña'),
        child: Text(
          '¿Has olvidado tu contraseña?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRegister() {
    return Container(
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: () => print('Botón registrar'),
        child: Text(
          '¿No tienes una cuenta? Regístrate',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => print('Botón de login'),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors
            .white54, // Cambiará a blanco cuando se haya introducido un email y contraseña (Pendiente de hacer)
        child: Text(
          'Acceder con un correo electrónico',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtnGoogle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      child: RaisedButton(
          elevation: 5.0,
          onPressed: () => login(),
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/img/GoogleIcon.png',
                height: 35.0,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 10),
              ),
              Text(
                'Acceder con Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23.0,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          )),
    );
  }

  Scaffold buildNoValiacionScreen() {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[200],
                      Colors.teal[200],
                    ],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          child: new Image.asset(
                        'assets/img/run.png',
                        height: 125.0,
                        width: 125.0,
                      )),
                      Text(
                        'Entrenados',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Open Sans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                      ),
                      _buildLoginBtnGoogle(),
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'O',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildEmail(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildPassword(),
                      _buildLoginBtn(),
                      _buildForgotPasswordBtn(),
                      Divider(
                        color: Colors.black,
                      ),
                      _buildRegister(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return validacion ? buildValiacionScreen() : buildNoValiacionScreen();
  }
}
