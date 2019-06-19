import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_epics/redux_epics.dart';
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
import 'package:questbee/serializers.dart';

void main() async {
  setupCrashlytics();

  // Create persistence
  final persistor = Persistor<AppState>(
    storage: SecureStorage(FlutterSecureStorage()),
    serializer: BuiltValueSerializer(),
    throttleDuration: Duration(seconds: 2),
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  final store =  Store<AppState>(
    rootReducer,
    initialState: await persistor.load() ?? AppState.initialState(),
    middleware: [
      thunkMiddleware,
      (Store<AppState> store, dynamic action, NextDispatcher next) {
        next(action);

        String debugString = "Action: ${action.runtimeType}";

        debugPrint(debugString);
        Crashlytics.instance.log(debugString);
      },
      NavigationMiddleware<AppState>(),
      persistor.createMiddleware(),
      EpicMiddleware<AppState>(rootEpic(firebaseMessaging)),
    ],
  );

  registerNotifications(store, firebaseMessaging, flutterLocalNotifications);

  runApp(App(store: store));
}

void setupCrashlytics() {
  FlutterError.onError = Crashlytics.instance.onError;
}

void registerNotifications(Store<AppState> store,
    FirebaseMessaging firebaseMessaging,
    FlutterLocalNotificationsPlugin flutterLocalNotifications) {
  // Register Firebase Messaging notifications

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

  // Local notifications setup

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
}

class BuiltValueSerializer implements StateSerializer<AppState> {
  @override
  AppState decode(Uint8List data) {
    if (data == null) {
      return null;
    }

    return serializers.deserialize(json.decode(String.fromCharCodes(data)));
  }

  @override
  Uint8List encode(AppState state) {
    return Uint8List.fromList(
      (json.encode(serializers.serialize(state))).codeUnits);
  }
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
