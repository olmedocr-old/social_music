import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'spotify_authentication.dart' as spotify_auth;

class TabAdminSettings extends StatefulWidget {
  @override
  State createState() => new TabAdminSettingsState();
}

class TabAdminSettingsState extends State<TabAdminSettings> {
  bool _isDataReady;

  void _toggleQrButton() {
    setState(() {
      _isDataReady ? _generateQr() : _generateSnackBar();
    });
  }

  void _generateSnackBar() {
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child:
            Text('You must log in first into Spotify to generate the QR code'),
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

  void _generateQr() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: QrImage(
                  data: "1234567890",
                  size: 300.0,
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _isDataReady = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Login into Spotify"),
            onPressed: () {
              print("Spotify login");
              spotify_auth
                  .handleSignIn()
                  .then((onValue) {})
                  .catchError((e) => print(e));
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          RaisedButton(
            child: Text("Generate QR"),
            onPressed: _toggleQrButton,
          ),
        ],
      ),
    );
  }
}
