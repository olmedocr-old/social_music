// Create session, generate session code, encode in qr the id, view users in the session, terminate session
import 'dart:async';
import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'tab_admin_settings.dart';
import 'package:social_music/session.dart';

String userId;

class TabAdminSession extends StatefulWidget {
  TabAdminSession(
      {Key key, this.user, this.rootReference, this.activeSessionReference})
      : super(key: key);
  final FirebaseUser user;
  final DatabaseReference activeSessionReference;
  final DatabaseReference rootReference;

  @override
  State createState() => new TabAdminSessionState();
}

class TabAdminSessionState extends State<TabAdminSession> {
  bool _sessionActive = false;
  DatabaseReference newChild;

  void _addSession() {
    if (!_sessionActive){
      widget.rootReference.update({widget.user.uid: ""});
      newChild = widget.rootReference.child(widget.user.uid);
      newChild.set(new Session(widget.user.displayName).toMap());

      userId = widget.user.uid;
      _sessionActive = true;
      isSessionDataReady = true;
    } else {
      //TODO: if the session already exists, manage the boolean that allows the wr creation and session addition
      _generateSnackBar("Session already active, delete it first");
    }

  }

  void _removeSession(){
    widget.rootReference.child(widget.user.uid).remove();

    _sessionActive = false;
    isSessionDataReady = false;
  }

  void _generateSnackBar(String text) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(text),
      ),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("Active sessions"),
        Flexible(
          child: FirebaseAnimatedList(
            defaultChild: CircularProgressIndicator(),
            query: widget.rootReference.child(widget.user.uid),
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Image.network(widget.user.photoUrl),
                  //TODO: take only the child with the name, maybe is a listener problem
                  title: Text("Session author ${snapshot.value}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _removeSession();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
