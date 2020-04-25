import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/search.dart';
import 'package:entrenados/pages/share.dart';
import 'package:entrenados/pages/create_account.dart';
import 'package:entrenados/pages/create_google_account.dart';
import 'package:entrenados/pages/timeline.dart';
import 'package:entrenados/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/models/searchModel.dart';

import 'mypage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection("users");
final postsRef = Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection("comments");
final activityFeedRef = Firestore.instance.collection("feed");
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final timelineRef = Firestore.instance.collection("timeline");
final storedPostsRef = Firestore.instance.collection("storedPosts");

final DateTime timestamp = DateTime.now();

User currentUser;
String _email;
String _pwd;
bool _log = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SearchModel sm = new SearchModel();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
    // Reautenticar usuario cuando vuelve a reabrir la app y es de Google

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((cuenta) {})
        .catchError((err) {
      print('Error al iniciar session automáticamente: $err');
    });

    // Reautenticar usuario cuando vuelve a reabrir la app y ya está autenticado con el correo

    _auth.onAuthStateChanged
        .listen((fUser) => {if (fUser != null) handleSignIn(true, fUser.uid)})
        .onError((_) => print("No se puede iniciar sesión automáticamente"));
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
      isAuth = false;
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  handleSignInGoogle(GoogleSignInAccount account) async {
    if (account != null) {
      await createGoogleUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotification(true, null);
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotification(bool fromGoogle, User fUser) {
    if (Platform.isIOS) getIosPermission();

    var user;

    if (fromGoogle) {
      user = googleSignIn.currentUser;
    } else {
      user = fUser;
    }

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async{}, // When the app is off.
      // onResume: (Map<String, dynamic> message) async{}, // App Launch but in the background
      onMessage: (Map<String, dynamic> message) async {
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          SnackBar snackBar = SnackBar(
            content: Text(
              body,
              overflow: TextOverflow.ellipsis,
            ),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  getIosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(alert: true, badge: true, sound: true),
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  Future<void> showAlertNoValid() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Credenciales incorrectos'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'El email y contraseña introducidos no coindicen con ninguno de nuestros usuarios'),
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

  Future signIpUser() async {
    FirebaseUser fUser = await _auth
        .signInWithEmailAndPassword(email: _email, password: _pwd)
        .catchError((onError) => {showAlertNoValid()});

    return fUser.uid;
  }

  handleSignIn(bool auto, String uidAuto) async {
    if (!auto) {
      String uid = await signIpUser();
      await usersRef
          .document(uid)
          .get()
          .then((doc) => currentUser = User.fromDocument(doc))
          .catchError((onError) => print(onError));
    } else {
      await usersRef
          .document(uidAuto)
          .get()
          .then((doc) => currentUser = User.fromDocument(doc))
          .catchError((onError) => print(onError));
    }

    if (currentUser != null) {
      setState(() {
        isAuth = true;
      });
      configurePushNotification(false, currentUser);
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createGoogleUserInFirestore() async {
    // 1) Comprueba si el usuario existe en la colección de firebase.
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    // 2) Si el usuario no existe, lo llevamos a la página de crear cuenta(google).
    if (!doc.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateGoogleAccount()));
      // 3) Cogemos el nombre del usuario y lo metemos en la colección junto con la información de Google.
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName.toUpperCase(),
        "bio": "",
        "timestamp": timestamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  createUserInFirestore() async {
    final User user = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateAccount()));
    // Introduce the new user as the currentUser
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    doc = await usersRef.document(user.id).get();
    currentUser = User.fromDocument(doc);
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
          Timeline(currentUser: currentUser),
          Search(searchModel: sm),
          Share(currentUser: currentUser, searchModel: sm),
          MyPage(profileId: currentUser?.id),
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
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle))
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _scaffoldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 50.0,
            child: TextFormField(
              validator: (val) =>
                  val.isEmpty ? "Introduce una email válido" : null,
              onChanged: (val) {
                setState(() => _email = val);
              },
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
                hintText: 'Correo electrónico',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 50.0,
            child: TextFormField(
              validator: (val) => val.isEmpty
                  ? "Introduce una contraseña al menos de 6 caracteres"
                  : null,
              onChanged: (val) {
                setState(() => _pwd = val);
                _log = true;
              },
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
                hintText: 'Contraseña',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            width: double.infinity,
            child: RaisedButton(
              elevation: 5.0,
              onPressed: () => _log ? handleSignIn(false, "") : "",
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: !_log ? Colors.white54 : Colors.white,
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
          )
        ],
      ),
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
        onPressed: () => createUserInFirestore(),
        child: Text(
          '¿No tienes una cuenta? Regístrate',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildLoginBtnGoogle() {
    return RaisedButton(
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
          Container(
            width: MediaQuery.of(context).size.width * 0.1,
            child: new Image.asset(
              'assets/img/GoogleIcon.png',
              height: 35.0,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Padding(
              padding: EdgeInsets.only(left: 3.0),
              child: AutoSizeText(
                'Acceder con Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23.0,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
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
                      _buildForm(),
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
    return isAuth ? buildValiacionScreen() : buildNoValiacionScreen();
  }
}
