import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'tab_admin_settings.dart';
import 'tab_admin_sessions.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({Key key, this.title, this.app, this.user}) : super(key: key);
  final String title;
  final FirebaseApp app;
  final FirebaseUser user;

  @override
  State createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  FirebaseDatabase database;
  DatabaseError _error;
  DatabaseReference activeSessionReference;
  StreamSubscription<Event> activeSessionSubscription;
  static bool isRemoteSessionDataReady = false;
  static bool isLoginDataReady = false;
  static bool isSessionDataReady = false;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    activeSessionReference = database.reference().child(widget.user.uid);
    activeSessionReference.keepSynced(true);

    activeSessionSubscription =
        activeSessionReference.onValue.listen((Event event) {
      print("activeSessionSubscription triggered");
      if (event.snapshot.value != null) {
        isRemoteSessionDataReady = true;
      } else {
        isRemoteSessionDataReady = false;
      }
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
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "Session", icon: Icon(Icons.settings_ethernet)),
                Tab(text: "Settings", icon: Icon(Icons.settings)),
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              TabAdminSession(
                user: widget.user,
                activeSessionReference: this.activeSessionReference,
              ),
              TabAdminSettings(
                user: widget.user,
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

  @override
  void dispose() {
    activeSessionSubscription.cancel();
    super.dispose();
  }
}
