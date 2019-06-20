import * as functions from "firebase-functions";

const REDDIT_TOKEN_RETRIEVAL_URI = "https://www.reddit.com/api/v1/access_token";
let adminSdkInitialized = false;

export async function appRedditFirebaseAuthImpl(data: any, context: any) {
    if (!data.code && !data.error) {
        return {
            message: "Somehow, nothing was sent to us by Reddit. Please try again in a bit."
        };
    }

    const qs = await import("querystring");

    if (data.error) {
        return {
            redirect:
                functions.config().app.redirect + '?'
                + qs.stringify({"error": data.error})
        };
    }

    const {default: axios} = await import("axios");

    let redditTokenResponse;

    try {
        // TODO: Find a way to not do this manually.

        redditTokenResponse = await axios.post(
            REDDIT_TOKEN_RETRIEVAL_URI,
            qs.stringify({
                grant_type: "authorization_code",
                redirect_uri: "https://questbee-d85f9.web.app/redditAppRedirect",
                code: data.code,
            }),
            {
                auth: {
                    username: functions.config().app.clientid,
                    password: ''
                },
            }
        ).then((r) => {
            if (r.data.error) {
                throw new Error(r.data.error);
            }

            return r;
        });
    } catch (error) {
        console.error(`Error when retrieving access token: ${error.message}`);

        return {
            message: "Unfortunately, there was an error while signing in to your account. Please try again in a bit."
        };
    }

    const snoowrap = await import("snoowrap");

    const reddit = new snoowrap({
        userAgent: "Firebase:QuestBee Backend:v0.0.1 (by /u/eshansingh)",
        accessToken: redditTokenResponse.data.access_token,
    });

    const username = await reddit.getMe().name;

    const admin = await import("firebase-admin");

    if (!adminSdkInitialized) {
        admin.initializeApp();
        adminSdkInitialized = true;
    }

    // Attach the username as a claim so Security Rules can later
    // check based on it rather than the very long token itself.
    const token = await admin.auth().createCustomToken(username, {username});

    console.log(`Token created for Reddit user ${username}: ${token}`);

    return {
        redirect: functions.config().app.redirect + '?' + qs.stringify({
            ...redditTokenResponse.data,
            state: data.state,
            firebaseToken: token,
        })
    }
}
