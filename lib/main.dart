import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/root_reducer.dart';
import 'package:questbee/redux/deep_links/actions.dart';

import 'package:uni_links/uni_links.dart';

import 'package:questbee/app.dart';

void main() {
  // Create the store
  final store = Store<AppState>(
    rootReducer,
    initialState: AppState.initialState(),
    middleware: [
      thunkMiddleware,
      NavigationMiddleware<AppState>(),
    ],
  );

  // Register deeplinking
  getUriLinksStream().listen((Uri uri) {
    store.dispatch(deepLinkRecievedAction(uri));
  }, onError: (err) {
    store.dispatch(DeepLinkErrorAction(err));
  });

  // TODO: Rehydrate the app

  runApp(App(store: store));
}
