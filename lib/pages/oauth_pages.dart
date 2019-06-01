import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:after_layout/after_layout.dart';

import 'package:questbee/utils/reddit_api_wrapper.dart';
import 'package:provider/provider.dart';

import 'package:questbee/pages/channels_page.dart';

import 'dart:async';

class RedditOAuthLauncherPage extends StatefulWidget {
  static final String route = '/reddit-oauth-launcher';

  @override
  _RedditOAuthLauncherPageState createState() =>
      _RedditOAuthLauncherPageState();
}

class _RedditOAuthLauncherPageState extends State<RedditOAuthLauncherPage>
    with AfterLayoutMixin<RedditOAuthLauncherPage> {
  @override
  void afterFirstLayout(BuildContext context) {
    _launchAuthUrl(context);
  }

  _launchAuthUrl(BuildContext context) async {
    String url = (ModalRoute.of(context).settings.arguments
        as Map<String, String>)['url'];

    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement "Back to Login" in case something goes wrong here

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Launching Reddit authorization...'),
            SizedBox(height: 5.0),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class RedditOAuthRedirectPage extends StatelessWidget {
  static final String route = '/reddit-oauth-redirect';

  Widget _buildPermissionsDenied() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('You denied permissions :('),
        Row(
          children: <Widget>[
            RaisedButton(child: Text('Changed your mind?'), onPressed: null),
            RaisedButton(child: Text('Quit'), onPressed: null),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionsAllowed(BuildContext context, String code) {
    return Center(
      child: StoreBuilder<AppState>(
        onInitialBuild: (store) {
          var client = Provider.of<RedditAPIWrapper>(context).client;

          final authCompleter = Completer();

          store.dispatch(
              authenticateWithCodeAction(client, code, authCompleter));

          authCompleter.future.then((_) {
            store.dispatch(signedInAction());
          });
        },
        builder: (context, store) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Logging you in...'),
              SizedBox(height: 5.0),
              CircularProgressIndicator()
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: args['error'] == 'access_denied'
          ? _buildPermissionsDenied()
          : _buildPermissionsAllowed(context, args['code']),
    );
  }
}
