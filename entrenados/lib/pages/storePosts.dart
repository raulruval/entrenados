import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/post_tile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StorePosts extends StatefulWidget {
  final User currentUser;
  StorePosts({@required this.currentUser, Key key}) : super(key: key);

  @override
  _StorePostsState createState() => _StorePostsState();
}

class _StorePostsState extends State<StorePosts> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    getStoredPosts();
  }

  getStoredPosts() async {
    QuerySnapshot snapshot = await storedPostsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildStoredPosts() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/img/nofavPosts.svg',
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 1.5,
              ),
              AutoSizeText(
                "No has añadido publicaciones a favoritos. ¡Da un 'me gusta' a una publicación para añadirla a esta sección!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
                maxLines: 3,
              ),
            ],
          ),
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post, false)));
      });
      return ListView(
        children: gridTiles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,
          isAppTitle: false,
          removeBackButton: false,
          titleText: "Publicaciones guardadas"),
      body: buildStoredPosts(),
    );
  }
}
