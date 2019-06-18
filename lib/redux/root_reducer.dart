import 'package:redux_epics/redux_epics.dart';
import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/reducer.dart';
import 'package:questbee/redux/channels/reducer.dart';
import 'package:questbee/redux/questions/reducer.dart';
import 'package:questbee/redux/preferences/reducer.dart';
import 'package:questbee/redux/notifications/epics.dart';
import 'package:questbee/redux/deep_links/epics.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

AppState rootReducer(AppState state, dynamic action) {
  return state.rebuild((b) => b
    ..redditState.replace(redditReducer(state.redditState, action))
    ..channelsState.replace(channelsReducer(state.channelsState, action))
    ..questionsState.replace(questionsReducer(state.questionsState, action))
    ..preferencesState.replace(preferencesReducer(state.preferencesState, action))
  );
}

rootEpic(FirebaseMessaging firebaseMessaging) {
  return combineEpics(<Epic<AppState>>[
    channelSubscriptionNotificationsEpic(firebaseMessaging),
    uriLinksEpic,
  ]);
}
