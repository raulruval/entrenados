import 'package:entrenados/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/home.dart';

import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreen({
    @required this.postId,
    @required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: (header(context, titleText: '', removeBackButton: false)),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 15.0, left: 6.0, right: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34.0),
                      ),
                    ),
                    child: Hero(
                      transitionOnUserGestures: true,
                      tag: 'card',
                      child: Material(
                        type: MaterialType.transparency,
                        child: post,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
