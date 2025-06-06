/**
 * User Filter Management Cloud Function for TapIn@UW
 * Handles saving and updating user preference filters in Firestore
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

/**
 * Saves or updates a user's preference filters in Firestore
 * 
 * Endpoint: POST /saveUserFilters
 * 
 * Request Body:
 *   {
 *     "uid": "string",      // User's unique identifier
 *     "filters": {          // Object containing filter preferences
 *       "filterName": boolean,  // Key-value pairs of filter names and their states
 *       ...
 *     }
 *   }
 * 
 * Returns:
 *   - 200: Success message
 *   - 400: Invalid or missing parameters
 *   - 405: Invalid HTTP method
 *   - 500: Server error
 * 
 * Note: This function merges the new filters with existing user data
 * and updates the filtersUpdatedAt timestamp
 */
exports.saveUserFilters = onRequest(async (req, res) => {
  return cors(req, res, async () => {
    // Only allow POST
    if (req.method !== "POST") {
      res.status(405).send({ error: "Only POST requests allowed" });
      return;
    }

    const { uid, filters } = req.body;

    // Validate parameters
    if (!uid || typeof uid !== "string") {
      res.status(400).send({ message: "Missing or invalid 'uid' in request body" });
      return;
    }
    if (typeof filters !== "object" || Array.isArray(filters)) {
      res.status(400).send({ message: "Missing or invalid 'filters' object in request body" });
      return;
    }

    try {
      const userRef = admin.firestore().collection("users").doc(uid);

      // Merge in the new filters and timestamp
      await userRef.set(
        {
          filters: filters,
          filtersUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      res.status(200).send({ message: "Filters saved successfully." });
    } catch (error) {
      logger.error("Error saving user filters:", error);
      res.status(500).send({
        message: "Failed to save filters",
        error: error.message,
      });
    }
  });
}); 