import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'tab_user_settings.dart';
import 'tab_user_queue.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key key, this.title, this.app, this.user}) : super(key: key);
  final String title;
  final FirebaseApp app;
  final FirebaseUser user;

  @override
  State createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  //TODO: clean database code
  FirebaseDatabase database;
  DatabaseError _error;
  DatabaseReference activeSessionReference;
  DatabaseReference rootReference;
  StreamSubscription<Event> activeSessionSubscription;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    activeSessionReference = database.reference().child(widget.user.uid);
    rootReference = database.reference().root();

    activeSessionSubscription =
        activeSessionReference.onValue.listen((Event event) {
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
    return WillPopScope(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "Search", icon: Icon(Icons.search)),
                Tab(text: "Playing next", icon: Icon(Icons.queue_music)),
                Tab(text: "Settings", icon: Icon(Icons.settings)),
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              Center(
                child: Text("Search songs in Spotify"),
              ),
              TabUserQueue(),
              TabUserSettings(),
            ],
          ),
        ),
      ),
      onWillPop: (){
        return new Future(() => false);
      },
    );
  }

  @override
  void dispose() {
    activeSessionSubscription.cancel();
    super.dispose();
  }
}
