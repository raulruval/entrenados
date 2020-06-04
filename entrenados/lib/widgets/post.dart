import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/models/searchModel.dart';
import 'package:entrenados/pages/comments.dart';
import 'package:entrenados/pages/documentViewPage.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/chewei_list_item.dart';
import 'package:entrenados/widgets/custom_image.dart';
import 'package:entrenados/widgets/profileHeader.dart';
import 'package:entrenados/widgets/yt_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:video_player/video_player.dart';

import 'expandableText.dart';

class Post extends StatefulWidget {
  final String currentUserId;
  final String postId;
  final String ownerId;
  final String username;
  final String title;
  final String difficulty;
  final String group;
  final int duration;
  final String description;
  final String photoUrl;
  final String videoUrl;
  final String linkUrl;
  final String documentUrl;
  final String notes;
  final dynamic likes;
  final String equipment;
  final String muscles;
  final String selectedEquipment;
  final String selectedMuscles;
  final String mainResource;
  final Timestamp timestamp;

  Post(
      {this.currentUserId,
      this.postId,
      this.ownerId,
      this.username,
      this.title,
      this.difficulty,
      this.group,
      this.duration,
      this.description,
      this.photoUrl,
      this.videoUrl,
      this.linkUrl,
      this.documentUrl,
      this.notes,
      this.likes,
      this.equipment,
      this.muscles,
      this.selectedMuscles,
      this.selectedEquipment,
      this.mainResource,
      this.timestamp});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        postId: doc['postId'],
        username: doc['username'],
        ownerId: doc['ownerId'],
        title: doc['title'],
        difficulty: doc['currentDifficulty'],
        group: doc['currentGroup'],
        duration: doc['duration'],
        description: doc['description'],
        photoUrl: doc['photoUrl'],
        videoUrl: doc['videoUrl'],
        linkUrl: doc['linkUrl'],
        documentUrl: doc['documentUrl'],
        notes: doc['notes'],
        likes: doc['likes'],
        equipment: doc['selectedEquipment'],
        muscles: doc['selectedMuscles'],
        mainResource: doc['mainResource'],
        timestamp: doc['timestamp']);
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  getSelectedEquipment(String equipment) {
    List<Item> list;
    List<Item> actualEquipment = new List();
    SearchModel sm = new SearchModel();
    list = sm.getEquipment();
    equipment.split("-").forEach((seq) => {
          list.forEach((equip) => {
                if (seq == equip.index.toString()) {actualEquipment.add(equip)}
              })
        });
    return actualEquipment;
  }

  getSelectedMuscles(String muscles) {
    List<Item> list;
    List<Item> actualMuscles = new List();
    SearchModel sm = new SearchModel();
    list = sm.getMuscles();
    muscles.split("-").forEach((seq) => {
          list.forEach((mus) => {
                if (seq == mus.index.toString()) {actualMuscles.add(mus)}
              })
        });
    return actualMuscles;
  }

  @override
  PostState createState() => PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        title: this.title,
        difficulty: this.difficulty,
        group: this.group,
        duration: this.duration,
        description: this.description,
        photoUrl: this.photoUrl,
        videoUrl: this.videoUrl,
        linkUrl: this.linkUrl,
        documentUrl: this.documentUrl,
        notes: this.notes,
        likeCount: getLikeCount(likes),
        likes: this.likes,
        muscles: this.muscles,
        equipment: this.equipment,
        selectedEquipment: getSelectedEquipment(equipment),
        selectedMuscles: getSelectedMuscles(muscles),
        mainResource: this.mainResource,
      );
}

class PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String title;
  final String difficulty;
  final String group;
  final int duration;
  final String description;
  final String photoUrl;
  final String videoUrl;
  final String linkUrl;
  final String documentUrl;
  final String notes;
  Map likes;
  int commentsCount;
  int likeCount;
  String equipment;
  String muscles;
  bool isLiked;
  bool showHeart = false;
  List<Item> selectedEquipment;
  List<Item> selectedMuscles;
  String mainResource;

  PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.difficulty,
    this.group,
    this.duration,
    this.description,
    this.photoUrl,
    this.videoUrl,
    this.linkUrl,
    this.documentUrl,
    this.notes,
    this.likes,
    this.commentsCount,
    this.equipment,
    this.muscles,
    this.likeCount,
    this.selectedEquipment,
    this.selectedMuscles,
    this.mainResource,
  });

  @override
  void initState() {
    getCommentsCount();
    super.initState();
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": photoUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  deleteStoredPostsRef(currentUserId, postId) async {
    storedPostsRef
        .document(currentUserId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = (likes[currentUserId] == true);
    if (_isLiked) {
      postsRef
          .document((ownerId))
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});

      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });

      deleteStoredPostsRef(currentUserId, postId);
    } else if (!_isLiked) {
      postsRef
          .document((ownerId))
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});

      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });

      storedPostsRef
          .document(currentUserId)
          .collection("userPosts")
          .document(postId)
          .setData({
        "postId": postId,
        "ownerId": ownerId,
        "username": username,
        "photoUrl": photoUrl,
        "videoUrl": videoUrl,
        "linkUrl": linkUrl,
        "documentUrl": documentUrl,
        "title": title,
        "duration": duration,
        "currentDifficulty": difficulty,
        "currentGroup": group,
        "selectedMuscles": muscles,
        "selectedEquipment": equipment,
        "mainResource": mainResource,
        "notes": notes,
        "timestamp": timestamp,
        "likes": likes,
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRRect(
              child: cachedNetworkImage(photoUrl, context, false),
              borderRadius: BorderRadius.circular(20.0),
            ),
            showHeart
                ? Animator(
                    duration: Duration(milliseconds: 300),
                    tween: Tween(begin: 0.8, end: 1.4),
                    curve: Curves.elasticOut,
                    cycles: 0,
                    builder: (anim) => Transform.scale(
                      scale: anim.value,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  buildItems(List<Item> selected) {
    return selected.isNotEmpty
        ? Column(
            children: <Widget>[
              for (var item in selected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("- " + item.name, style: TextStyle(fontSize: 16.0)),
                  ],
                ),
            ],
          )
        : Text("Ninguno", style: TextStyle(fontSize: 16.0));
  }

  buildPostInfo() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.arrow_upward,
              size: 40.0,
              color: Colors.teal[900],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Dificultad: ",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "$difficulty",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
           Divider(),
        Row(
          children: <Widget>[
            Icon(
              Icons.timer,
              size: 40.0,
              color: Colors.teal[900],
            ),
Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Duración: ",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "$duration minutos",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        Divider(),
        Row(
          children: <Widget>[
            Icon(
              Icons.rowing,
              size: 40.0,
              color: Colors.teal[900],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Grupo: ",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "$group",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        Divider(),
        Row(
          children: <Widget>[
            Icon(
              Icons.directions_run,
              size: 40.0,
              color: Colors.teal[900],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Músculos involucrados: ",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        buildItems(selectedMuscles),
        Divider(),
        Row(
          children: <Widget>[
            Icon(
              Icons.fitness_center,
              size: 30.0,
              color: Colors.teal[900],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Equipamiento necesario: ",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        buildItems(selectedEquipment),
      ],
    );
  }

  void getCommentsCount() async {
    QuerySnapshot snapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    if (snapshot != null) {
      setState(() {
        commentsCount = snapshot.documents.length;
      });
    }
  }

  buildPostSocial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
          GestureDetector(
            onTap: handleLikePost,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 38.0,
              color: Colors.pink,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text(
              "$likeCount",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ]),
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId, ownerId: ownerId, photoUrl: photoUrl),
              child: Icon(
                Icons.chat,
                size: 38.0,
                color: Colors.blue[900],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                commentsCount != null ? "$commentsCount" : "0",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
        ),
      ],
    );
  }

  showComments(BuildContext context,
      {String postId, String ownerId, String photoUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: postId,
        postOwnerId: ownerId,
        postMediaUrl: photoUrl,
      );
    }));
  }

  buildVideoResource() {
    return Flexible(
      child: ExpansionTile(
          title: GradientText(
            "Vídeo de la publicación",
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.teal[400], Colors.deepPurple[400]]),
          ),
          leading: Icon(
            Icons.ondemand_video,
            color: Colors.deepPurple,
          ),
          children: <Widget>[
            ChewieListItem(
              videoPlayerController:
                  VideoPlayerController.network(this.videoUrl),
              looping: true,
            ),
          ]),
    );
  }

  buildLinkResource() {
    return Flexible(
      child: ExpansionTile(
          title: GradientText(
            "Vídeo de youtube enlazado",
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.teal[400], Colors.deepPurple[400]]),
          ),
          leading: FaIcon(
            FontAwesomeIcons.youtube,
            color: Colors.redAccent,
          ),
          children: <Widget>[
            YtListItem(
              url: linkUrl,
            ),
          ]),
    );
  }

  buildNotes() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: ExpandableText("$notes"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildNamePost() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
        child: GradientText(
          title,
          textAlign: TextAlign.center,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.teal[400], Colors.deepPurple[400]]),
          style: TextStyle(
            wordSpacing: 2,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  buildDocumentResource() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DocumentViewPage(documentUrl: documentUrl))),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: FaIcon(
            FontAwesomeIcons.fileAlt,
            color: Colors.redAccent,
          ),
        ),
        title: GradientText(
          'Visualiza la documentación',
          textAlign: TextAlign.start,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.teal[400], Colors.deepPurple[400]]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            
            children: <Widget>[
              buildHeader(
                this.ownerId,
                this.currentUserId,
                this.postId,
                false,
                null,
              ),
              Divider(
                height: 0.8,
              ),
              title != "" ? buildNamePost() : SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildPostImage(),
                  buildPostSocial(),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: buildPostInfo(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  height: 20,
                  thickness: 5,
                  color: Colors.deepPurple[100],
                ),
              ),
              this.documentUrl != ''
                  ? buildDocumentResource()
                  : SizedBox.shrink(),
              this.videoUrl != ''
                  ? Row(
                      children: <Widget>[
                        buildVideoResource(),
                      ],
                    )
                  : SizedBox.shrink(),
              this.linkUrl != ''
                  ? Row(
                      children: <Widget>[
                        buildLinkResource(),
                      ],
                    )
                  : SizedBox.shrink(),
              notes!= "" ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: buildNotes(),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.teal[100],
                            Colors.deepPurple[100]
                          ]),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
