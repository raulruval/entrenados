import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/activity.dart';
import 'package:entrenados/pages/profile.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class MyPage extends StatefulWidget {
  final String profileId;
  MyPage({this.profileId});
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Scaffold(
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 30.0, top: 15.0, right: 30.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Entrenados',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 25.0,
                            color: Colors.grey.shade900),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.notifications),
                              color: Colors.grey.shade500,
                              iconSize: 35.0,
                              onPressed: ()  {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => new Activity(),
                                  ),
                                );
                              },
                            ),
                            Padding(padding: EdgeInsets.only(right: 10.0)),
                            InkWell(
                              child: Hero(
                                tag: "fotoPerfil",
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.photoUrl),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => new Profile(
                                        profileId: widget.profileId),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0),
                    height: 100.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey.shade100),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.navigation, color: Colors.blue),
                          iconSize: 50.0,
                          onPressed: () {},
                        ),
                        SizedBox(width: 5.0),
                        Padding(
                          padding: EdgeInsets.only(top: 27.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'ENTRENAMIENTOS FAVORITOS',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14.0),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Añade tus entrenamientos',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 50.0),
                        IconButton(
                          icon:
                              Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          iconSize: 30.0,
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'ENTRENAMIENTOS SUGERIDOS',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.0,
                            fontFamily: 'Montserrat'),
                      ),
                      Text(
                        'Ver todos',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            fontFamily: 'Montserrat'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
