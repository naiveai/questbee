import 'package:draw/draw.dart';
import 'package:questbee/models/channels.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';

import 'package:questbee/redux/questions/actions.dart';

class SubscribedToChannelAction {
  final ChannelModel channel;

  SubscribedToChannelAction(this.channel);
}

class UnsubscribedFromChannelAction {
  final ChannelModel channel;

  UnsubscribedFromChannelAction(this.channel);
}
