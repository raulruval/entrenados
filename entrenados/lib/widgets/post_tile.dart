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
                    child: Container(
                      child: buildHeader(
                          post.ownerId, post.currentUserId, post.postId, false, post.title),
                    ),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            ClipRRect(
                              child: cachedNetworkImage(
                                post.mediaUrl,
                                context,
                                true,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            Text(
                              "16'",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(255, 255, 255, 0.6),
                                fontSize: 45.0,
                                fontFamily: "Monserrat"
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.black,
                            ),
                          ),
                          Text("Principiante"),
                        ],
                      ),
                      Divider(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.fitness_center,
                              color: Colors.black,
                            ),
                          ),
                          Text("Sin equipamiento"),
                        ],
                      ),
                      Divider(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.rowing,
                              color: Colors.black,
                            ),
                          ),
                          Text("Resistencia"),
                        ],
                      ),
                      Divider(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                          Text("540"),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.comment,
                              color: Colors.blue,
                            ),
                          ),
                          Text("540"),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          )),
    );
  }
}
