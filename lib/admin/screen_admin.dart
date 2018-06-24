import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:social_music/admin/tab_admin_settings.dart';
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

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            TabAdminSession(database: this.database, user: widget.user),
            TabAdminSettings(),
          ],
        ),
      ),
    );
  }
}
