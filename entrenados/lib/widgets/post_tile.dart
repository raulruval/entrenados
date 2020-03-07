import 'package:entrenados/widgets/profileHeader.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/pages/post_screen.dart';
import 'package:entrenados/widgets/custom_image.dart';
import 'package:entrenados/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 160),
          pageBuilder: (_, __, ___) => PostScreen(
                postId: post.postId,
                userId: post.ownerId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: Container(
          margin: EdgeInsets.only(top: 15.0, left: 6.0, right: 6.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(34.0), bottom: Radius.circular(34.0)),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: buildHeader(post.ownerId, post.currentUserId, false),
                  )
                ],
              ),
              Divider(
                thickness: 0.8,
              ),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, right: 10.0, bottom: 10.0, left: 15.0),
                        child: ClipRRect(
                          child: cachedNetworkImage(
                            post.mediaUrl,
                            context,
                            true,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[],
                  )
                ],
              ),
            ],
          )),
    );
  }
}
