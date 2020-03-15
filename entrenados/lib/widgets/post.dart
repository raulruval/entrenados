import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/item.dart';
import 'package:entrenados/pages/comments.dart';
import 'package:entrenados/pages/equipment.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/pages/musclesinvolved.dart';
import 'package:entrenados/widgets/custom_image.dart';
import 'package:entrenados/widgets/profileHeader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  final String mediaUrl;
  final String notes;
  final dynamic likes;
  final String equipment;
  final String muscles;
  final List<Item> selectedEquipment;
  final List<Item> selectedMuscles;

  Post({
    this.currentUserId,
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.difficulty,
    this.group,
    this.duration,
    this.description,
    this.mediaUrl,
    this.notes,
    this.likes,
    this.equipment,
    this.muscles,
    this.selectedMuscles,
    this.selectedEquipment,
  });

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
      mediaUrl: doc['mediaUrl'],
      notes: doc['notes'],
      likes: doc['likes'],
      equipment: doc['selectedEquipment'],
      muscles: doc['selectedMuscles'],
    );
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
    list = Equipment.getEquipment();
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
    list = Musclesinvolved.getMuscles();
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
        mediaUrl: this.mediaUrl,
        notes: this.notes,
        likeCount: getLikeCount(likes),
        likes: this.likes,
        muscles: this.muscles,
        equipment: this.equipment,
        selectedEquipment: getSelectedEquipment(equipment),
        selectedMuscles: getSelectedMuscles(muscles),
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
  final String mediaUrl;
  final String notes;
  Map likes;
  int likeCount;
  String equipment;
  String muscles;
  bool isLiked;
  bool showHeart = false;
  List<Item> selectedEquipment;
  List<Item> selectedMuscles;
  PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.difficulty,
    this.group,
    this.duration,
    this.description,
    this.mediaUrl,
    this.notes,
    this.likes,
    this.equipment,
    this.muscles,
    this.likeCount,
    this.selectedEquipment,
    this.selectedMuscles,
  });

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
        "mediaUrl": mediaUrl,
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
              child: cachedNetworkImage(mediaUrl, context, false),
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

  buildPostInfo() {
    return Column(
      children: <Widget>[
        Text(
          "$title",
          style: TextStyle(fontSize: 30.0),
        ),
        Text("$duration"),
        Text("$difficulty"),
        Text("$group"),
        for (var item in selectedMuscles) Text(item.name),
        for (var item in selectedEquipment) Text(item.name),
        Text("$notes"),
      ],
    );
  }

  buildPostSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat,
                size: 38.0,
                color: Colors.blue[900],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      children: <Widget>[
        buildHeader(
          this.ownerId,
          this.currentUserId,
          this.postId,
          true,
          null,
        ),
        Divider(
          height: 0.8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildPostImage(),
            buildPostSocial(),
          ],
        ),
        buildPostInfo(),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
