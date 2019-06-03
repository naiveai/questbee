import 'package:flutter/foundation.dart';

import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/channels/state.dart';
import 'package:questbee/redux/questions/state.dart';

@immutable
class AppState {
  AppState({
    this.redditState,
    this.channelsState,
    this.questionsState,
  });

  final RedditState redditState;
  final ChannelsState channelsState;
  final QuestionsState questionsState;

  factory AppState.initialState() {
    return AppState(
      redditState: RedditState.initialState(),
      channelsState: ChannelsState.initialState(),
      questionsState: QuestionsState.initialState(),
    );
  }

  static AppState fromJson(dynamic json) {
    if (json != null) {
      return AppState(
        redditState: RedditState.fromJson(json['redditState']),
        channelsState: ChannelsState.initialState(),
        questionsState: QuestionsState.initialState(),
      );
    }

    return null;
  }

  Map toJson() {
    return {
      'redditState': redditState.toJson(),
    };
  }
}
