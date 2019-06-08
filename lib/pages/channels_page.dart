import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:provider/provider.dart';
import 'package:questbee/utils/reddit_api_wrapper.dart';

import 'package:questbee/redux/channels/actions.dart';
import 'package:questbee/redux/preferences/actions.dart';

import 'package:questbee/models/channels.dart';

class ChannelsPage extends StatelessWidget {
  static final String route = '/channels';

  @override
  Widget build(BuildContext context) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return Scaffold(
      appBar: AppBar(title: Text('Channels')),
      body: StoreConnector<AppState, _ChannelViewModel>(
        distinct: true,
        converter: _ChannelViewModel.fromStore,
        onInit: (store) {
          store.dispatch(loadChannels(reddit));
        },
        builder: (BuildContext context, _ChannelViewModel vm) {
          if (vm.channels.length == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return ChannelList(
            channels: vm.channels,
            actionBuilder: (BuildContext context, ChannelModel channel) =>
              Switch(
                value: vm.subscribedChannels.contains(channel),
                onChanged: (value) => vm.onChannelTap(channel, !value),
              )
          );
        },
      ),
    );
  }
}

class _ChannelViewModel {
  _ChannelViewModel({this.channels, this.onChannelTap, this.subscribedChannels});

  final List<ChannelModel> channels;
  final List<ChannelModel> subscribedChannels;
  final Function onChannelTap;

  static _ChannelViewModel fromStore(Store<AppState> store) {
    return _ChannelViewModel(
      channels: store.state.channelsState.channels,
      subscribedChannels: store.state.preferencesState.subscribedChannels,
      onChannelTap: (channel, inSubscribed) {
        if (inSubscribed) {
          store.dispatch(UnsubscribedFromChannelAction(channel));
        } else {
          store.dispatch(SubscribedToChannelAction(channel));
        }
      },
    );
  }

  bool operator ==(other) {
    return (other is _ChannelViewModel && other.channels == channels &&
        other.subscribedChannels == subscribedChannels);
  }

  int get hashCode {
    return channels.hashCode ^ subscribedChannels.hashCode;
  }
}

class ChannelList extends StatelessWidget {
  ChannelList({Key key, this.channels, this.actionBuilder}) : super(key: key);

  final List<ChannelModel> channels;
  final Function(BuildContext, ChannelModel) actionBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (BuildContext context, int index) {
        var currentChannel = channels[index];

        return Card(
          child: ListTile(
            leading: CachedNetworkImage(
              placeholder: (_, __) => CircularProgressIndicator(),
              errorWidget: (_, __, error) => Icon(MdiIcons.imageBroken),
              imageUrl: currentChannel.iconImage.toString(),
            ),
            title: Text(currentChannel.humanName),
            trailing: actionBuilder(context, currentChannel),
          ),
        );
      },
    );
  }
}
