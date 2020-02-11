import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/usuario.dart';
import 'package:entrenados/widgets/progreso.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';

class Compartir extends StatefulWidget {
  final Usuario currentUser;

  Compartir({this.currentUser});
  @override
  _CompartirState createState() => _CompartirState();
}

class _CompartirState extends State<Compartir> {
  TextEditingController captionController = TextEditingController();

  TextEditingController nombreController = TextEditingController();
  TextEditingController duracionController = TextEditingController();

  Duration resultingDuration = new Duration(hours:0, minutes:30, seconds:0);
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleGaleria() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handleCamara() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handleDefecto() {
    Navigator.pop(context);
    File file = new File("assets/img/share.jpg");
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Subir imagen del recurso"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Realizar foto para la imagen"),
                onPressed: handleCamara,
              ),
              SimpleDialogOption(
                child: Text("Usar imagen de galería"),
                onPressed: handleGaleria,
              ),
              SimpleDialogOption(
                child: Text("Usar una imagen por defecto"),
                onPressed: handleDefecto,
              ),
              SimpleDialogOption(
                child: Text("Cancelar"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildCompartir() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/img/share.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 250.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                "Compartir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50.0,
                ),
              ),
              color: Colors.teal,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildFormularioCompartir() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: clearImage,
          ),
          title: Text(
            "Compartir Post",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            FlatButton(
              onPressed: isUploading
                  ? null
                  : () => print("subiendo"), //handleSubmit(),
              child: Text(
                "Publicar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ]),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 120.0,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  )),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Titulo de la publicación",
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.label,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: nombreController,
                decoration: InputDecoration(
                    hintText: "Nombre del entrenamiento",
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.timer,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: InkWell(
                child: Text("Duración"),
                onTap: () async {
                   resultingDuration = await showDurationPicker(
                    context: context,
                    initialTime: new Duration(minutes: 30),
                  );
                  Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text("Duración escogida: $resultingDuration")));

                },
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.arrow_upward,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                // controller: locationController,
                decoration: InputDecoration(
                    hintText: "Dificultad", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.book,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                // controller: locationController,
                decoration: InputDecoration(
                    hintText: "Grupo", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.directions_run,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                // controller: locationController,
                decoration: InputDecoration(
                    hintText: "Músculos principales involucrados",
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.nature_people,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                // controller: locationController,
                decoration: InputDecoration(
                    hintText: "Equipamiento", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.note,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                // controller: locationController,
                decoration: InputDecoration(
                    hintText: "Notas", border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Subir recurso",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.teal,
              onPressed: () => print("Escoge el recurso"),
              icon: Icon(
                Icons.file_upload,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildCompartir() : buildFormularioCompartir();
  }
}
