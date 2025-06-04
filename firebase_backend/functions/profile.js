/**
 * Profile Management Cloud Functions for TapIn@UW
 * Handles user profile data retrieval and photo management
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

/**
 * Retrieves a user's profile information from Firestore
 * 
 * Endpoint: GET /getUserProfile
 * Query Parameters:
 *   - uid: The user's unique identifier
 * 
 * Returns:
 *   - 200: User profile data including:
 *     - uid: User ID
 *     - displayName: User's display name
 *     - username: User's username
 *     - bio: User's biography
 *     - interests: Array of user's interests
 *     - createdAt: Account creation timestamp
 *     - photoUrls: Array of user's photo URLs
 *   - 400: Missing uid parameter
 *   - 404: User not found
 *   - 405: Invalid HTTP method
 *   - 500: Server error
 */
exports.getUserProfile = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "GET") {
      response.status(405).send({ error: "Only GET requests allowed" });
      return;
    }

    const uid = request.query.uid;

    if (!uid) {
      response.status(400).send({ message: "Missing uid in query parameters" });
      return;
    }

    try {
      const userDoc = await admin.firestore().collection("users").doc(uid).get();

      if (!userDoc.exists) {
        response.status(404).send({ message: "User profile not found" });
        return;
      }

      const data = userDoc.data();
      response.status(200).send({
        uid,
        displayName: data.displayName || "",
        username: data.username || "",
        bio: data.bio || "",
        interests: data.interests || [],
        createdAt: data.createdAt || null,
        photoUrls: data.photoUrls || [], // optional if saving URLs
      });
    } catch (error) {
      logger.error("Error fetching user profile:", error);
      response.status(500).send({
        message: "Failed to retrieve profile",
        error: error.message,
      });
    }
  });
});

/**
 * Retrieves all photos associated with a user from Firebase Storage
 * 
 * Endpoint: GET /getUserPhotos
 * Query Parameters:
 *   - uid: The user's unique identifier
 * 
 * Returns:
 *   - 200: Array of signed URLs for user's photos
 *   - 400: Missing uid parameter
 *   - 405: Invalid HTTP method
 *   - 500: Server error
 * 
 * Note: Photos are stored in the path 'users/{uid}/photos/' in Firebase Storage
 * and are returned as signed URLs valid until 2500-03-01
 */
exports.getUserPhotos = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "GET") {
      response.status(405).send({ error: "Only GET requests allowed" });
      return;
    }

    const uid = request.query.uid;

    if (!uid) {
      response.status(400).send({ message: "Missing uid in query parameters" });
      return;
    }

    try {
      const bucket = admin.storage().bucket();
      const [files] = await bucket.getFiles({ prefix: `users/${uid}/photos/` });

      const urls = await Promise.all(
        files.map(file =>
          file.getSignedUrl({
            action: "read",
            expires: "03-01-2500",
          }).then(urls => urls[0])
        )
      );

      response.status(200).send({ photoUrls: urls });
    } catch (error) {
      logger.error("Error fetching photo URLs:", error);
      response.status(500).send({
        message: "Failed to retrieve photos",
        error: error.message,
      });
    }
  });
});
