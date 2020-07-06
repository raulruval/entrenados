import 'package:auto_size_text/auto_size_text.dart';
import 'package:entrenados/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/home.dart';

import 'package:entrenados/widgets/post.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_svg/svg.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreen({
    @required this.postId,
    @required this.userId,
  });

  Future<void> showAlertDeletePost(String texto, BuildContext context) async {
    return showAnimatedDialog<void>(
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuario existente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(texto),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Volver a intentarlo'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  deletedPost(BuildContext context) {
    return Scaffold(
      body: Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              "Lo sentimos, esta publicación ya no existe. Recarga la vista para eliminarla.",
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
  }

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
        Post post;
        try {
          post = Post.fromDocument(snapshot.data);
        } catch (ex) {}
        return post != null
            ? Center(
                child: Scaffold(
                  backgroundColor: Colors.grey[300],
                  appBar:
                      (header(context, titleText: '', removeBackButton: false)),
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(top: 15.0, left: 6.0, right: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(34.0),
                            ),
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: post,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : deletedPost(context);
      },
    );
  }
}
