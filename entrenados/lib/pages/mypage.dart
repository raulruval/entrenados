import 'package:auto_size_text/auto_size_text.dart';
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

class _MyPageState extends State<MyPage> with TickerProviderStateMixin {
  AnimationController _breathingController;
  var _breathe = 0.0;
  int timesBreathe = 0;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed && timesBreathe < 5) {
        _breathingController.forward();
        timesBreathe++;
      }
    });
    _breathingController.addListener(() {
      setState(() {
        _breathe = _breathingController.value;
      });
    });
    _breathingController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final size = 35 - 7 * _breathe;
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AutoSizeText(
                        'Entrenados',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 25.0,
                            color: Colors.grey.shade900),
                        maxLines: 1,
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.notifications),
                              color: Colors.grey.shade500,
                              iconSize: 35.0,
                              onPressed: () {
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
                                transitionOnUserGestures: true,
                                tag: "fotoPerfil",
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: size,
                                    backgroundImage: CachedNetworkImageProvider(
                                        user.photoUrl),
                                  ),
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
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey.shade100),
                    child: GestureDetector(
                      onTap: () => print("Abrir entrenamientos"),
                      child: Padding(
                      padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 60.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.red,
                              size: 50.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'ENTRENAMIENTOS SUGERIDOS',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            'Ver todos',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
