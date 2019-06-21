import * as functions from "firebase-functions";

let adminSdkInitialized = false;

export async function appRedditFirebaseAuthImpl(data: any, context: any) {
    if(!data.accessToken) {
        throw new functions.https.HttpsError("unauthenticated", "No Reddit access token was passed in");
    }

    const snoowrap = await import("snoowrap");

    let username;

    try {
        const reddit = new snoowrap({
            userAgent: "Firebase:QuestBee Backend:v0.0.1 (by /u/eshansingh)",
            accessToken: data.accessToken,
        });

        username = await reddit.getMe().name;
    } catch (error) {
        throw new functions.https.HttpsError("unknown", `Error occured while checking credentials: ${error}`);
    }

    const admin = await import("firebase-admin");

    if (!adminSdkInitialized) {
        admin.initializeApp();
        adminSdkInitialized = true;
    }

    // Usernames are not case-sensitive in Reddit, but tokens in Firebase are.
    const token = await admin.auth().createCustomToken(username.toLowerCase());

    console.log(`Token created for Reddit user ${username}: ${token}`);

    return {
        "firebaseToken": token,
    };
}
