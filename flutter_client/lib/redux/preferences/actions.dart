import 'package:draw/draw.dart';
import 'package:questbee/models/channels.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';

import 'package:questbee/redux/questions/actions.dart';

abstract class ChangeChannelSubscriptionAction {
  final ChannelModel channel;

  ChangeChannelSubscriptionAction(this.channel);
}

class SubscribedToChannelAction extends ChangeChannelSubscriptionAction {
  SubscribedToChannelAction(channel) : super(channel);
}

class UnsubscribedFromChannelAction extends ChangeChannelSubscriptionAction {
  UnsubscribedFromChannelAction(channel) : super(channel);
}
