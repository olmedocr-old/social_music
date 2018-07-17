import 'dart:io' show Platform;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:social_music/admin/screen_admin.dart';
import 'package:social_music/user/screen_user.dart';
import 'firebase_authentication.dart';

FirebaseUser user;
FirebaseApp app;

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Social Music',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomeScreen(),
      routes: <String, WidgetBuilder>{
        "/admin": (BuildContext context) => new AdminScreen(
            title: 'Social Music Admin Page', user: user, app: app),
        "/user": (BuildContext context) => new UserScreen(
            title: 'Social Music Home Page', user: user, app: app),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<FirebaseUser> _loginFirebase() async {
    return await handleSignIn();
  }

  Future<FirebaseApp> _initFirebase() async {
    return await FirebaseApp.configure(
      name: 'db',
      options: Platform.isIOS
          ? const FirebaseOptions(
              googleAppID: '1:924211986379:ios:d5f9f352ec173ad5',
              apiKey: 'AIzaSyATDU38uR2exfKlAYWd3FvOSL46vl85900',
              databaseURL: 'https://social-music-7b288.firebaseio.com',
            )
          : const FirebaseOptions(
              googleAppID: '1:924211986379:android:7eacfc617334e178',
              apiKey: 'AIzaSyATDU38uR2exfKlAYWd3FvOSL46vl85900',
              databaseURL: 'https://social-music-7b288.firebaseio.com',
            ),
    );
  }

  Widget _iOSDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: new Text('Select the type of user'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(
                'The admin is able to create sessions and must have a Spotify premium account.'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            new Text(
                'A normal user is able to search and add songs to the admin\'s Spotify account.'),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: new Text('Admin'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed("/admin");
          },
        ),
        CupertinoButton(
            child:
                new Text('Normal'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/user");
            }),
      ],
    );
  }

  Widget _androidDialog(BuildContext context) {
    return AlertDialog(
      title: new Text('Select the type of user'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(
                'The admin is able to create sessions and must have a Spotify premium account.'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            new Text(
                'A normal user is able to search and add songs to the admin\'s Spotify account.'),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('ADMIN', style: Theme.of(context).textTheme.button),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed("/admin");
          },
        ),
        new FlatButton(
          child: new Text('NORMAL', style: Theme.of(context).textTheme.button),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed("/user");
          },
        ),
      ],
    );
  }

  Future<Widget> _showDialog(BuildContext context) async {
    user = await _loginFirebase();
    app = await _initFirebase();
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return _iOSDialog(context);
        } else {
          return _androidDialog(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: FutureBuilder(
        future: _showDialog(context),
        builder: (context, snapshot) {
          return Center(
            child: Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
