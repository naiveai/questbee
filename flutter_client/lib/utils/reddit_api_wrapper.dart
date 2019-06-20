import 'package:draw/draw.dart';

import 'package:questbee/reddit_config.dart' as redditConfig;

class RedditAPIWrapper {
  Reddit client;

  Reddit initializeWithoutCredentials() {
    client = Reddit.createInstalledFlowInstance(
      clientId: redditConfig.clientId,
      userAgent: redditConfig.userAgent,
      redirectUri: redditConfig.backendRedirectUri,
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
