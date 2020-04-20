import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = true;
  User user;
  bool _bioValid = true;
  bool _displayNameValid = true;
  File _image;
  @override
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName.toUpperCase();
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Nombre",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Actualiza tu nombre",
            errorText: _displayNameValid ? null : "Nombre demasiado corto",
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Actualiza tu bio",
            errorText: _displayNameValid ? null : "Bio demasiado larga",
          ),
        ),
      ],
    );
  }

  Future updateProfileData(BuildContext context) async {
    String fileName;
    String url;
    if (_image != null) {
      try {
        fileName = basename(_image.path);
        StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
        await uploadTask.onComplete;

        url = await FirebaseStorage.instance
            .ref()
            .child(fileName)
            .getDownloadURL();
      } catch (err) {
        print("Error subiendo la foto");
      }
    }
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayNameValid && _bioValid && _image != null) {
      usersRef.document(widget.currentUserId).updateData({
        "photoUrl": url,
        "displayName": displayNameController.text.toUpperCase(),
        "bio": bioController.text
      });
    } else if (_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text.toUpperCase(),
        "bio": bioController.text
      });
    }
    SnackBar snackbar = SnackBar(
      content: Text("Perfil actualizado"),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);

    fileName = null;
  }

  logout() async {
    await FirebaseAuth.instance
        .signOut()
        .catchError((onError) => print(onError));
    googleSignIn.signOut();

    Navigator.push(
        this.context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Editar Perfil",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                size: 30,
                color: Colors.green,
              ),
              onPressed: () => {
                    Navigator.pop(context),
                    _image = null,
                  }),
        ],
      ),
      body: Builder(
        builder: (context) => isLoading
            ? circularProgress()
            : ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: getImage,
                                child: CircleAvatar(
                                  radius: 80.0,
                                  backgroundColor: Colors.teal,
                                  child: ClipOval(
                                    child: new SizedBox(
                                      width: 160,
                                      height: 160,
                                      child: (_image != null)
                                          ? Image.file(
                                              _image,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : Image.network(
                                              user.photoUrl,
                                              fit: BoxFit.fitWidth,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: IconButton(
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      size: 35.0,
                                    ),
                                    onPressed: getImage),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => updateProfileData(context),
                          child: Text(
                            "Actualizar Perfil",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: FlatButton.icon(
                            onPressed: () => logout(),
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Salir",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
