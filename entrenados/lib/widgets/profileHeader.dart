import 'package:cached_network_image/cached_network_image.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';

Widget buildHeader(ownerId, currentUserId, bool showLocation) {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("mostrar perfil"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ), 
          
          subtitle: showLocation ? Text("location") : null,
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => print("deletePOst"),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }