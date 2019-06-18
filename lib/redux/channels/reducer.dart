import 'package:questbee/redux/channels/actions.dart';
import 'package:questbee/redux/channels/state.dart';

ChannelsState channelsReducer(ChannelsState state, dynamic action) {
  switch(action.runtimeType) {
    case ChannelsLoadedAction:
      return ChannelsState((b) => b.channels.replace(action.channels));
    default:
      return state;
  }
}
