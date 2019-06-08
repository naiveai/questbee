import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/reducer.dart';
import 'package:questbee/redux/channels/reducer.dart';
import 'package:questbee/redux/questions/reducer.dart';
import 'package:questbee/redux/preferences/reducer.dart';

AppState rootReducer(AppState state, dynamic action) {
  return AppState(
    redditState: redditReducer(state.redditState, action),
    channelsState: channelsReducer(state.channelsState, action),
    questionsState: questionsReducer(state.questionsState, action),
    preferencesState: preferencesReducer(state.preferencesState, action),
  );
}
