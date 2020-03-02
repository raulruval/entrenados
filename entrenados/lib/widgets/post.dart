import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/comments.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/custom_image.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String caption;
  final String difficulty;
  final String group;
  final String duration;
  final String description;
  final String mediaUrl;
  final String notes;
  final dynamic likes;
  final dynamic equipment;
  final dynamic muscles;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.caption,
    this.difficulty,
    this.group,
    this.duration,
    this.description,
    this.mediaUrl,
    this.notes,
    this.likes,
    this.equipment,
    this.muscles,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      caption: doc['caption'],
      difficulty: doc['difficulty'],
      group: doc[''],
      duration: doc[''],
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

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        caption: this.caption,
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
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String caption;
  final String difficulty;
  final String group;
  final String duration;
  final String description;
  final String mediaUrl;
  final String notes;
  Map likes;
  int likeCount;
  Map equipment;
  Map muscles;
  bool isLiked = false;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.caption,
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
  });

  buildHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("mostrar perfil"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text("location"),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => print("deletePOst"),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print("Like post"),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            cachedNetworkImage(mediaUrl),
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
          "Prueba de texto",
          style: TextStyle(fontSize: 30.0),
        ),
      ],
    );
  }

  buildPostSocial() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: 20.0,
              ),
            ),
            GestureDetector(
              onTap: () => print("liked post"),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 20.0,
              ),
            ),
            GestureDetector(
              onTap: () => print("mostrar comentarios"),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(""),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildHeader(),
        Divider(
          height: 0.8,
        ),
        buildPostImage(),
        buildPostSocial(),
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
