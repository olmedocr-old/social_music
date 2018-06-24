import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_music/admin/screen_admin.dart';
import 'package:social_music/user/screen_user.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_authentication.dart';

void main() async {
  //FIXME: this shouldn't be here. it penalizes the app startup and can hang if no internet
  //TODO: sacar un popup y elegir si es consumer o producer y hacer un setstate en funcion de eso, no comprobando el mail
  FirebaseUser user = await handleSignIn();

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: 'to-do',
      apiKey: 'AIzaSyATDU38uR2exfKlAYWd3FvOSL46vl85900',
      databaseURL: 'https://social-music-7b288.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:924211986379:android:7eacfc617334e178',
      apiKey: 'AIzaSyATDU38uR2exfKlAYWd3FvOSL46vl85900',
      databaseURL: 'https://social-music-7b288.firebaseio.com',
    ),
  );

  runApp(new MyApp(user: user, app: app,));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.user, this.app})
      : super(key: key); // This widget is the root of your application.
  final FirebaseUser user;
  final FirebaseApp app;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Social Music',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: user.email == 'rauleteolmedo@gmail.com'
            ? new AdminHomePage(title: 'Social Music Admin Page', user: this.user)
            : new UserHomePage(title: 'Social Music Home Page'));
  }
}

class UserHomePage extends StatelessWidget {
  UserHomePage({Key key, this.title, this.app}) : super(key: key);
  final String title;
  final FirebaseApp app;

  @override
  Widget build(BuildContext context) {
    return UserScreen(title: this.title, app: this.app);
  }
}

class AdminHomePage extends StatelessWidget {
  AdminHomePage({Key key, this.title, this.app, this.user}) : super(key: key);
  final String title;
  final FirebaseApp app;
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return AdminScreen(title: this.title, app: this.app, user: this.user);
  }
}
