import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrenados/models/user.dart';
import 'package:entrenados/pages/activity.dart';
import 'package:entrenados/pages/home.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

Widget buildHeader(
    ownerId, currentUserId, postId, bool showLocation, String title) {
  return FutureBuilder(
    future: usersRef.document(ownerId).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      User user = User.fromDocument(snapshot.data);
      bool isPostOwner = currentUserId == ownerId;
      return Center(
        child: ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: ownerId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
          ),
          title: title == null
              ? GestureDetector(
                  onTap: () => showProfile(context, profileId: ownerId),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => showProfile(context, profileId: ownerId),
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(
                          user.username,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        title,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
          subtitle: showLocation ? Text("location") : null,
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context, ownerId, postId),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        ),
      );
    },
  );
}

handleDeletePost(BuildContext parentContext, ownerId, postId) {
  return showAnimatedDialog(
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("¿Seguro que quieres eliminar esta publicación?"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                deletePost(ownerId, postId);
                Navigator.pop(context);
              },
              child: Text(
                'Borrar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
              ),
            )
          ],
        );
      });
}

//Nota: Para borrar un post ownerId y currentUserId deben ser iguales, esto no se puede cambiar.
deletePost(ownerId, postId) async {
  postsRef
      .document(ownerId)
      .collection('userPosts')
      .document(postId)
      .get()
      .then((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });
  // borrar la imagen almacenada del post
  storageRef.child("post_$postId.jpg").delete();
  // borrar las notificaciones del activity feed
  QuerySnapshot activityFeedSnapshot = await activityFeedRef
      .document(ownerId)
      .collection("feedItems")
      .where('postId', isEqualTo: postId)
      .getDocuments();

  activityFeedSnapshot.documents.forEach((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });

  // Eliminar los comentarios

  QuerySnapshot commentsSnapshot =
      await commentsRef.document(postId).collection('comments').getDocuments();
  commentsSnapshot.documents.forEach((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });
}
