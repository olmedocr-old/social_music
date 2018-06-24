// Create session, generate session code, encode in qr the id, view users in the session, terminate session
import 'dart:async';
import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TabAdminSession extends StatefulWidget {
  TabAdminSession({Key key, this.title, this.database, this.user})
      : super(key: key);
  final String title;
  final FirebaseDatabase database;
  final FirebaseUser user;

  @override
  State createState() => new TabAdminSessionState();
}

class TabAdminSessionState extends State<TabAdminSession> {
  DatabaseReference _activeSessionReference;
  StreamSubscription<Event> _activeSessionSubscription;
  DatabaseError _error;

  @override
  void initState() {
    //TODO: lo mismo por ser tabs y estar esto rulando todo el rato se me va a la puta todo
    super.initState();
    print("initState TabAdminSessionState");
    _activeSessionReference =
        widget.database.reference().child(widget.user.uid);

    _activeSessionSubscription =
        _activeSessionReference.onValue.listen((Event event) {
      setState(() {});
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build TabAdminSessionState");
    return Column(
      children: <Widget>[
        Text("Active sessions"),
        Flexible(
          child: FirebaseAnimatedList(
            query: _activeSessionReference,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Image.network(widget.user.photoUrl),
                  title: Text("Session author ${snapshot.value}"),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                //TODO: change isSessionReady to true and send the uid to be encoded in the qr
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
