import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/equipment.dart';
import 'package:entrenados/pages/musclesinvolved.dart';
import 'package:entrenados/widgets/circularFab.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/home.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:image/image.dart' as Im;

class Share extends StatefulWidget {
  final User currentUser;
  final SearchModel searchModel;

  Share({this.currentUser, this.searchModel});
  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share>
    with AutomaticKeepAliveClientMixin<Share>, SingleTickerProviderStateMixin {
  final _flutterVideoCompress = FlutterVideoCompress();
  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController duracionController = TextEditingController();
  List<Item> selectedMusclesList = List();
  List<Item> selectedEquipmentList = List();
  String selectedMuscles = "";
  String selectedEquipment = "";
  String mainResource = "";
  String _currentDifficulty;
  String _currentGroup;
  List<DropdownMenuItem<String>> _dropDownMenuItemsDifficulty;
  List<DropdownMenuItem<String>> _dropDownMenuItemsGroup;
  AnimationController _animationController;
  Animation _degOneTranslationAnimation;
  Animation _rotationAnimation;

  @override
  void initState() {
    _dropDownMenuItemsDifficulty = getDropDownMenuItemsDifficulty();
    _dropDownMenuItemsGroup = getDropDownMenuItemsGroup();
    _currentDifficulty = _dropDownMenuItemsDifficulty[0].value;
    _currentGroup = _dropDownMenuItemsGroup[0].value;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _degOneTranslationAnimation = TweenSequence(<TweenSequenceItem>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(_animationController);
    _rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItemsDifficulty() {
    List<DropdownMenuItem<String>> items = new List();
    for (String difficulty in widget.searchModel.difficulty) {
      items.add(
          new DropdownMenuItem(value: difficulty, child: new Text(difficulty)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItemsGroup() {
    List<DropdownMenuItem<String>> items = new List();
    for (String group in widget.searchModel.group) {
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
  File imgFile;
  File videoFile;
  File docFile;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleGaleria(String fileType) async {
    Navigator.pop(context);
    switch (fileType) {
      case "image":
        File file = await ImagePicker.pickImage(
            source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
        setState(() {
          this.imgFile = file;
        });
        break;
      case "video":
        File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
        setState(() {
          this.videoFile = file;
        });
        break;
      case "document":
        print("documento");
        break;
    }
  }

  handleCamara(String fileType) async {
    Navigator.pop(context);
    switch (fileType) {
      case "image":
        File file = await ImagePicker.pickImage(
            source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
        setState(() {
          this.imgFile = file;
        });
        break;
      case "video":
        File file = await ImagePicker.pickVideo(source: ImageSource.camera);
        setState(() {
          this.videoFile = file;
        });
        break;
      case "document":
        print("documento");
        break;
    }
  }

  selectFile(parentContext, bool withCamera, String fileType) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Subir recurso"),
            children: <Widget>[
              withCamera
                  ? SimpleDialogOption(
                      child: Text("Recurso desde cámara"),
                      onPressed: () => handleCamara(fileType),
                    )
                  : "",
              SimpleDialogOption(
                child: Text("Recurso desde documentos"),
                onPressed: () => handleGaleria(fileType),
              ),
              SimpleDialogOption(
                child: Text("Limpiar recursos"),
                onPressed: () => {clearFiles(), Navigator.pop(context)},
              ),
              SimpleDialogOption(
                child: Text("Cancelar"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  clearFiles() {
    setState(() {
      imgFile = null;
    });
  }

  buildItemSequence(List<Item> itemList) {
    List<int> sequence = [];
    itemList.forEach((item) => {sequence.add(item.index)});

    sequence.sort();
    String sortSequence = "";
    sequence.forEach((sequence) => {sortSequence += sequence.toString() + "-"});

    return sortSequence;
  }

  _getMusclesInvolved(context) async {
    selectedMusclesList = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Musclesinvolved(
                    selectedMusclesList, widget.searchModel))) ??
        selectedMusclesList;

    selectedMuscles = buildItemSequence(selectedMusclesList);
  }

  _getEquipment(context) async {
    selectedEquipmentList = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Equipment(selectedEquipmentList, widget.searchModel))) ??
        selectedEquipment;

    selectedEquipment = buildItemSequence(selectedEquipmentList);
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(imgFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 65));
    setState(() {
      imgFile = compressedImageFile;
    });
  }

  compressVideo() async {
    final info = await _flutterVideoCompress.compressVideo(
      videoFile.path,
      quality:
          VideoQuality.HighestQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );
    setState(() {
      videoFile = info.file;
    });
  }

  Future<String> uploadResource(file, String typeFile) async {
    StorageUploadTask uploadTask;
    if (typeFile == "image") {
      uploadTask = storageRef.child("post_$postId.jpg").putFile(file);
    } else if (typeFile == "video") {
      uploadTask = storageRef.child("post_$postId.mp4").putFile(file);
      mainResource = "video";
    } else if (typeFile == "pdf") {
      uploadTask = storageRef.child("post_$postId.pdf").putFile(file);
      mainResource = "pdf";
    } else {
      return null;
    }
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String photoUrl,
      String videoUrl,
      String documentUrl,
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
      "photoUrl": photoUrl,
      "videoUrl": videoUrl,
      "documentUrl": documentUrl,
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
    if (imgFile == null) {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new AutoSizeText(
        "Debes incluir una foto para subir tu entrenamiento.",
        maxLines: 1,
      )));
    } else {
      setState(() {
        isUploading = true;
      });
      await compressImage();

      String photoUrl = await uploadResource(imgFile, "image");
      String videoUrl = "", documentUrl = "";
      if (videoFile != null) {
        await compressVideo();
        videoUrl = await uploadResource(videoFile, "video");
      }
      if (docFile != null) documentUrl = await uploadResource(docFile, "doc");
      createPostInFirestore(
          photoUrl: photoUrl,
          videoUrl: videoUrl,
          documentUrl: documentUrl,
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
      selectedEquipmentList = [];
      selectedMusclesList = [];
      mainResource = "";
      setState(() {
        documentUrl = null;
        videoFile = null;
        imgFile = null;
        isUploading = false;
        postId = Uuid().v4();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new AutoSizeText(
        "Tu publicación se ha subido correctamente",
        maxLines: 1,
      )));
    }
  }

  // uploadResourceFab() {
  //   return Container(
  //     width: 200.0,
  //     height: 100.0,
  //     alignment: Alignment.center,
  //     child: RaisedButton.icon(
  //       label: Text(
  //         "Subir recurso",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(30.0),
  //       ),
  //       color: Colors.teal,
  //       onPressed: () => selectFile(context, true, "video"),
  //       icon: Icon(
  //         Icons.file_upload,
  //         color: Colors.white,
  //       ),
  //     ),
  //   );
  // }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
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
            child: GestureDetector(
              onTap: () => selectFile(context, true, "image"),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: imgFile == null
                      ? AssetImage('assets/img/addPhoto.png')
                      : FileImage(imgFile),
                )),
              ),
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
      // uploadResourceFab(),
    ];
    return Scaffold(
      floatingActionButton: fab(),
      appBar: AppBar(
          backgroundColor: Colors.teal,
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

  fab() {
    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset.fromDirection(getRadiansFromDegree(270),
              _degOneTranslationAnimation.value * 90),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(
                getRadiansFromDegree(_rotationAnimation.value))
              ..scale(_degOneTranslationAnimation.value),
            child: CircularFab(
              color: Colors.blue,
              width: 50,
              height: 50,
              icon: Icon(
                Icons.insert_link,
                color: Colors.white,
              ),
              onClick: () => selectFile(context, true, "enlace"),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(getRadiansFromDegree(225),
              _degOneTranslationAnimation.value * 90),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(
                getRadiansFromDegree(_rotationAnimation.value))
              ..scale(_degOneTranslationAnimation.value),
            child: CircularFab(
                color: Colors.purple,
                width: 50,
                height: 50,
                icon: Icon(
                  Icons.ondemand_video,
                  color: Colors.white,
                ),
                onClick: () => print("hola"))
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(getRadiansFromDegree(180),
              _degOneTranslationAnimation.value * 90),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(
                getRadiansFromDegree(_rotationAnimation.value))
              ..scale(_degOneTranslationAnimation.value),
            child: CircularFab(
              color: Colors.orangeAccent,
              width: 50,
              height: 50,
              icon: Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
              ),
              onClick: () => print("hola"),
            ),
          ),
        ),
        Container(
          height: 60,
          width: 60,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.rotationZ(getRadiansFromDegree(_rotationAnimation.value)),
            child: CircularFab(
              color: Colors.red,
              width: 60,
              height: 60,
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onClick: () {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OrientationLayoutBuilder(
      portrait: (context) => buildFormularioCompartir(),
      landscape: (context) => buildFormularioCompartir(),
    );
  }
}
