import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/equipment.dart';
import 'package:entrenados/pages/musclesinvolved.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:image/image.dart' as Im;

class Share extends StatefulWidget {
  final User currentUser;

  Share({this.currentUser});
  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share>
    with AutomaticKeepAliveClientMixin<Share> {
  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController duracionController = TextEditingController();
  List<Item> selectedMusclesList = List();
  List<Item> selectedEquipmentList = List();
  String selectedMuscles = "";
  String selectedEquipment = "";
  String mainResource = "";
  List _difficulty = ["Principiante", "Intermedio", "Avanzado"];
  List _group = [
    "Resistencia",
    "Movilidad",
    "Fuerza",
    "Yoga",
    "Pilates",
    "HIIT"
  ];
  String _currentDifficulty;
  String _currentGroup;
  List<DropdownMenuItem<String>> _dropDownMenuItemsDifficulty;
  List<DropdownMenuItem<String>> _dropDownMenuItemsGroup;

  @override
  void initState() {
    _dropDownMenuItemsDifficulty = getDropDownMenuItemsDifficulty();
    _dropDownMenuItemsGroup = getDropDownMenuItemsGroup();
    _currentDifficulty = _dropDownMenuItemsDifficulty[0].value;
    _currentGroup = _dropDownMenuItemsGroup[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItemsDifficulty() {
    List<DropdownMenuItem<String>> items = new List();
    for (String difficulty in _difficulty) {
      items.add(
          new DropdownMenuItem(value: difficulty, child: new Text(difficulty)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItemsGroup() {
    List<DropdownMenuItem<String>> items = new List();
    for (String group in _group) {
      items.add(new DropdownMenuItem(value: group, child: new Text(group)));
    }
    return items;
  }

  void changedDropDownItemDifficulty(String selectedDifficulty) {
    setState(() {
      _currentDifficulty = selectedDifficulty;
    });
  }

  void changedDropDownItemGroup(String selectedGroup) {
    setState(() {
      _currentGroup = selectedGroup;
    });
  }

  Duration resultingDuration = new Duration(hours: 0, minutes: 30, seconds: 0);
  File file;
  bool defaultImg = false;
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
    setState(() {
      defaultImg = true;
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
      defaultImg = false;
    });
  }

  buildItemSequence(List<Item> itemList) {
    String sequence = "";
    itemList.forEach((item) => {sequence += item.index.toString() + "-"});
    return sequence;
  }

  _getMusclesInvolved(context) async {
    selectedMusclesList = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Musclesinvolved(selectedMusclesList))) ??
        selectedMusclesList;

    selectedMuscles = buildItemSequence(selectedMusclesList);
  }

  _getEquipment(context) async {
    selectedEquipmentList = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Equipment(selectedEquipmentList))) ??
        selectedEquipment;

    selectedEquipment = buildItemSequence(selectedEquipmentList);
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 65));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl,
      String title,
      int duration,
      String currentDifficulty,
      String currentGroup,
      String selectedMuscles,
      String selectedEquipment,
      String mainResource,
      String notes}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "title": title,
      "duration": duration,
      "currentDifficulty": currentDifficulty,
      "currentGroup": currentGroup,
      "selectedMuscles": selectedMuscles,
      "selectedEquipment": selectedEquipment,
      "mainResource": mainResource,
      "notes": notes,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handlesSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        title: titleController.text,
        duration: resultingDuration.inMinutes,
        currentDifficulty: _currentDifficulty,
        currentGroup: _currentGroup,
        selectedMuscles: selectedMuscles,
        selectedEquipment: selectedEquipment,
        mainResource: mainResource,
        notes: notesController.text);
    titleController.clear();
    notesController.clear();
    selectedEquipment = "";
    selectedMuscles = "";
    mainResource = "";
    setState(() {
      file = null;
      defaultImg = false;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  uploadResource() {
    print("Uploading test resource");
    if (notesController.text == "video") {
      mainResource = "video";
    }else if (notesController.text == "pdf"){
      mainResource = "pdf";
    }else if (notesController.text == "link"){
      mainResource = "link";
    }else{
      mainResource ="no";
    }
  }

  buildFormularioCompartir() {
    var children2 = <Widget>[
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
                image: defaultImg == true
                    ? AssetImage('assets/img/share.jpg')
                    : FileImage(file),
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
            controller: titleController,
            decoration: InputDecoration(
                hintText: "Titulo del entrenamiento", border: InputBorder.none),
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
                    initialTime: resultingDuration ?? new Duration(minutes: 30),
                  ) ??
                  resultingDuration;
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
          child: DropdownButton(
            value: _currentDifficulty,
            items: _dropDownMenuItemsDifficulty,
            onChanged: changedDropDownItemDifficulty,
          ),
        ),
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.rowing,
          color: Colors.teal,
          size: 35.0,
        ),
        title: Container(
          width: 250.0,
          child: DropdownButton(
            value: _currentGroup,
            items: _dropDownMenuItemsGroup,
            onChanged: changedDropDownItemGroup,
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
          child: InkWell(
              child: Text("Músculos principales involucrados"),
              onTap: () => _getMusclesInvolved(context)),
        ),
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.fitness_center,
          color: Colors.teal,
          size: 35.0,
        ),
        title: Container(
          width: 250.0,
          child: InkWell(
              child: Text("Equipamiento"), onTap: () => _getEquipment(context)),
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
            controller: notesController,
            decoration:
                InputDecoration(hintText: "Notas", border: InputBorder.none),
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
          onPressed: () => uploadResource(),
          icon: Icon(
            Icons.file_upload,
            color: Colors.white,
          ),
        ),
      )
    ];
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
              onPressed: isUploading ? null : () => handlesSubmit(),
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
        children: children2,
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null && defaultImg == false
        ? buildCompartir()
        : buildFormularioCompartir();
  }
}
