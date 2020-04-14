import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/post_tile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';

class SearchPostsResponse extends StatefulWidget {
  final List<String> selectedDifficulty;
  final List<String> selectedDuration;
  final List<String> selectedGroup;
  SearchPostsResponse(
      this.selectedDifficulty, this.selectedDuration, this.selectedGroup);
  @override
  _SearchPostsResponseState createState() => _SearchPostsResponseState();
}

class _SearchPostsResponseState extends State<SearchPostsResponse> {
  bool isLoading = false;
  List<Post> posts = [];

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

      for (int i = 0; i < querySnapshot.documents.length; i++) {
        QuerySnapshot snapshot = await postsRef
            .document(querySnapshot.documents[i].documentID)
            .collection('userPosts')
            .orderBy('timestamp', descending: true)
            .getDocuments();

        setState(() {
          posts +=
              snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  buildPostsResponse1() {
    if (isLoading) {
      return circularProgress();
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }

  buildPostsResponse() {
    if (querySnapshot != null) {
      return ListView.builder(
        primary: false,
        itemCount: querySnapshot.documents.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, i) {
          return Column(
            children: <Widget>[
//load data into widgets

              Text("${querySnapshot.documents[i].data['currentDifficulty']}"),
            ],
          );
        },
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // if (isLoading) {
    //   return circularProgress();
    // } else {
    //   List<GridTile> gridTiles = [];
    //   posts.forEach((post) {
    //     gridTiles.add(GridTile(child: PostTile(post)));
    //   });
    //   return ListView(
    //     shrinkWrap: true,
    //     physics: NeverScrollableScrollPhysics(),
    //     children: gridTiles,
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.selectedDifficulty[0]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: buildPostsResponse1(),
    );
  }
}
