import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'tab_admin_sessions.dart';

import 'package:social_music/spotify_authentication.dart';

bool isLoginDataReady = false;
bool isSessionDataReady = false;

class TabAdminSettings extends StatefulWidget {
  @override
  State createState() => new TabAdminSettingsState();
}

class TabAdminSettingsState extends State<TabAdminSettings> {
  final String clientId = '307123396078430cbeba39351bfb014c';
  final String clientSecret = '34321de4e92340e9919e033b7629ef55';
  final String redirectUrl = null; //TODO: raulolmedo.com/callback
  final List<String> scopes = ["user-library-read"];

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

  void _openWebview() async {
    bool success = await Navigator.of(context).push(new MaterialPageRoute<bool>(
          builder: (BuildContext context) => new SpotifyLoginWebViewPage(
                clientId: this.clientId,
                clientSecret: this.clientSecret,
                redirectUrl: this.redirectUrl == null
                    ? "https://kunstmaan.github.io/flutter_slack_oauth/success.html"
                    : this.redirectUrl,
                scopes: this.scopes,
              ),
        ));

    if (success == null) {
      _generateSnackBar("Webview closed");
    } else if (success == false) {
      _generateSnackBar("Login failed");
    } else if (success) {
      isLoginDataReady = true;
      _generateSnackBar("Success");
    }
  }

  void _generateQr() async {
    Directory tempDir = await getTemporaryDirectory();
    File credentialsFile = File('${tempDir.path}/credentials');

    print(credentialsFile.readAsStringSync());

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: QrImage(
                  version: 18,
                  data: base64.encode(utf8.encode("{\"token\":" +
                      credentialsFile.readAsStringSync() +
                      ",\"adminId\":" +
                      "\"" +
                      userId +
                      "\"" +
                      "}")),
                  size: 300.0,
                ),
              ),
            ),
          );
        });
  }

  void _qrButtonPressed() {
    setState(() {
      if (isLoginDataReady && isSessionDataReady) {
        _generateQr();
      } else if (!isLoginDataReady) {
        _generateSnackBar(
            'You must login first into Spotify to generate the QR code');
      } else if (!isSessionDataReady) {
        _generateSnackBar(
            "You must create a session before generating the QR code");
      } else {
        _generateSnackBar(
            "You must login into Spotify and create a session to generate the QR code");
      }
    });
  }

  @override
  void initState() {
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
              _openWebview();
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          RaisedButton(
            child: Text("Generate QR"),
            onPressed: _qrButtonPressed,
          ),
        ],
      ),
    );
  }
}
