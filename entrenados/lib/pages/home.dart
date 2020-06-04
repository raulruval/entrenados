import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/activity.dart';
import 'package:entrenados/pages/profile.dart';
import 'package:entrenados/pages/search.dart';
import 'package:entrenados/pages/share.dart';
import 'package:entrenados/pages/create_account.dart';
import 'package:entrenados/pages/create_google_account.dart';
import 'package:entrenados/pages/timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
bool _newAlert = false;
int _alertCount = 0;

class Home extends StatefulWidget {
  bool logout = false;
  Home(this.logout);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SearchModel sm = new SearchModel();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldKeyNoValidation = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DateTime current;

  @override
  void initState() {
    super.initState();

    pageController = PageController();
    // Detecta cuando un usuario inicia sesión.
    googleSignIn.onCurrentUserChanged.listen((cuenta) {
      handleSignInGoogle(cuenta);
    }, onError: (err) {
      // print('Error al iniciar session: $err');
    });
    // Reautenticar usuario cuando vuelve a reabrir la app y es de Google

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((cuenta) {})
        .catchError((err) {
      // Reautenticar usuario cuando vuelve a reabrir la app y ya está autenticado con el correo
      if (!widget.logout) {
        handleAutomaticSignIn();
      } else {
        resetSharedPreferences();
      }
    });
  }

  resetSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("email", "");
    pref.setString("pass", "");
  }

  handleAutomaticSignIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("email") != "") {
      FirebaseUser fUser = await signIpUser(true);
      if (fUser != null) handleSignIn(true, fUser.uid);
    }
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
      // print("Firebase Messaging token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async{}, // When the app is off.
      // onResume: (Map<String, dynamic> message) async{}, // App Launch but in the background
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _alertCount++;
          _newAlert = true;
        });
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

  Future signIpUser(bool auto) async {
    if (!auto) {
      FirebaseUser fUser = await _auth
          .signInWithEmailAndPassword(email: _email, password: _pwd)
          .catchError((onError) => {
                _scaffoldKeyNoValidation.currentState.showSnackBar(SnackBar(
                  content: AutoSizeText(
                    "El email y contraseña introducidos no coindicen con ninguno de nuestros usuarios.",
                    maxLines: 2,
                  ),
                ))
              });
      if (!fUser.isEmailVerified) {
        fUser.sendEmailVerification();
      }
      return fUser;
    } else {
      SharedPreferences pref = await SharedPreferences.getInstance();
      _email = pref.getString("email");
      _pwd = pref.getString("pass");
      FirebaseUser fUser = await _auth
          .signInWithEmailAndPassword(email: _email, password: _pwd)
          .catchError((onError) => {print("error")});
      return fUser;
    }
  }

  handleSignIn(bool auto, String uidAuto) async {
    FirebaseUser fUser;
    bool userVerify = false;
    if (!auto) {
      fUser = await signIpUser(false);
      await usersRef
          .document(fUser.uid)
          .get()
          .then((doc) => currentUser = User.fromDocument(doc));
      // .catchError((onError) => print(onError));
    } else {
      await usersRef
          .document(uidAuto)
          .get()
          .then((doc) => currentUser = User.fromDocument(doc));
      // .catchError((onError) => print(onError));
    }
    try {
      userVerify = fUser.isEmailVerified;
    } catch (ex) {
      // print(ex);
    }
    if (auto) userVerify = true;
    if (currentUser != null && userVerify) {
      if (currentUser.username == "") {
        final username = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateGoogleAccount()));
        usersRef.document(currentUser.id).updateData({'username': username});
      }
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (!auto) {
        setState(() {
          pref.setString("email", _email);
          pref.setString("pass", _pwd);
        });
      }
      setState(() {
        isAuth = true;
      });
      configurePushNotification(false, currentUser);
    } else if (currentUser != null && !auto) {
      _scaffoldKeyNoValidation.currentState.showSnackBar(SnackBar(
        content: AutoSizeText(
          "Por favor, verifique su cuenta de correo electrónico para poder iniciar sesión.",
          maxLines: 2,
        ),
      ));
      setState(() {
        isAuth = false;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createGoogleUserInFirestore() async {
    // 1) Comprueba si el usuario existe en la colección de firebase.
    final GoogleSignInAccount user = googleSignIn.currentUser;
    final GoogleSignInAuthentication googleAuth = await user.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _auth.signInWithCredential(credential);

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
    /*    pageController.jumpToPage(pageIndex);
 */
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 10), curve: Curves.easeIn);
    if (pageIndex == 3) {
      _newAlert = false;
      _alertCount = 0;
    }
  }

  Scaffold buildValidationScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          Search(searchModel: sm),
          Share(currentUser: currentUser, searchModel: sm),
          Activity(),
          Profile(
            profileId: currentUser.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: SnakeNavigationBar(
        snakeShape: SnakeShape.circle,
        style: SnakeBarStyle.pinned,
        currentIndex: pageIndex,
        padding: EdgeInsets.all(4),
        onPositionChanged: onTap,
        snakeGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.teal[400], Colors.deepPurple[400]]),
        items: [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.home)),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.search)),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.plus, size: 30)),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                _newAlert
                    ? Icon(
                        Icons.notifications,
                        size: 30,
                      )
                    : Icon(
                        Icons.notifications_none,
                        size: 30,
                      ),
                _newAlert
                    ? Positioned(
                        top: -3.0,
                        right: -1.0,
                        child: new Text(
                          "$_alertCount",
                          style: new TextStyle(
                              fontSize: 9.0, fontWeight: FontWeight.bold),
                        ))
                    : SizedBox.shrink(),
              ],
            ),
          ),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.userAlt))
        ],
      ),
    );
  }

  final kHintTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Colors.teal[600],
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

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

  handleForgotPwd() async {
    if (_email == null) {
      _scaffoldKeyNoValidation.currentState.showSnackBar(SnackBar(
        content: AutoSizeText(
          "Por favor, introduce el correo electrónico y pulsa 'Cambiar contraseña'.",
          maxLines: 2,
        ),
      ));
    } else {
      await _auth
          .sendPasswordResetEmail(email: _email)
          .then((_) => {
                _scaffoldKeyNoValidation.currentState.showSnackBar(SnackBar(
                  content: AutoSizeText(
                    "Se ha envíado un enlace para resetear la contraseña a $_email",
                    maxLines: 2,
                  ),
                ))
              })
          .catchError((error) {
        _scaffoldKeyNoValidation.currentState.showSnackBar(SnackBar(
          content: AutoSizeText(
            "Lo sentimos, el email $_email no está registrado en la aplicación.",
            maxLines: 2,
          ),
        ));
      });
    }
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: () => handleForgotPwd(),
        child: Text(
          'Cambiar contraseña',
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('¿No tienes una cuenta? '),
          Padding(
            padding: EdgeInsets.all(8),
          ),
          Text(
            ' ¡Regístrate!',
            style: kLabelStyle,
          ),
        ]),
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
            child: new Image.asset(
              'assets/img/GoogleIcon.png',
              height: 35.0,
            ),
          ),
          Flexible(
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Scaffold buildNoValidationScreen() {
    return Scaffold(
      key: _scaffoldKeyNoValidation,
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
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.teal[400],
                        Colors.deepPurple[200]
                      ]),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 80.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          child: new Image.asset(
                        'assets/img/run.png',
                        height: 200.0,
                        width: 200.0,
                      )),
                      AutoSizeText(
                        'Entrenados',
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Manrope',
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
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

  Future<bool> exitWarning() {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current) > Duration(seconds: 2)) {
      current = now;
      SnackBar snackbar = SnackBar(
        content: Text("Si deseas salir de la aplicación pulsa de nuevo atrás"),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isAuth
        ? WillPopScope(
            child: buildValidationScreen(), onWillPop: () => exitWarning())
        : buildNoValidationScreen();
  }
}
