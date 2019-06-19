import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

import 'package:questbee/models/channels.dart';
import 'package:questbee/models/questions.dart';
import 'package:questbee/redux/channels/state.dart';
import 'package:questbee/redux/preferences/state.dart';
import 'package:questbee/redux/questions/state.dart';
import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/app_state.dart';

part 'serializers.g.dart';

@SerializersFor([
  ChannelModel,
  QuestionModel,
  QuestionBlockModel,
  ChannelsState,
  PreferencesState,
  QuestionsState,
  RedditState,
  AppState,
])
final Serializers serializers = _$serializers;
