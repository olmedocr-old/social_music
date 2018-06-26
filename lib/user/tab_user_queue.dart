import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TabUserQueue extends StatefulWidget {
  TabUserQueue({
    Key key,
    this.user,
    this.rootReference,
    this.activeSessionReference,
    this.nextSongsReference,
    this.nowPlayingReference,
  }) : super(key: key);
  final FirebaseUser user;
  final DatabaseReference activeSessionReference;
  final DatabaseReference rootReference;
  final DatabaseReference nextSongsReference;
  final DatabaseReference nowPlayingReference;

  @override
  State createState() => new TabUserQueueState();
}

class TabUserQueueState extends State<TabUserQueue> {
  DatabaseReference newChild;

  void _addSong() {
    widget.nextSongsReference.push().set("Test");
  }

  void _markAsFavourite() {}

  @override
  Widget build(BuildContext context) {
    //TODO: select the correct layout
    return Column(
      children: <Widget>[
        Text("Now playing"),
        Flexible(
          child: FirebaseAnimatedList(
            defaultChild: CircularProgressIndicator(),
            query: widget.nowPlayingReference,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Text("Image"),
                  title: Text("Data ${snapshot.value}"),
                  trailing: Text("-3:25"),
                ),
              );
            },
          ),
        ),
        Text("Next in the queue"),
        Flexible(
          child: FirebaseAnimatedList(
            defaultChild: CircularProgressIndicator(),
            query: widget.nextSongsReference,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Text("Image"),
                  title: Text("Data ${snapshot.value}"),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: _markAsFavourite,
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _addSong,
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
