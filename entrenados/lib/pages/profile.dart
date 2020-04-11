import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/edit_profile.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/post_tile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/post.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  int postCount = 0;
  bool isLoading = false;
  List<Post> posts = [];
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AutoSizeText(
          count.toString(),
          style: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monserrat'),
          maxLines: 1,
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: AutoSizeText(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              fontFamily: 'Monserrat',
            ),
            maxLines: 1,
          ),
        )
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0, left: 15.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 150.0,
          height: 50.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.teal[200] : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.teal[800],
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.teal[800],
            ),
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  handleFollowing() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return Container(
        child: buildButton(
          text: "Editar perfil",
          function: editProfile,
        ),
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Siguiendo",
        function: handleFollowing,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Seguir",
        function: handleFollow,
      );
    }
  }

  buildAppBarProfile() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.more_vert),
          color: Colors.white,
          onPressed: (() {}),
        )
      ],
    );
  }

  buildMobileProfile() {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);

          return Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: "fotoPerfil",
                          child: SizedBox(
                            height: 90.0,
                            width: 90.0,
                            child: CircleAvatar(
                              radius: 45.0,
                              backgroundImage:
                                  CachedNetworkImageProvider(user.photoUrl),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: AutoSizeText(
                              user.displayName,
                              style: TextStyle(
                                fontFamily: 'Monserrat',
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Flexible(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                AutoSizeText(
                                  user.bio,
                                  style: TextStyle(
                                    fontFamily: 'Monserrat',
                                    color: Colors.white,
                                    wordSpacing: 2,
                                    letterSpacing: 2,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Parte de seguidores
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.28,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child:
                                buildCountColumn("seguidores", followerCount),
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        child: buildCountColumn("seguidos", followingCount),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.44,
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: buildProfileButton())),
                    ],
                  ),
                ),
              ),
              // BuildPosts
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: buildCard(),
              )
            ],
          );
        });
  }

  buildCard() {
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 15.0, left: 4.0, right: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(34.0),
            ),
          ),
          child: Hero(
            transitionOnUserGestures: true,
            tag: 'card',
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 25.0,
                        left: 25.0,
                        right: 25.0,
                      ),
                      child: Text(
                        'Publicaciones ($postCount)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          fontFamily: 'Monserrat',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildProfilePosts(),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/img/empty.svg',
              height: 260.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 60),
              child: Text(
                "No existen publicaciones",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return Expanded(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridTiles,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: buildAppBarProfile(),
          body: Container(
            color: Theme.of(context).primaryColor,
            child: OrientationLayoutBuilder(
              portrait: (context) => buildMobileProfile(),
              landscape: (context) => buildCard(),
            ),
          )),
    );
  }
}
