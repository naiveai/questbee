import 'package:flutter/foundation.dart';

import 'package:questbee/models/channels.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'state.g.dart';

abstract class ChannelsState implements Built<ChannelsState, ChannelsStateBuilder> {
  static Serializer<ChannelsState> get serializer => _$channelsStateSerializer;

  BuiltList<ChannelModel> get channels;

  factory ChannelsState.initialState() {
    return ChannelsState((b) => b.channels.replace(BuiltList<ChannelModel>()));
  }

  ChannelsState._();
  factory ChannelsState([void Function(ChannelsStateBuilder) updates]) = _$ChannelsState;
}
