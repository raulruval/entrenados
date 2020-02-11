import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/buscar.dart';
import 'package:entrenados/pages/compartir.dart';
import 'package:entrenados/pages/crear_cuenta.dart';
import 'package:entrenados/pages/perfil.dart';
import 'package:entrenados/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:entrenados/pages/actividad.dart';
import 'package:entrenados/pages/tablon.dart';
import 'package:entrenados/models/usuario.dart';
import 'package:entrenados/pages/crear_cuenta_google.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();
Usuario currentUser;
String email;
String pwd;

class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  bool validacion = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detecta cuando un usuario inicia sesión.
    googleSignIn.onCurrentUserChanged.listen((cuenta) {
      handleSignInGoogle(cuenta);
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

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginGoogle() {
    googleSignIn.signIn();
  }

  logoutGoogle() {
    googleSignIn.signOut();
    logout();
  }
    logout() {
    setState(() {
       validacion=false;
    });
   
  }


  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  handleSignInGoogle(GoogleSignInAccount account) async {
    if (account != null) {
      crearUsuarioGoogleEnFirestore();
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
  bool buscarUsuarioEnFirestore(String email, String pwd){

    return true;
  }
  handleSignIn(String email, String pwd) async {
    bool encontrado = buscarUsuarioEnFirestore(email,pwd);
    if (encontrado) {
            setState(() {
              validacion = true;
            });
            // configurePushNotification();
          } else {
            setState(() {
              validacion = false;
              /// Retornar mensaje de inicio invalido.
            });
          }
        }
      
        crearUsuarioGoogleEnFirestore() async {
          // 1) Comprueba si el usuario existe en la colección de firebase.
          final GoogleSignInAccount user = googleSignIn.currentUser;
          DocumentSnapshot doc = await usersRef.document(user.id).get();
          // 2) Si el usuario no existe, lo llevamos a la página de crear cuenta(google).
          if (!doc.exists) {
            final username = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => CrearCuentaGoogle()));
            // 3) Cogemos el nombre del usuario y lo metemos en la colección junto con la información de Google.
            usersRef.document(user.id).setData({
              "id": user.id,
              "username": username,
              "photoUrl": user.photoUrl,
              "email": user.email,
              "displayName": user.displayName,
              "bio": "",
              "timestamp": timestamp,
              "pwd": null,
            });
            doc = await usersRef.document(user.id).get();
          }
          currentUser = Usuario.fromDocument(doc);
        }
      
        crearUsuarioEnFirestore() async {
          // 1) llevamos al  la página de crear cuenta.
          final Usuario user = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => CrearCuenta()));
          // 2) Cogemos el nombre del usuario y lo metemos en la colección junto con la información de Google.
          usersRef.document(user.id).setData({
            "id": user.id,
            "username": user.username,
            "photoUrl": user.photoUrl,
            "email": user.email,
            "displayName": user.displayName,
            "bio": "",
            "timestamp": timestamp,
            "pwd": user.pwd,
          });
      
          DocumentSnapshot doc = await usersRef.document(user.id).get();
          doc = await usersRef.document(user.id).get();
          currentUser = Usuario.fromDocument(doc);
        }
      
        onTap(int pageIndex) {
          pageController.animateToPage(
            pageIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      
        Widget buildValiacionScreen() {
          return Scaffold(
            body: PageView(
              children: <Widget>[
                // Tablon(),
                RaisedButton(
                  child: Text('Logout'),
                  onPressed: logoutGoogle,
                ),
                Actividad(),
                Compartir(),
                Buscar(),
                Perfil(),
              ],
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: CupertinoTabBar(
              currentIndex: pageIndex,
              onTap: onTap,
              activeColor: Theme.of(context).primaryColor,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
                BottomNavigationBarItem(
                    icon: Icon(
                  Icons.photo_camera,
                  size: 35.0,
                )),
                BottomNavigationBarItem(icon: Icon(Icons.search)),
                BottomNavigationBarItem(icon: Icon(Icons.account_circle))
              ],
            ),
          );
        }
      
        Widget _buildEmail() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              onPressed: () => crearUsuarioEnFirestore(),
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
              onPressed: () => handleSignIn(email,pwd),
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
                onPressed: () => loginGoogle(),
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
