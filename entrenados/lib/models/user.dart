import 'package:cloud_firestore/cloud_firestore.dart';

class User {
   String id;
   String username;
   String email;
   String photoUrl;
   String displayName;
   String bio;
   String pwd;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.pwd,
  });


  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
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
