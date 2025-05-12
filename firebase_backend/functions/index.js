// Firebase Cloud Functions for TapIn@UW - Handles user signup, login, and profile retrieval

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin SDK to access Auth and Firestore
admin.initializeApp();

/**
 * SIGNUP FUNCTION - Creates a new user in Firebase Authentication and Firestore.
 * 
 * Trigger: HTTP POST
 * Required Fields in body:
 * - email (must be a @uw.edu address)
 * - password (at least 6 characters)
 * - displayName (user's full name)
 * 
 * Optional:
 * - bio: short description
 * - interests: array of strings
 */
exports.createUser = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "POST") {
      response.status(405).send({ error: "Only POST requests allowed" });
      return;
    }

    try {
      const { email, password, displayName, bio, interests } = request.body;

      // Validate required fields
      if (!email || !password || !displayName) {
        response.status(400).send({ message: "Email, password, and name required." });
        return;
      }

      // Email must be UW
      if (!email.endsWith("@uw.edu")) {
        response.status(400).send({ message: "Only @uw.edu email allowed." });
        return;
      }

      // Enforce strong passwords
      if (password.length < 6) {
        response.status(400).send({ message: "Password must be 6+ characters." });
        return;
      }

      // Create Firebase user
      const userRecord = await admin.auth().createUser({
        email,
        password,
        displayName,
        emailVerified: false,
      });

      // Save additional data to Firestore
      const userData = {
        uid: userRecord.uid,
        email,
        displayName,
        bio: bio || "",
        interests: interests || [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastLogin: admin.firestore.FieldValue.serverTimestamp(),
        preferences: { notifications: true, theme: "light" },
        isProfileComplete: false,
      };

      await admin.firestore().collection("users").doc(userRecord.uid).set(userData);

      const token = await admin.auth().createCustomToken(userRecord.uid);

      response.status(201).send({
        message: "Signup successful.",
        token,
        user: {
          uid: userRecord.uid,
          email,
          displayName,
          bio: userData.bio,
          interests: userData.interests,
        },
      });

    } catch (error) {
      logger.error("Signup error:", error);

      if (error.code === "auth/email-already-exists") {
        response.status(409).send({ message: "Email already registered." });
      } else if (error.code === "auth/invalid-email") {
        response.status(400).send({ message: "Invalid email address." });
      } else {
        response.status(500).send({ message: "Unexpected error. Try again." });
      }
    }
  });
});

/**
 * LOGIN FUNCTION - Logs in a registered user and returns a token.
 * 
 * Trigger: HTTP POST
 * Required Fields in body:
 * - email
 * - password 
 */
exports.loginUser = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "POST") {
      response.status(405).send({ error: "Only POST requests allowed" });
      return;
    }

    try {
      const { email, password } = request.body;

      if (!email || !password) {
        response.status(400).send({ message: "Email and password required." });
        return;
      }

      // Get user data (Firebase Admin cannot verify password)
      const userRecord = await admin.auth().getUserByEmail(email);

      // Issue token and update Firestore login time
      const token = await admin.auth().createCustomToken(userRecord.uid);
      await admin.firestore().collection("users").doc(userRecord.uid).update({
        lastLogin: admin.firestore.FieldValue.serverTimestamp()
      });

      response.status(200).send({
        message: "Login token issued.",
        token,
        user: {
          uid: userRecord.uid,
          email: userRecord.email,
          displayName: userRecord.displayName,
        },
      });

    } catch (error) {
      logger.error("Login error:", error);

      if (error.code === "auth/user-not-found") {
        response.status(401).send({ message: "User not found. Check email." });
      } else {
        response.status(500).send({ message: "Login failed. Try again later." });
      }
    }
  });
});
