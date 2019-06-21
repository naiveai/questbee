import 'package:flutter/foundation.dart';
import 'package:questbee/pages/oauth_pages.dart';

final clientId = "SlOSFuJWe_E7Cg";
final redirectUri = Uri.parse("questbee:/${RedditOAuthRedirectPage.route}");
final permissionScopes = [
  "vote",
  "submit",
  "read",
  "identity",
  "edit",
  "flair",
  "history"
];
final userAgent = "${defaultTargetPlatform.toString().substring(15)}:com.eshan.questbee:v0.0.1 (by /u/eshansingh)";
