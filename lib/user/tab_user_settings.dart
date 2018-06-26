import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:social_music/firebase_authentication.dart' as firebase_auth;

class TabUserSettings extends StatefulWidget {
  @override
  State createState() => new TabUserSettingsState();
}

class TabUserSettingsState extends State<TabUserSettings> {
  String spotifyCredetials = "";

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

  Future scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.spotifyCredetials = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print('The user did not grant the camera permission!');
        _generateSnackBar(
            "Error! Go to settings and grant access to the camera");
      } else {
        print('Unknown error_ $e');
        _generateSnackBar("Unknown error: $e");
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
      _generateSnackBar("The back button was pressed before scanning anything");
    } catch (e) {
      print('Unknown error_ $e');
      _generateSnackBar("Unknown error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Scan QR code"),
            onPressed: scanBarcode,
          ),
          Text(spotifyCredetials),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ],
      ),
    );
  }
}
