import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

ThunkAction<AppState> deepLinkRecievedAction(Uri uri) {
  return (Store<AppState> store) {
    store.dispatch(NavigateToAction.push(
      "/" + uri.host,
      arguments: uri.queryParameters,
    ));
  };
}

class DeepLinkErrorAction {
  dynamic error;

  DeepLinkErrorAction(this.error);
}
