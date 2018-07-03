import 'dart:io' show Platform;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'tab_user_queue.dart';
import 'tab_user_search.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key key, this.title, this.app, this.user}) : super(key: key);
  final String title;
  final FirebaseApp app;
  final FirebaseUser user;

  @override
  State createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  bool hasScanned = false;

  FirebaseDatabase database;
  DatabaseError _error;
  DatabaseReference nextSongsReference;
  DatabaseReference nowPlayingReference;
  StreamSubscription<Event> nextSongsSubscription;
  StreamSubscription<Event> nowPlayingSubscription;

  String _obtainUserId(String barcode) {
    Map<String, dynamic> map = json.decode(utf8.decode(base64.decode(barcode)));
    return map["adminId"];
  }

  void _setupListeners(String adminUserId) {
    nextSongsReference = database.reference().child("$adminUserId/nextSongs");
    nowPlayingReference = database.reference().child("$adminUserId/nowPlaying");

    nextSongsSubscription =
        nextSongsReference.onChildAdded.listen((Event event) {
          print("nextSongsSubscription triggered");
          setState(() {});
        }, onError: (Object o) {
          final DatabaseError error = o;
          setState(() {
            _error = error;
          });
        });

    nowPlayingSubscription =
        nowPlayingReference.onChildChanged.listen((Event event) {
          print("nowPlayingSubscription triggered");
          setState(() {});
        }, onError: (Object o) {
          final DatabaseError error = o;
          setState(() {
            _error = error;
          });
        });
  }

  Future _scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      _setupListeners(_obtainUserId(barcode));
      setState(() {
        hasScanned = true;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print('The user did not grant the camera permission!');
        _showDialog(
            context,
            'Error!',
            'The app does not have cammera permission, please go to settings to grant access to the app and retry.',
            'RETRY');
      } else {
        print('Unknown error_ $e');
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
      _showDialog(context, 'Error!',
          'You pressed the back button before scanning anything.', 'RETRY');
    } catch (e) {
      print('Unknown error_ $e');
    }
  }

  Widget _iOSDialog(BuildContext context, String title, String body,
      String button) {
    return new WillPopScope(
      child: CupertinoAlertDialog(
        title: new Text(title),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(body),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoButton(
              child: new Text(button, style: Theme
                  .of(context)
                  .textTheme
                  .button),
              onPressed: () {
                Navigator.of(context).pop();
                _scanBarcode();
              }),
        ],
      ),
      onWillPop: () {
        return new Future(() => false);
      },
    );
  }

  Widget _androidDialog(BuildContext context, String title, String body,
      String button) {
    return new WillPopScope(
      child: AlertDialog(
        title: new Text(title),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(body),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(button, style: Theme
                .of(context)
                .textTheme
                .button),
            onPressed: () {
              Navigator.of(context).pop();
              _scanBarcode();
            },
          ),
        ],
      ),
      onWillPop: () {
        return new Future(() => false);
      },
    );
  }

  Future<Widget> _showDialog(BuildContext context, String title, String body,
      String button) async {
    return showDialog<Widget>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return _iOSDialog(context, title, body, button);
        } else {
          return _androidDialog(context, title, body, button);
        }
      },
    );
  }


  @override
  void initState() {
    super.initState();

    database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasScanned) {
      Widget widget;

      _showDialog(
          context,
          'The camera is about to open',
          'We need the QR code generated by the admin, be ready',
          'OK').then((onValue) {
        widget = onValue;
      });
      return Scaffold(
        backgroundColor: Theme
            .of(context)
            .accentColor,
        body: widget,
      );
    } else {
      return WillPopScope(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "Search", icon: Icon(Icons.search)),
                  Tab(text: "Playing next", icon: Icon(Icons.queue_music)),
                ],
              ),
              title: Text(widget.title),
            ),
            body: TabBarView(
              children: [
                TabUserSearch(),
                TabUserQueue(
                  database: this.database,
                  user: widget.user,
                  nextSongsReference: this.nextSongsReference,
                  nowPlayingReference: this.nowPlayingReference,
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          return new Future(() => false);
        },
      );
    }
  }

  @override
  void dispose() {
    nextSongsSubscription.cancel();
    nowPlayingSubscription.cancel();
    super.dispose();
  }
}
