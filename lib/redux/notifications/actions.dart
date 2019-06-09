import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

ThunkAction<AppState> notificationForeground(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    print("onMessage: ${message}");
  };
}

ThunkAction<AppState> notificationBackground(Map<String, dynamic> message) {
  return (Store<AppState> store) {
    print("onMessage: ${message}");
  };
}
