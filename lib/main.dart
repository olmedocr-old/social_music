import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'firebase_authentication.dart';
import 'package:social_music/admin/screen_admin.dart';
import 'package:social_music/user/screen_user.dart';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  StatelessWidget _onAppStart(BuildContext context) {
    Widget page;

    _selectPage(context).then((onValue) {
      page = onValue;
    });

    return page;
  }

  Future<StatelessWidget> _selectPage(context) async {
    FirebaseUser user = await handleSignIn();

    StatelessWidget page = await Navigator.push(
        context,
        new MaterialPageRoute<StatelessWidget>(
          builder: (BuildContext context) => SimpleDialog(
                title: Text("Select option"),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context,
                          AdminHomePage(title: 'Social Music Admin Page'));
                    },
                    child: Text("Admin"),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context,
                          UserHomePage(title: 'Social Music Home Page'));
                    },
                    child: Text("User"),
                  ),
                ],
              ),
        ));

    return page;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Social Music',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _onAppStart(context),
    );
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
