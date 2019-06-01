import 'package:questbee/redux/channels/actions.dart';
import 'package:questbee/redux/channels/state.dart';

ChannelsState channelsReducer(ChannelsState state, dynamic action) {
  if (action is ChannelsLoadedAction) {
    return ChannelsState(channels: action.channels);
  }

  return state;
}
