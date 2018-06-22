import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

/// A webview used for the sign in with spotify flow.
class SpotifyLoginWebViewPage extends StatefulWidget {
  const SpotifyLoginWebViewPage({
    @required this.clientId,
    @required this.clientSecret,
    @required this.redirectUrl,
    this.scopes,
  });

  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;

  @override
  _SpotifyLoginWebViewPageState createState() =>
      new _SpotifyLoginWebViewPageState();
}

class _SpotifyLoginWebViewPageState extends State<SpotifyLoginWebViewPage> {
  bool setupUrlChangedListener = false;

  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    final String clientId = widget.clientId;
    final String clientSecret = widget.clientSecret;
    final String redirectUrl = widget.redirectUrl;
    final List<String> scopes = widget.scopes;
    final authorizationEndpoint =
        Uri.parse("https://accounts.spotify.com/authorize");
    final tokenEndpoint = Uri.parse("https://accounts.spotify.com/api/token");

    var grant = new oauth2.AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret);

    if (!setupUrlChangedListener) {
      flutterWebviewPlugin.onUrlChanged.listen((String changedUrl) async {
        if (changedUrl.startsWith(redirectUrl)) {
          Uri uri = new Uri().resolve(changedUrl);
          oauth2.Client client =
              await grant.handleAuthorizationResponse(uri.queryParameters);

          // Save credentials on temporal directory
          Directory tempDir = await getTemporaryDirectory();
          File credentialsFile = new File('${tempDir.path}/credentials');
          await credentialsFile.writeAsString(client.credentials.toJson());

          client.close();
          grant.close();

          Navigator.of(context).pop(true);
        }
      });
      setupUrlChangedListener = true;
    }

    return new WebviewScaffold(
        appBar: new AppBar(
          title: new Text("Log in to Spotify"),
        ),
        url: grant
            .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
            .toString());
  }
}
