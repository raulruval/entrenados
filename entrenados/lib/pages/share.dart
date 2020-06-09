import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/equipment.dart';
import 'package:entrenados/pages/musclesinvolved.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/home.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path/path.dart' as path;

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _titleKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _notesKey = GlobalKey<FormState>();

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
  TextEditingController linkPath = TextEditingController();
  String linkUrl = '';

  handleGaleria(ResourceType fileType) async {
    Navigator.pop(context);
    switch (fileType) {
      case ResourceType.image:
        File file = await ImagePicker.pickImage(
            source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
        setState(() {
          this.imgFile = file;
        });
        break;
      case ResourceType.video:
        File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
        setState(() {
          this.videoFile = file;
        });
        break;
      case ResourceType.document:
        File file = await FilePicker.getFile(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        setState(() {
          this.docFile = file;
        });
        break;
      case ResourceType.link:
        break;
    }
  }

  handleCamara(ResourceType fileType) async {
    Navigator.pop(context);
    switch (fileType) {
      case ResourceType.image:
        File file = await ImagePicker.pickImage(
            source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
        setState(() {
          this.imgFile = file;
        });
        break;
      case ResourceType.video:
        File file = await ImagePicker.pickVideo(source: ImageSource.camera);
        setState(() {
          this.videoFile = file;
        });
        break;
      case ResourceType.document:
        break;
      case ResourceType.link:
        break;
    }
  }

  selectFile(parentContext, bool withCamera, ResourceType fileType) {
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 1),
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              " Subir recurso",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            children: <Widget>[
              withCamera
                  ? SimpleDialogOption(
                      child: Text(
                        "- Recurso desde cámara",
                      ),
                      onPressed: () => handleCamara(fileType),
                    )
                  : SizedBox.shrink(),
              SimpleDialogOption(
                child: Text(
                  "- Recurso desde documentos",
                ),
                onPressed: () => handleGaleria(fileType),
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancelar",
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
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

  Future<String> uploadResource(file, ResourceType typeFile) async {
    StorageUploadTask uploadTask;
    if (typeFile == ResourceType.image) {
      uploadTask = storageRef.child("post_$postId.jpg").putFile(file);
    } else if (typeFile == ResourceType.video) {
      uploadTask = storageRef.child("post_$postId.mp4").putFile(file);
      mainResource = ResourceType.video.toString();
    } else if (typeFile == ResourceType.document) {
      uploadTask = storageRef.child("post_$postId.pdf").putFile(file);
      mainResource = ResourceType.document.toString();
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
      String linkUrl,
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
      "linkUrl": linkUrl,
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
    if (!_notesKey.currentState.validate() &&
        !_titleKey.currentState.validate()) {
      return;
    }

    if (imgFile == null) {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new AutoSizeText(
        "Debes incluir una foto para subir tu entrenamiento.",
        maxLines: 1,
      )));
    }
    if (titleController.text == "") {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new AutoSizeText(
        "Debes incluir un titulo para subir tu entrenamiento.",
        maxLines: 1,
      )));
    } else {
      setState(() {
        isUploading = true;
      });
      await compressImage();

      String photoUrl = await uploadResource(imgFile, ResourceType.image);
      String videoUrl = "", documentUrl = "";
      if (videoFile != null) {
        await compressVideo();
        videoUrl = await uploadResource(videoFile, ResourceType.video);
      }
      if (docFile != null)
        documentUrl = await uploadResource(docFile, ResourceType.document);

      createPostInFirestore(
          photoUrl: photoUrl,
          videoUrl: videoUrl,
          linkUrl: linkUrl,
          documentUrl: documentUrl,
          title: titleController.text,
          duration: resultingDuration.inMinutes,
          currentDifficulty: _currentDifficulty,
          currentGroup: _currentGroup,
          selectedMuscles: selectedMuscles,
          selectedEquipment: selectedEquipment,
          mainResource: mainResource,
          notes: notesController.text);
      setState(() {
        selectedMusclesList.clear();
        selectedEquipmentList.clear();
        titleController.clear();
        notesController.clear();
        selectedEquipment = "";
        selectedMuscles = "";
        mainResource = "";
        documentUrl = null;
        videoFile = null;
        imgFile = null;
        isUploading = false;
        postId = Uuid().v4();
        linkUrl = '';
        linkPath.text = '';
        docFile = null;
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new AutoSizeText(
        "Tu publicación se ha subido correctamente",
        maxLines: 1,
      )));
    }
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  showAlertDeleteResource(
      BuildContext parentContext, ResourceType resourceType) {
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 1),
        context: parentContext,
        barrierDismissible: true,
        builder: (context) {
          return SimpleDialog(
            title: Text("¿Seguro que quieres eliminar este recurso?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  if (resourceType == ResourceType.video) {
                    setState(() {
                      videoFile = null;
                    });
                  }
                  if (resourceType == ResourceType.document) {
                    setState(() {
                      docFile = null;
                    });
                  }
                  if (resourceType == ResourceType.link) {
                    setState(() {
                      linkUrl = '';
                    });
                  }
                },
                child: Text(
                  'Borrar',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                ),
              )
            ],
          );
        });
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
              onTap: () => selectFile(context, true, ResourceType.image),
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
      videoFile != null
          ? ListTile(
              leading: Icon(
                Icons.ondemand_video,
                color: Colors.orange,
                size: 35.0,
              ),
              title: AutoSizeText(
                path.basename(videoFile.path),
                maxLines: 1,
              ),
              trailing: Icon(Icons.delete, color: Colors.red.shade300),
              onTap: () => showAlertDeleteResource(context, ResourceType.video),
            )
          : SizedBox.shrink(),
      docFile != null
          ? ListTile(
              leading: Icon(
                Icons.insert_drive_file,
                color: Colors.orange,
                size: 35.0,
              ),
              title: AutoSizeText(
                path.basename(docFile.path),
                maxLines: 1,
              ),
              trailing: Icon(Icons.delete, color: Colors.red.shade300),
              onTap: () =>
                  showAlertDeleteResource(context, ResourceType.document),
            )
          : SizedBox.shrink(),
      linkUrl != ''
          ? ListTile(
              leading: Icon(
                Icons.insert_link,
                color: Colors.orange,
                size: 35.0,
              ),
              title: AutoSizeText(
                linkPath.text,
                maxLines: 1,
              ),
              trailing: Icon(Icons.delete, color: Colors.red.shade300),
              onTap: () => showAlertDeleteResource(context, ResourceType.link),
            )
          : SizedBox.shrink(),
      Padding(
        padding: EdgeInsets.only(bottom: 15),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundImage:
              CachedNetworkImageProvider(widget.currentUser.photoUrl),
        ),
        title: Container(
          width: 250.0,
          child: Form(
            key: _titleKey,
            child: TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                  hintText: "Titulo del entrenamiento *",
                  border: InputBorder.none),
              onSaved: (val) => titleController.text = val.trim(),
              validator: (String title) {
                if (title.isEmpty || title.trim().length < 3) {
                  return "Titulo demasiado corto";
                } else if (title.trim().length > 25) {
                  return "Titulo demasido largo";
                } else {
                  return null;
                }
              },
            ),
          ),
        ),
      ),
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

              int durationInMinutes = resultingDuration.inMinutes;
              Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text(
                      "Duración escogida: $durationInMinutes minutos")));
            },
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.arrow_upward,
          color: Colors.teal,
          size: 35.0,
        ),
        title: Container(
          width: 250.0,
          child: DropdownButton(
            underline: SizedBox(),
            value: _currentDifficulty,
            items: _dropDownMenuItemsDifficulty,
            onChanged: changedDropDownItemDifficulty,
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.rowing,
          color: Colors.teal,
          size: 35.0,
        ),
        title: Container(
          width: 250.0,
          child: DropdownButton(
            underline: SizedBox(),
            value: _currentGroup,
            items: _dropDownMenuItemsGroup,
            onChanged: changedDropDownItemGroup,
          ),
        ),
      ),
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
      Padding(
        padding: const EdgeInsets.only(top: 3, right: 15, left: 15),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Form(
                    key: _notesKey,
                    child: TextFormField(
                      controller: notesController,
                      onSaved: (val) => notesController.text = val.trim(),
                      decoration: InputDecoration(
                          hintText: "Descripción del entrenamiento",
                          border: InputBorder.none),
                      maxLines: 5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 20.0),
      )
    ];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: fabResources(),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Text(
            "Compartir Post",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: <Color>[Colors.teal[600], Colors.deepPurple[400]])),
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

  displayInputDialogLink(BuildContext context) async {
    return await showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 1),
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Introduce el enlace al recurso',
              style: TextStyle(fontFamily: 'Viga'),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                validator: (String val) {
                  if (!RegExp(
                          r"^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$")
                      .hasMatch(val)) {
                    return 'Por favor, introduce una URL válida';
                  } else {
                    return null;
                  }
                },
                onSaved: (String value) {
                  setState(() {
                    linkUrl = linkPath.text;
                  });
                },
                controller: linkPath,
                decoration:
                    InputDecoration(hintText: "Dirección url de youtube..."),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Aceptar'),
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  fabResources() {
    return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        curve: Curves.bounceIn,
        backgroundColor: Colors.redAccent[200],
        children: [
          SpeedDialChild(
              child: Icon(Icons.ondemand_video),
              label: 'Subir un vídeo',
              onTap: () => selectFile(context, true, ResourceType.video),
              backgroundColor: Colors.blue[600]),
          SpeedDialChild(
              child: Icon(Icons.insert_drive_file),
              label: 'Subir un documento',
              onTap: () => selectFile(context, false, ResourceType.document),
              backgroundColor: Colors.purple[600]),
          SpeedDialChild(
              child: Icon(Icons.insert_link),
              label: 'Enlazar un vídeo de Youtube',
              onTap: () => displayInputDialogLink(context),
              backgroundColor: Colors.orange),
        ]);
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

enum ResourceType { image, video, document, link }
