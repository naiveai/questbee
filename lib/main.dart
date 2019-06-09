import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/root_reducer.dart';
import 'package:questbee/redux/deep_links/actions.dart';
import 'package:questbee/redux/notifications/actions.dart';

import 'package:uni_links/uni_links.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:questbee/app.dart';

void main() async {
  // Create persistence
  final persistor = Persistor<AppState>(
    storage: SecureStorage(FlutterSecureStorage()),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
    throttleDuration: Duration(seconds: 2),
  );

  // Create the store
  final store = Store<AppState>(
    rootReducer,
    initialState: await persistor.load(),
    middleware: [
      thunkMiddleware,
      NavigationMiddleware<AppState>(),
      persistor.createMiddleware(),
    ],
  );

  // Register deeplinking
  getUriLinksStream().listen((Uri uri) {
    store.dispatch(deepLinkRecievedAction(uri));
  }, onError: (err) {
    store.dispatch(DeepLinkErrorAction(err));
  });

  // Register Firebase Messaging notifications
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _firebaseMessaging.getToken().then((String token) {
    debugPrint("Firebase Messaging token: $token");
  });

  _firebaseMessaging.requestNotificationPermissions();

  _firebaseMessaging.configure(
    onMessage: (message) { store.dispatch(notificationForeground(message)); },
    onResume: (message) { store.dispatch(notificationBackground(message)); },
    onLaunch: (message) { store.dispatch(notificationBackground(message)); },
  );

  runApp(App(store: store));
}

class SecureStorage implements StorageEngine {
  final FlutterSecureStorage secureStorageInstance;

  SecureStorage(this.secureStorageInstance);

  @override
  Future<Uint8List> load() async {
    String value = await secureStorageInstance.read(key: 'state');

    if (value != null) {
      return Uint8List.fromList(value.codeUnits);
    }

    return null;
  }

  @override
  Future<void> save(Uint8List data) async {
    await secureStorageInstance.write(key: 'state',
        value: String.fromCharCodes(data));
  }
}
