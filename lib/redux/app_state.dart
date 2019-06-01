import 'package:flutter/foundation.dart';

import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/channels/state.dart';

@immutable
class AppState {
  AppState({
    this.redditState,
    this.channelsState,
  });

  final RedditState redditState;
  final ChannelsState channelsState;

  factory AppState.initialState() {
    return AppState(
      redditState: RedditState.initialState(),
      channelsState: ChannelsState.initialState(),
    );
  }
}
