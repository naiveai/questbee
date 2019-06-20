import 'dart:convert';
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

  Future<Reddit> initializeWithCredentials(Map credentials) async {
    client = await Reddit.restoreAuthenticatedInstance(
      json.encode({
        ...credentials,
        "tokenEndpoint": "https://www.reddit.com/api/v1/access_token",
      }),
      clientId: redditConfig.clientId, clientSecret: '',
      userAgent: redditConfig.userAgent,
    );

    return client;
  }
}
