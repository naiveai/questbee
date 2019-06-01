import 'package:flutter/foundation.dart';

import 'package:questbee/models/channels.dart';

@immutable
class ChannelsState {
  ChannelsState({this.channels});

  final List<ChannelModel> channels;

  factory ChannelsState.initialState() {
    return ChannelsState(channels: []);
  }
}
