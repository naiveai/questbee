import 'package:flutter/foundation.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'state.g.dart';

abstract class RedditState implements Built<RedditState, RedditStateBuilder> {
  static Serializer<RedditState> get serializer => _$redditStateSerializer;

  @nullable
  String get credentials;

  factory RedditState.initialState() {
    return RedditState();
  }

  RedditState._();
  factory RedditState([void Function(RedditStateBuilder) updates]) = _$RedditState;
}
