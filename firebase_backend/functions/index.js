/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * Creates a new user in Firebase Authentication and Firestore
 * Required fields in request body:
 * - email: string (must be @uw.edu)
 * - password: string
 * - displayName: string
 * Optional fields:
 * - bio: string
 * - interests: string[]
 */
exports.createUser = onRequest(async (request, response) => {
  // Only allow POST requests
  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const {email, password, displayName, bio, interests} = request.body;

    // Validate required fields
    if (!email || !password || !displayName) {
      response.status(400).send({
        error: "Missing required fields",
        message: "Email, password, and displayName are required",
      });
      return;
    }

    // Validate UW email domain
    if (!email.endsWith("@uw.edu")) {
      response.status(400).send({
        error: "Invalid email domain",
        message: "Only @uw.edu email addresses are allowed",
      });
      return;
    }

    // Create the user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });

    // Create a user document in Firestore
    const userData = {
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Optional fields
      bio: bio || "",
      interests: interests || [],
      preferences: {
        notifications: true,
        theme: "light"
      },
    };

    // Store the user data in Firestore
    await admin.firestore()
        .collection("users")
        .doc(userRecord.uid)
        .set(userData);

    // Return success response
    response.status(201).send({
      message: "User created successfully",
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        bio: userData.bio,
        interests: userData.interests,
      },
    });
  } catch (error) {
    logger.error("Error creating user:", error);
    
    // Handle specific error cases
    if (error.code === "auth/email-already-exists") {
      response.status(409).send({
        error: "Email already exists",
        message: "A user with this email already exists",
      });
    } else if (error.code === "auth/invalid-email") {
      response.status(400).send({
        error: "Invalid email",
        message: "The provided email is invalid",
      });
    } else if (error.code === "auth/weak-password") {
      response.status(400).send({
        error: "Weak password",
        message: "The password is too weak",
      });
    } else {
      response.status(500).send({
        error: "Internal server error",
        message: "An error occurred while creating the user",
      });
    }
  }
});

/**
 * Authenticates a user and returns their data
 * Required fields in request body:
 * - email: string
 * - password: string
 */
exports.login = onRequest(async (request, response) => {
  // Only allow POST requests
  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const {email, password} = request.body;

    // Validate required fields
    if (!email || !password) {
      response.status(400).send({
        error: "Missing required fields",
        message: "Email and password are required",
      });
      return;
    }

    // Sign in the user with Firebase Auth to validate credentials
    const auth = admin.auth();
    const userCredential = await auth.signInWithEmailAndPassword(email, password);

    // Get the user's data from Firestore
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(userCredential.user.uid)
        .get();

    if (!userDoc.exists) {
      response.status(404).send({
        error: "User not found",
        message: "User data not found in database",
      });
      return;
    }

    // Create a custom token for the client
    const customToken = await auth.createCustomToken(userCredential.user.uid);

    // Return success response with user data and token
    response.status(200).send({
      message: "Login successful",
      user: {
        uid: userCredential.user.uid,
        email: userCredential.user.email,
        displayName: userCredential.user.displayName,
        ...userDoc.data(),
      },
      token: customToken,
    });
  } catch (error) {
    logger.error("Error during login:", error);
    
    // Handle specific error cases
    if (error.code === "auth/user-not-found") {
      response.status(404).send({
        error: "User not found",
        message: "No user found with this email",
      });
    } else if (error.code === "auth/wrong-password") {
      response.status(401).send({
        error: "Invalid credentials",
        message: "Invalid email or password",
      });
    } else if (error.code === "auth/invalid-email") {
      response.status(400).send({
        error: "Invalid email",
        message: "The provided email is invalid",
      });
    } else if (error.code === "auth/user-disabled") {
      response.status(403).send({
        error: "Account disabled",
        message: "This account has been disabled",
      });
    } else {
      response.status(500).send({
        error: "Internal server error",
        message: "An error occurred during login",
      });
    }
  }
});
