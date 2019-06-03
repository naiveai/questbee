import 'package:draw/draw.dart';
import 'package:questbee/reddit_config.dart' as redditConfig;
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/pages/channels_page.dart';
import 'package:questbee/pages/oauth_pages.dart';

ThunkAction<AppState> startUserSignInAction(Reddit reddit) {
  return (Store<AppState> store) {
    var authUrl = reddit.auth
      .url(redditConfig.permissionScopes, 'foobar')
      .replace(host: 'en.reddit.com')
      .toString();

    store.dispatch(NavigateToAction.push(
      RedditOAuthLauncherPage.route,
      arguments: {'url': authUrl}
    ));
  };
}

ThunkAction<AppState> authenticateWithCodeAction(Reddit reddit, String code, Completer completer) {
  return (Store<AppState> store) async {
    await reddit.auth.authorize(code);

    completer.complete();
  };
}

ThunkAction<AppState> signedInAction(Reddit reddit) {
  return (Store<AppState> store) {
    store.dispatch(
        StoreCredentialsAction(
            reddit.auth.credentials.toJson()));

    store.dispatch(NavigateToAction.pushNamedAndRemoveUntil(
      ChannelsPage.route,
      (_) => false,
    ));
  };
}

class StoreCredentialsAction {
  String credentials;

  StoreCredentialsAction(this.credentials);
}
