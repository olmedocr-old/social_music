import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'firebase_authentication.dart' as firebase_auth;

class TabUserSettings extends StatefulWidget {
  @override
  State createState() => new TabUserSettingsState();
}

class TabUserSettingsState extends State<TabUserSettings> {
  String barcode = "";

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
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text("Log in using Google"),
                onPressed: () {
                  firebase_auth
                      .handleSignIn()
                      .then((onValue) {})
                      .catchError((e) => print(e));
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              RaisedButton(
                child: Text("Log out from Google"),
                onPressed: () {
                  firebase_auth
                      .handleSignOut()
                      .then((onValue) {})
                      .catchError((e) => print(e));
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
          ),
          RaisedButton(
            child: Text("Scan QR code"),
            onPressed: scanBarcode,
          ),
          Text(barcode),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
          RaisedButton(
            child: Text("Auth to spotify"),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Future scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
