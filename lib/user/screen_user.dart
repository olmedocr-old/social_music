import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:social_music/user/tab_user_settings.dart';

class UserScreen extends StatefulWidget{
  UserScreen({Key key, this.title, this.app}) : super(key: key);
  final String title;
  final FirebaseApp app;

  @override
  State createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            Center(
              child: Text("See the list of songs next"),
            ),
            TabUserSettings(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Pressed");
          },
          tooltip: 'Add song to queue',
          child: new Icon(Icons.add),
        ),
      ),
    );
  }


}