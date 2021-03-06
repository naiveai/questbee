import 'package:draw/draw.dart';
import 'package:questbee/reddit_config.dart' as redditConfig;
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/pages/questions_page.dart';
import 'package:questbee/pages/oauth_pages.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:questbee/utils/reddit_api_wrapper.dart';

import 'package:cloud_functions/cloud_functions.dart';

ThunkAction<AppState> startUserSignInAction(RedditAPIWrapper redditWrapper) {
  return (Store<AppState> store) {
    final reddit = redditWrapper.initializeWithoutCredentials();

    final authUrl = reddit.auth
      .url(redditConfig.permissionScopes, 'foobar')
      .replace(host: 'en.reddit.com')
      .toString();

    store.dispatch(NavigateToAction.pushNamedAndRemoveUntil(
      RedditOAuthLauncherPage.route,
      (_) => false,
      arguments: {'url': authUrl},
    ));
  };
}

ThunkAction<AppState> authenticateAfterFlowAction(
    Reddit reddit, FirebaseAuth auth, CloudFunctions functions,
    String code, Completer completer) {
  return (Store<AppState> store) async {
    await reddit.auth.authorize(code);

    final authFunction =
        functions.getHttpsCallable(
          functionName: "appRedditFirebaseAuth"
        );

    final result = await authFunction.call({
      "accessToken": reddit.auth.credentials.accessToken,
    });

    await auth.signInWithCustomToken(token: result.data['firebaseToken']);

    completer.complete();
  };
}

ThunkAction<AppState> signedInAction(Reddit reddit) {
  return (Store<AppState> store) {
    store.dispatch(
        StoreCredentialsAction(
            reddit.auth.credentials.toJson()));

    store.dispatch(NavigateToAction.pushNamedAndRemoveUntil(
      QuestionsPage.route,
      (_) => false,
    ));
  };
}

class StoreCredentialsAction {
  String credentials;

  StoreCredentialsAction(this.credentials);
}

class UsernameFetchedAction {
  String username;

  UsernameFetchedAction(this.username);
}
