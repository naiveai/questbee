import 'package:flutter/foundation.dart';

import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/channels/state.dart';
import 'package:questbee/redux/questions/state.dart';
import 'package:questbee/redux/preferences/state.dart';

@immutable
class AppState {
  AppState({
    this.redditState,
    this.channelsState,
    this.questionsState,
    this.preferencesState,
  });

  final RedditState redditState;
  final ChannelsState channelsState;
  final QuestionsState questionsState;
  final PreferencesState preferencesState;

  factory AppState.initialState() {
    return AppState(
      redditState: RedditState.initialState(),
      channelsState: ChannelsState.initialState(),
      questionsState: QuestionsState.initialState(),
      preferencesState: PreferencesState.initialState(),
    );
  }

  static AppState fromJson(dynamic json) {
    if (json == null) { return AppState.initialState(); }

    return AppState(
      redditState: RedditState.fromJson(json['redditState']),
      channelsState: ChannelsState.initialState(),
      questionsState: QuestionsState.initialState(),
      preferencesState: PreferencesState.fromJson(json['preferencesState']),
    );
  }

  Map toJson() {
    return {
      'redditState': redditState.toJson(),
      'preferencesState': preferencesState.toJson(),
    };
  }
}
