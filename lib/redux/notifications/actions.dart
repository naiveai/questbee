import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

ThunkAction<AppState> notificationOnMessage(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    print("onMessage: ${message}");
  };
}

ThunkAction<AppState> notificationOnResume(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    print("onMessage: ${message}");
  };
}

ThunkAction<AppState> notificationOnLaunch(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    print("onMessage: ${message}");
  };
}
