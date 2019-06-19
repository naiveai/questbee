import 'package:questbee/models/channels.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'state.g.dart';

abstract class PreferencesState implements Built<PreferencesState, PreferencesStateBuilder> {
  static Serializer<PreferencesState> get serializer => _$preferencesStateSerializer;

  BuiltList<ChannelModel> get subscribedChannels;

  factory PreferencesState.initialState() {
    return PreferencesState((b) => b
      .subscribedChannels.replace(BuiltList<ChannelModel>()));
  }

  PreferencesState._();
  factory PreferencesState([void Function(PreferencesStateBuilder) updates]) = _$PreferencesState;
}
