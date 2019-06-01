import 'package:draw/draw.dart';

import 'package:questbee/reddit_config.dart' as redditConfig;

class RedditAPIWrapper {
  Reddit client;

  Reddit initializeWithoutCredentials() {
    client = Reddit.createWebFlowInstance(
      clientId: redditConfig.clientId, clientSecret: '',
      userAgent: redditConfig.userAgent,
      redirectUri: redditConfig.redirectUri,
    );

    return client;
  }

  Future<Reddit> initializeWithCredentials(String credentials) async {
    client = await Reddit.restoreAuthenticatedInstance(
      credentials,
      clientId: redditConfig.clientId, clientSecret: '',
      userAgent: redditConfig.userAgent,
    );

    return client;
  }
}
