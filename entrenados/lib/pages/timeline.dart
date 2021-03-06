import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/pages/search.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/post_tile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList;
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildUserToFollow() {
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          return Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot usersRec = snapshot.data.documents[index];
                  UserResult userResult;
                  return Column(
                    children: <Widget>[
                      FutureBuilder(
                          future: postsRef
                              .document(usersRec.data['id'])
                              .collection('userPosts')
                              .getDocuments(),
                          builder: (BuildContext context, AsyncSnapshot snaps) {
                            if (snaps.hasData) {
                              if (snaps.data != null) {
                                if (snaps.data.documents.length > 0) {
                                  User user = User.fromDocument(usersRec);
                                  final bool isFollowingUser =
                                      followingList.contains(user.id);
                                  final bool notVerified = user.id == "";
                                   if (user.username != null &&
                                      user.username != "" &&
                                      user.displayName != null &&
                                      user.displayName != "" && !isFollowingUser && !notVerified && !isFollowingUser) {
                                    userResult = UserResult(user);
                                  }
                                }
                              }
                            }
                            return Container(
                              child: userResult,
                            );
                          }),
                    ],
                  );
                }),
          );
        }
      },
    );
  }

  buildTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        color: Theme.of(context).accentColor.withOpacity(0.1),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).primaryColor,
                    size: 30.0,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "Recomendaciones",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30.0),
                  ),
                ],
              ),
            ),
            buildUserToFollow(),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post, true)));
      });
      return ListView(
        children: gridTiles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: header(context, isAppTitle: true, removeBackButton: true),
        body: RefreshIndicator(
          onRefresh: () => getTimeline(),
          child: buildTimeLine(),
        ));
  }
}
