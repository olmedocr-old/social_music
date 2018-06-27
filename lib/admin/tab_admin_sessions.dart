import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'screen_admin.dart';

class TabAdminSession extends StatefulWidget {
  TabAdminSession(
      {Key key,
      this.user,
      this.activeSessionReference})
      : super(key: key);
  final FirebaseUser user;
  final DatabaseReference activeSessionReference;

  @override
  State createState() => new TabAdminSessionState();
}

class TabAdminSessionState extends State<TabAdminSession> {
  DatabaseReference newChild;

  void _addSession() {
    if (!(AdminScreenState.isSessionDataReady || AdminScreenState.isRemoteSessionDataReady)) {
      widget.activeSessionReference.set({
        "adminName": widget.user.displayName,
      });

      AdminScreenState.isSessionDataReady = true;
    } else {
      _generateSnackBar("Session already active, delete it first");
    }
  }

  void _removeSession() {
    widget.activeSessionReference.remove();

    AdminScreenState.isSessionDataReady = false;
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
            query: widget.activeSessionReference.limitToFirst(1),
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Image.network(widget.user.photoUrl),
                  title: Text("Session author: ${snapshot.value}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _removeSession,
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
              onPressed: _addSession,
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
