import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:convert';

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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:questbee/app.dart';

void main() async {
  setupCrashlytics();

  final store = await initStore();
  registerDeeplinking(store);
  registerNotifications(store);

  runApp(App(store: store));
}

void setupCrashlytics() {
  FlutterError.onError = Crashlytics.instance.onError;
}

Future<Store<AppState>> initStore() async {
  // Create persistence
  final persistor = Persistor<AppState>(
    storage: SecureStorage(FlutterSecureStorage()),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
    throttleDuration: Duration(seconds: 2),
  );

  return Store<AppState>(
    rootReducer,
    initialState: await persistor.load(),
    middleware: [
      thunkMiddleware,
      NavigationMiddleware<AppState>(),
      persistor.createMiddleware(),
    ],
  );
}

void registerDeeplinking(Store<AppState> store) {
  getUriLinksStream().listen((Uri uri) {
    store.dispatch(deepLinkRecievedAction(uri));
  }, onError: (err) {
    store.dispatch(DeepLinkErrorAction(err));
  });
}

void registerNotifications(Store<AppState> store) {
  // Local notifications setup
  final flutterLocalNotifications = FlutterLocalNotificationsPlugin();

  flutterLocalNotifications.initialize(
    InitializationSettings(
      AndroidInitializationSettings('@mipmap/ic_launcher'),
      IOSInitializationSettings(),
    ),
    onSelectNotification: (messageJson) {
      store.dispatch(
        notificationClicked(json.decode(messageJson)));
    },
  );

  // Register Firebase Messaging notifications
  final firebaseMessaging = FirebaseMessaging();

  firebaseMessaging.getToken().then((String token) {
    debugPrint("Firebase Messaging token: $token");
  });

  firebaseMessaging.requestNotificationPermissions();

  firebaseMessaging.configure(
    onMessage: (message) {
      store.dispatch(
          notificationForeground(message, flutterLocalNotifications));
    },
    onResume: (message) {
      store.dispatch(
        notificationClicked(message));
    },
    onLaunch: (message) {
      store.dispatch(
        notificationClicked(message));
    },
  );
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
