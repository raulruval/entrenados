import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/edit_profile.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:entrenados/widgets/post.dart';


class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  int postCount = 0;
  bool isLoading = false;
  List<Post> posts = [];
  String postOrientation = "grid";
  int followerCount = 0;
  int followingCount = 0;

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monserrat'),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                fontFamily: 'Monserrat'),
          ),
        )
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Editar perfil",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Siguiendo",
        // function: handleFollowing,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Seguir",
        // function: handleFollow,
      );
    }
  }

  buildAppBarProfile() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.black,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.more_vert),
          color: Colors.black,
          onPressed: (() {}),
        )
      ],
    );
  }

  buildContentProfile() {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "fotoPerfil",
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontFamily: 'Monserrat',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    user.bio,
                    style:
                        TextStyle(fontFamily: 'Monserrat', color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        buildCountColumn("posts", 0),
                        buildCountColumn("seguidores", 0),
                        buildCountColumn("seguidos", 0),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.grid_on),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // BuildPosts
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarProfile(),
      body: buildContentProfile(),
    );
  }
}
