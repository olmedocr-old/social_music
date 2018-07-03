import 'dart:io' show Platform;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TabUserQueue extends StatefulWidget {
  TabUserQueue(
      {Key key,
      this.user,
      this.rootReference,
      this.activeSessionReference,
      this.nextSongsReference,
      this.nowPlayingReference,
      this.database})
      : super(key: key);
  final FirebaseDatabase database;
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
    newChild = widget.nextSongsReference.push();

    newChild.set({
      "Track": 'Spotify track object',
      'favsNumber': 0,
      "addedByUser": widget.user.uid,
      "favedByUsers": [""]
    });
  }

  void _deleteSong(DataSnapshot snapshot) {
    widget.nextSongsReference.child(snapshot.key).remove();
  }

  Future<Null> _markAsFavourite(DataSnapshot snapshot) async {
    final TransactionResult transactionResult = await widget.nextSongsReference
        .child(snapshot.key)
        .runTransaction((MutableData mutableData) async {
      List<dynamic> list =
          List.from(mutableData.value['favedByUsers'], growable: true);

      if (list.contains(widget.user.uid)) {
        mutableData.value['favsNumber'] = mutableData.value['favsNumber'] + 1;

        list.remove(widget.user.uid);

        mutableData.value['favedByUsers'] = list;

        return mutableData;
      } else {
        mutableData.value['favsNumber'] = mutableData.value['favsNumber'] - 1;

        list.add(widget.user.uid);

        mutableData.value['favedByUsers'] = list;

        return mutableData;
      }
    });
    if (transactionResult.committed) {
      print('Transaction committed successfully.');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: select the correct layout
    return Column(
      children: <Widget>[
        Text("Now playing"),
        Flexible(
          child: FirebaseAnimatedList(
            defaultChild: Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
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
            defaultChild: Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
            query: widget.nextSongsReference.orderByChild("favsNumber"),
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              bool _isDeleteable = false;
              bool _isFavorited = false;

              if (snapshot.value['addedByUser'] == widget.user.uid) {
                _isDeleteable = true;
              }

              if (List
                  .from(snapshot.value['favedByUsers'])
                  .contains(widget.user.uid)) {
                _isFavorited = true;
              }
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                    leading: Text("Image"),
                    title: Text("Data: ${snapshot.value['Track']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text((snapshot.value['favsNumber'] * -1).toString()),
                        _isDeleteable
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteSong(snapshot);
                                },
                              )
                            : IconButton(
                                icon: _isFavorited
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : Icon(Icons.favorite_border),
                                onPressed: () {
                                  _markAsFavourite(snapshot);
                                },
                              ),
                      ],
                    )),
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
