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
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

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
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  User user;
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

  buildForm() {
    return Form(
      key: _formKey,
      child: Column(
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
          TextFormField(
            autovalidate: true,
            controller: displayNameController,
            decoration: InputDecoration(
              hintText: "Actualiza tu nombre",
            ),
            validator: (val) {
              if (val.trim().length < 3 || val.isEmpty) {
                return "Nombre demasiado corto";
              } else if (val.trim().length > 20) {
                return "Nombre demasiado largo";
              } else {
                return null;
              }
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Ciudad",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          TextFormField(
            autovalidate: true,
            controller: bioController,
            decoration: InputDecoration(
              hintText: "Actualiza tu localización",
            ),
            validator: (val) {
              if (val.trim().length > 20) {
                return "Localización demasiado larga";
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    var userId = user.id;
    final compressedImageFile = File('$path/img_$userId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 65));
    setState(() {
      _image = compressedImageFile;
    });
  }

  Future updateProfileData(BuildContext context) async {
    String fileName;
    String url;
    if (_image != null) {
      await compressImage();
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
        // print("Error subiendo la foto");
      }
    }

    setState(() {
      _formKey.currentState.save();
    });

    if (_formKey.currentState.validate() && _image != null) {
      usersRef.document(widget.currentUserId).updateData({
        "photoUrl": url,
        "displayName": displayNameController.text.toUpperCase(),
        "bio": bioController.text
      });
    } else if (_formKey.currentState.validate()) {
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text.toUpperCase(),
        "bio": bioController.text
      });
    }
    if (_formKey.currentState.validate()) {
      SnackBar snackbar = SnackBar(
        content: Text("Perfil actualizado"),
      );

      _scaffoldKey.currentState.showSnackBar(snackbar);

      fileName = null;
    }
  }

  logout() async {
    await FirebaseAuth.instance
        .signOut()
        .catchError((onError) => print(onError));

    googleSignIn.signOut();

    Navigator.push(
        this.context, MaterialPageRoute(builder: (context) => Home(true)));
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
      backgroundColor: Colors.grey[300],
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          "Editar Perfil",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                size: 30,
                color: Colors.white,
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
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              user.photoUrl,
                                              fit: BoxFit.cover,
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
                              buildForm(),
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
