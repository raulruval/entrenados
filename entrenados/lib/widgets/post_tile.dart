import 'package:auto_size_text/auto_size_text.dart';
import 'package:entrenados/widgets/profileHeader.dart';

import 'package:flutter/material.dart';
import 'package:entrenados/pages/post_screen.dart';
import 'package:entrenados/widgets/custom_image.dart';
import 'package:entrenados/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final bool realTimeInfo;

  PostTile(this.post, this.realTimeInfo);

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
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: buildHeader(post.ownerId, post.currentUserId,
                          post.postId, false, post.title),
                    ),
                  )
                ],
              ),
              Divider(
                thickness: 0.8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, right: 10.0, bottom: 10.0, left: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              ClipRRect(
                                child: cachedNetworkImage(
                                  post.photoUrl,
                                  context,
                                  true,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              Text(" "+post.duration.toString() + "'", style: TextStyle(fontSize: 30,color: Colors.teal[600],fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.arrow_upward,
                              color: Colors.black,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: AutoSizeText(
                                  post.difficulty,
                                  style: TextStyle(fontSize: 20),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 4.0)),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.fitness_center,
                              color: Colors.black,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: AutoSizeText(
                                  checkEquipment(),
                                  style: TextStyle(fontSize: 20),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 4.0)),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.rowing,
                              color: Colors.black,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: AutoSizeText(
                                  post.group,
                                  style: TextStyle(fontSize: 20),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 4.0)),
                        realTimeInfo
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: AutoSizeText(
                                        post
                                                .getLikeCount(post.likes)
                                                .toString() +
                                            ' me gusta',
                                        style: TextStyle(fontSize: 20),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 5.0)),
                                ],
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  )
                ],
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
