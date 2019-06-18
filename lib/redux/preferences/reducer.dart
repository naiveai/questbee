import 'package:questbee/redux/preferences/state.dart';
import 'package:questbee/redux/preferences/actions.dart';

PreferencesState preferencesReducer(PreferencesState state, dynamic action) {
  switch(action.runtimeType) {
    case SubscribedToChannelAction:
      return state.rebuild((b) =>
        b.subscribedChannels.add(action.channel));
    case UnsubscribedFromChannelAction:
      return state.rebuild((b) =>
        b.subscribedChannels.remove(action.channel));
    default:
      return state;
  }
}
