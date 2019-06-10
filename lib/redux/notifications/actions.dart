import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

ThunkAction<AppState> notificationForeground(
    Map<String, dynamic> message,
    FlutterLocalNotificationsPlugin flutterLocalNotifications) {
  return (Store<AppState> store) {
    print("onForeground: ${message}");

    flutterLocalNotifications.show(
      // We need to pass in an integer id for this notification, and if we pass
      // in the same one as a previous notification that one will get hidden by
      // this one. Technically if we recieve two or more notifications in the
      // same millisecond, this will mean only one of them will show, but that
      // is vanishingly unlikely for our usecase.
      DateTime.now().millisecondsSinceEpoch,
      message['notification']['title'], '',
      NotificationDetails(
        AndroidNotificationDetails(
          'subscribedChannels',
          'Subscribed Channels',
          'Notifications for new questions on your subscribed channels',
          style: AndroidNotificationStyle.BigText,
          styleInformation: BigTextStyleInformation(
            message['notification']['body'],
          ),
          importance: Importance.High,
          priority: Priority.High,
        ),
        IOSNotificationDetails(),
      ),
      payload: json.encode(message),
    );
  };
}

ThunkAction<AppState> notificationClicked(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    // This is a stub for now. Since the app is launched like normal, we
    // don't really have to do anything for the current simple usecase. More
    // complicated behaviour is predicated on FCM, Flutter, and its plugins to
    // be updated furter. So this is simply a TODO.

    print("onBackground: ${message}");
  };
}
