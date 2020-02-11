import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
   String id;
   String username;
   String email;
   String photoUrl;
   String displayName;
   String bio;
   String pwd;

  Usuario({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.pwd,
  });


  factory Usuario.fromDocument(DocumentSnapshot doc) {
    return Usuario(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      pwd: doc['pwd'],
    );
  }
}
