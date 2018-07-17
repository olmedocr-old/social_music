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
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:spotify/spotify_io.dart' as spotifyLib;
//FIXME: spotify lib do not refresh the token and results in a forbidden error when using the API
//TODO: fix all layouts

class UserScreen extends StatefulWidget {
  UserScreen({Key key, this.title, this.app, this.user}) : super(key: key);
  final String title;
  final FirebaseApp app;
  final FirebaseUser user;

  @override
  State createState() => UserScreenState();
}
//TODO: reformat code to clarify this screen

class UserScreenState extends State<UserScreen> {
  bool hasScanned = false;

  FirebaseDatabase database;
  DatabaseError _error;
  DatabaseReference nextSongsReference;
  DatabaseReference nowPlayingReference;
  DatabaseReference newChild;
  StreamSubscription<Event> nextSongsSubscription;
  StreamSubscription<Event> nowPlayingSubscription;
  spotifyLib.SpotifyApi spotify;

  void _loginSpotify(var token) {
    spotify = spotifyLib.SpotifyApi(spotifyLib.SpotifyApiCredentials
        .authorizationCode(
            token["accessToken"], token["refreshToken"], token["expiration"]));
    print(spotify.toString());
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
      Map<String, dynamic> map =
          json.decode(utf8.decode(base64.decode(barcode)));
      _setupListeners(map["adminId"]);
      _loginSpotify(map["token"]);
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

  Widget _iOSDialog(
      BuildContext context, String title, String body, String button) {
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
              child:
                  new Text(button),
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

  Widget _androidDialog(
      BuildContext context, String title, String body, String button) {
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
            child: new Text(button, style: Theme.of(context).textTheme.button),
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

  Future<Widget> _showDialog(
      BuildContext context, String title, String body, String button) async {
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

  void _addSong(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                  child: Column(
                children: <Widget>[
                  Text('Paste Spotify link of the song here'),
                  TextField(
                    autocorrect: false,
                    onSubmitted: (String input) {
                      newChild = this.nextSongsReference.push();
                      print('User input: $input');
                      _getSong(input);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )),
            ),
          );
        });
  }

  void _getSong(String songUrl) async {
    spotifyLib.Track track = await spotify.tracks.get(songUrl.substring(31));
    newChild.set({
      "track": {
        "name": track.name,
        "artist": track.artists[0].name,
        "image": track.album.images[0].url,
        "id": track.id,
      },
      'favsNumber': 0,
      "addedByUser": widget.user.uid,
      "favedByUsers": [""]
    });
  }

  void _openSearch() {
    //TODO: implement a search engine to avoid searching for songs outside the app
  }

  void _deleteSong(DataSnapshot snapshot) {
    this.nextSongsReference.child(snapshot.key).remove();
  }

  Future<Null> _markAsFavourite(DataSnapshot snapshot) async {
    final TransactionResult transactionResult = await this
        .nextSongsReference
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
        backgroundColor: Theme.of(context).accentColor,
        body: widget,
      );
    } else {
      return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            children: <Widget>[
              Text("Now playing"),
              Flexible(
                child: FirebaseAnimatedList(
                  defaultChild: Platform.isIOS
                      ? CupertinoActivityIndicator()
                      : CircularProgressIndicator(),
                  query: this.nowPlayingReference,
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
                  query: this.nextSongsReference.orderByChild("favsNumber"),
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
                          leading: Image.network(
                            snapshot.value['track']['image'],
                            width: 64.0,
                            height: 64.0,
                          ),
                          title: Text("${snapshot.value['track']['name']}"),
                          subtitle: Text(snapshot.value['track']['artist']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text((snapshot.value['favsNumber'] * -1)
                                  .toString()),
                              _isDeleteable
                                  ? IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteSong(snapshot);
                                      },
                                    )
                                  : IconButton(
                                      icon: _isFavorited
                                          ? Icon(Icons.favorite,
                                              color: Colors.red)
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
                    onPressed: () {
                      _addSong(context);
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
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
