import 'package:questbee/redux/preferences/state.dart';
import 'package:questbee/redux/preferences/actions.dart';

PreferencesState preferencesReducer(PreferencesState state, dynamic action) {
  if (action is SubscribedToChannelAction) {
    return PreferencesState(
      subscribedChannels: state.subscribedChannels + [action.channel],
    );
  } else if (action is UnsubscribedFromChannelAction) {
    return PreferencesState(
      subscribedChannels: state.subscribedChannels.where((c) => c !=
          action.channel).toList(),
    );
  }

  return state;
}
