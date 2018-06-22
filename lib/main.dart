import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_authentication.dart';
import 'screen_admin.dart';
import 'screen_user.dart';

void main() async {
  //FIXME: this shouldn't be here. it penalizes the app startup and can hang if no internet
  //TODO: sacar un popup y elegir si es consumer o producer y hacer un setstate en funcion de eso, no comprobando el mail
  FirebaseUser user = await handleSignIn();
  runApp(new MyApp(user: user));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.user})
      : super(key: key); // This widget is the root of your application.
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Social Music',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: user.email == 'rauleteolmedo@gmail.com'
            ? new AdminHomePage(title: 'Social Music Admin Page')
            : new UserHomePage(title: 'Social Music Home Page'));
  }
}

class UserHomePage extends StatelessWidget {
  UserHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return UserScreen(title: this.title);
  }
}

class AdminHomePage extends StatelessWidget {
  AdminHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return AdminScreen(title: this.title);
  }
}
