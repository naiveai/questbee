import * as functions from "firebase-functions";

import {appRedditFirebaseAuthImpl} from "./redditFirebaseAuth";

export const appRedditFirebaseAuth = functions.https.onCall(appRedditFirebaseAuthImpl);
