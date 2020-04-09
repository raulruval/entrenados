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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: () => Hero(
        transitionOnUserGestures: true,
        tag: 'card',
        child: Material(
          type: MaterialType.transparency,
          child: showPost(context),
        ),
      ),
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: buildHeader(post.ownerId, post.currentUserId,
                          post.postId, false, post.title),
                    ),
                  )
                ],
              ),
              Divider(
                thickness: 0.8,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.18,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 10.0,
                                bottom: 10.0,
                                left: 15.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.height * 0.15,
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
                                  post.mainResource == "video"
                                      ? Icon(
                                          Icons.videocam,
                                          size: 40.0,
                                          color: Colors.teal,
                                        )
                                      : post.mainResource == "pdf"
                                          ? Icon(
                                              Icons.picture_as_pdf,
                                              size: 40.0,
                                              color: Colors.teal,
                                            )
                                          : post.mainResource == "link"
                                              ? Icon(
                                                  Icons.link,
                                                  size: 40.0,
                                                  color: Colors.teal,
                                                )
                                              : Icon(
                                                  Icons.not_listed_location,
                                                  size: 40.0,
                                                  color: Colors.teal,
                                                )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 15.0),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                ),
                              ),
                              Text(post.difficulty),
                            ],
                          ),

                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Colors.black,
                                ),
                              ),
                              Text(checkEquipment()),
                            ],
                          ),

                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Icon(
                                  Icons.rowing,
                                  color: Colors.black,
                                ),
                              ),
                              Text(post.group),
                            ],
                          ),

                          Row(
                            children: <Widget>[],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: <Widget>[
                          //     Padding(
                          //       padding: const EdgeInsets.only(
                          //           left: 8.0, right: 8.0),
                          //       child: Icon(
                          //         Icons.favorite,
                          //         color: Colors.red,
                          //       ),
                          //     ),
                          //     Text(post.getLikeCount(post.likes).toString()),
                          //     Padding(
                          //       padding: const EdgeInsets.only(
                          //           left: 8.0, right: 8.0),
                          //       child: Icon(
                          //         Icons.timer,
                          //         color: Colors.blue,
                          //       ),
                          //     ),
                          //     Text(post.duration.toString() + "'"),
                          //   ],
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  String checkEquipment() {
    if (post.equipment == "") {
      return "Sin equipamiento";
    } else {
      int n = -1;
      post.equipment.split("-").forEach((seq) => {n++});
      return "Equipamiento [ " + n.toString() + " ]";
    }
  }
}
