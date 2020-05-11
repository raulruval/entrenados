import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/post_tile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchPostsResponse extends StatefulWidget {
  final String selectedDifficulty;
  final int selectedDuration;
  final List<String> selectedGroup;
  final String selectedMuscles;
  final String selectedEquipment;
  SearchPostsResponse(this.selectedDifficulty, this.selectedDuration,
      this.selectedGroup, this.selectedMuscles, this.selectedEquipment);
  @override
  _SearchPostsResponseState createState() => _SearchPostsResponseState();
}

class _SearchPostsResponseState extends State<SearchPostsResponse> {
  List<Post> posts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPrueba().then((results) {
      setState(() {
        querySnapshot = results;
        getPosts();
      });
    });
  }

  QuerySnapshot querySnapshot;

  getPrueba() async {
    return await usersRef.getDocuments();
  }

  getPosts() async {
    if (querySnapshot != null) {
      setState(() {
        isLoading = true;
      });
      print(widget.selectedMuscles + " y " + widget.selectedEquipment);

      for (int i = 0; i < querySnapshot.documents.length; i++) {
        for (int g = 0; g < widget.selectedGroup.length; g++) {
          QuerySnapshot snapshot = await postsRef
              .document(querySnapshot.documents[i].documentID)
              .collection('userPosts')
              .where('currentDifficulty', isEqualTo: widget.selectedDifficulty)
              .where('duration', isLessThanOrEqualTo: widget.selectedDuration)
              .where('currentGroup', isEqualTo: widget.selectedGroup[g])
              .where('selectedMuscles', isEqualTo: widget.selectedMuscles)
              .where('selectedEquipment', isEqualTo: widget.selectedEquipment)
              .getDocuments();

          setState(() {
            posts += snapshot.documents
                .map((doc) => Post.fromDocument(doc))
                .toList();
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  buildPostsResponse() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: SvgPicture.asset(
              'assets/img/empty.svg',
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 1.5,
            ),
          ),
          AutoSizeText(
            "Lo sentimos, no se encontró ninguna publicación con esos filtros. ¡Prueba con otros!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontSize: 40.0,
                fontWeight: FontWeight.bold),
            maxLines: 3,
          ),
        ],
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post, true)));
      });
      return ListView(
        shrinkWrap: true,
        children: gridTiles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.selectedDifficulty[0]);
    return Scaffold(
      appBar: header(context,
          isAppTitle: false,
          removeBackButton: false,
          titleText: "Publicaciones"),
      body: buildPostsResponse(),
    );
  }
}
