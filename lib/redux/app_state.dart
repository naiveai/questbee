import 'package:flutter/foundation.dart';

import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/channels/state.dart';
import 'package:questbee/redux/questions/state.dart';
import 'package:questbee/redux/preferences/state.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'app_state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
  static Serializer<AppState> get serializer => _$appStateSerializer;

  RedditState get redditState;
  ChannelsState get channelsState;
  QuestionsState get questionsState;
  PreferencesState get preferencesState;

  factory AppState.initialState() {
    return AppState((b) => b
      ..redditState.replace(RedditState.initialState())
      ..channelsState.replace(ChannelsState.initialState())
      ..questionsState.replace(QuestionsState.initialState())
      ..preferencesState.replace(PreferencesState.initialState())
    );
  }

  AppState._();
  factory AppState([void Function(AppStateBuilder) updates]) = _$AppState;
}
