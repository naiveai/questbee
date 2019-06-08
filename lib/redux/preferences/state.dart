import 'package:flutter/foundation.dart';

import 'package:questbee/models/channels.dart';

@immutable
class PreferencesState {
  PreferencesState({this.subscribedChannels});

  final List<ChannelModel> subscribedChannels;

  factory PreferencesState.initialState() {
    return PreferencesState(
      subscribedChannels: [],
    );
  }

  static PreferencesState fromJson(dynamic json) {
    if (json == null) { return PreferencesState.initialState(); }

    return PreferencesState(
      subscribedChannels:
          List<ChannelModel>.from(
              json['subscribedChannels'].map(ChannelModel.fromJson).toList()),
    );
  }

  Map toJson() {
    return {
      'subscribedChannels': subscribedChannels.map((c) => c.toJson()).toList(),
    };
  }
}
