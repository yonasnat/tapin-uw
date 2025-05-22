// Firebase Cloud Functions for TapIn@UW - Handles user signup,
// login, and profile retrieval

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cors = require("cors")({origin: true});

// Initialize Firebase Admin SDK to access Auth and Firestore
admin.initializeApp();

/**
 * SIGNUP FUNCTION - Creates a new user in Firebase Authentication
 * and Firestore.
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
      response.status(405).send({
        error: "Only POST requests allowed",
      });
      return;
    }

    try {
      const {email, password, displayName, bio, interests} = request.body;

      // Validate required fields
      if (!email || !password || !displayName) {
        response.status(400).send({
          message: "Email, password, and name required",
        });
        return;
      }

      // Email must be UW
      if (!email.endsWith("@uw.edu")) {
        response.status(400).send({message: "Only @uw.edu email allowed."});
        return;
      }

      // Enforce strong passwords
      if (password.length < 6) {
        response.status(400).send({message: "Password must be 6+ characters."});
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
        preferences: {notifications: true, theme: "light"},
        isProfileComplete: false,
      };

      await admin.firestore()
          .collection("users")
          .doc(userRecord.uid)
          .set(userData);

      try {
        // Try to create custom token
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
      } catch (tokenError) {
        // If token creation fails, still return success but without token
        logger.warn("Token creation failed:", tokenError);
        response.status(201).send({
          message: "Signup successful. Please login with your credentials.",
          user: {
            uid: userRecord.uid,
            email,
            displayName,
            bio: userData.bio,
            interests: userData.interests,
          },
        });
      }
    } catch (error) {
      logger.error("Signup error:", error);

      if (error.code === "auth/email-already-exists") {
        response.status(409).send({message: "Email already registered."});
      } else if (error.code === "auth/invalid-email") {
        response.status(400).send({message: "Invalid email address."});
      } else {
        response.status(500).send({
          message: "Unexpected error. Try again.",
          error: error.message,
        });
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
      response.status(405).send({error: "Only POST requests allowed"});
      return;
    }

    try {
      const {email, password} = request.body;

      if (!email || !password) {
        response.status(400).send({message: "Email and password required."});
        return;
      }

      // Get user data (Firebase Admin cannot verify password)
      const userRecord = await admin.auth().getUserByEmail(email);

      // Issue token and update Firestore login time
      const token = await admin.auth().createCustomToken(userRecord.uid);
      await admin.firestore().collection("users").doc(userRecord.uid).update({
        lastLogin: admin.firestore.FieldValue.serverTimestamp(),
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
        response.status(401).send({message: "User not found. Check email."});
      } else {
        response.status(500).send({message: "Login failed. Try again later."});
      }
    }
  });
});


 // GET USER PROFILE - Returns user profile from Firestore
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
        photoUrls: data.photoUrls || [],
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


 //GET USER PHOTOS - Returns signed image URLs from Firebase Storage

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

/**
 * CREATE EVENT FUNCTION - Creates a new event in Firestore
 * The event is created by the authenticated user who becomes the organizer.
 * Trigger: HTTP POST
 * Required Fields in body:
 * - title (string)
 * - date (ISO string)
 * - location (string)
 * - description (string)
 * - maxParticipants (number)
 * - tags (array of strings)
 *
 * Optional:
 * - imageUrl (string)
 */
exports.createEvent = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "POST") {
      response.status(405).send({error: "Only POST requests allowed"});
      return;
    }

    try {
      const {
        title,
        date,
        location,
        description,
        maxParticipants,
        tags,
        imageUrl,
      } = request.body;

      // Validate required fields
      if (!title || !date || !location || !description || !maxParticipants) {
        response.status(400).send({
          message: "Missing required fields",
        });
        return;
      }

      // Create event document
      const eventData = {
        title,
        date: new Date(date),
        location,
        description,
        maxParticipants,
        tags: tags || [],
        imageUrl: imageUrl || null,
        organizerId: request.auth.uid,
        currentParticipants: 0,
        status: "upcoming",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const eventRef = await admin.firestore()
          .collection("events")
          .add(eventData);

      response.status(201).send({
        message: "Event created successfully",
        eventId: eventRef.id,
        event: eventData,
      });
    } catch (error) {
      logger.error("Create event error:", error);
      response.status(500).send({
        message: "Failed to create event",
        error: error.message,
      });
    }
  });
});

/**
 * GET EVENTS FUNCTION - Retrieves a list of events with optional filtering.
 * Events are returned in ascending order by date.
 * Trigger: HTTP GET
 * Query Parameters:
 * - status (optional): "upcoming", "ongoing", "completed"
 * - limit (optional): number of events to return
 * - startAfter (optional): event ID to start after (for pagination)
 */
exports.getEvents = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "GET") {
      response.status(405).send({error: "Only GET requests allowed"});
      return;
    }

    try {
      const {status, limit = 10, startAfter} = request.query;

      let query = admin.firestore().collection("events");

      // Apply filters
      if (status) {
        query = query.where("status", "==", status);
      }
      
      // Apply pagination
      if (startAfter) {
        const startAfterDoc = await admin.firestore()
            .collection("events")
            .doc(startAfter)
            .get();
        query = query.startAfter(startAfterDoc);
      }

      // Get events
      const snapshot = await query
          .orderBy("date", "asc")
          .limit(parseInt(limit))
          .get();

      const events = [];
      snapshot.forEach((doc) => {
        events.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      response.status(200).send({
        events,
        lastDocId: events.length > 0 ? events[events.length - 1].id : null,
      });
    } catch (error) {
      logger.error("Get events error:", error);
      response.status(500).send({
        message: "Failed to fetch events",
        error: error.message,
      });
    }
  });
});

/**
 * JOIN EVENT FUNCTION - Adds a user to an event's participants.
 * The function checks if the event exists, isn't full,
 * and the user hasn't already joined.
 * Trigger: HTTP POST
 * Required Fields in body:
 * - eventId (string)
 */
exports.joinEvent = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "POST") {
      response.status(405).send({error: "Only POST requests allowed"});
      return;
    }

    try {
      const {eventId} = request.body;
      const userId = request.auth.uid;

      // Get event document
      const eventRef = admin.firestore().collection("events").doc(eventId);
      const eventDoc = await eventRef.get();

      if (!eventDoc.exists) {
        response.status(404).send({message: "Event not found"});
        return;
      }

      const eventData = eventDoc.data();

      // Check if event is full
      if (eventData.currentParticipants >= eventData.maxParticipants) {
        response.status(400).send({message: "Event is full"});
        return;
      }

      // Check if user is already a participant
      const participantRef = eventRef.collection("participants").doc(userId);
      const participantDoc = await participantRef.get();

      if (participantDoc.exists) {
        response.status(400).send({message: "Already joined this event"});
        return;
      }

      // Add user to participants and increment count
      await admin.firestore().runTransaction(async (transaction) => {
        transaction.set(participantRef, {
          joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        transaction.update(eventRef, {
          currentParticipants: admin.firestore.FieldValue.increment(1),
        });
      });

      response.status(200).send({
        message: "Successfully joined event",
      });
    } catch (error) {
      logger.error("Join event error:", error);
      response.status(500).send({
        message: "Failed to join event",
        error: error.message,
      });
    }
  });
});

/**
 * LEAVE EVENT FUNCTION - Removes a user from an event's participants
 *
 * Trigger: HTTP POST
 * Required Fields in body:
 * - eventId (string)
 */
exports.leaveEvent = onRequest(async (request, response) => {
  return cors(request, response, async () => {
    if (request.method !== "POST") {
      response.status(405).send({error: "Only POST requests allowed"});
      return;
    }

    try {
      const {eventId} = request.body;
      const userId = request.auth.uid;

      // Get event document
      const eventRef = admin.firestore().collection("events").doc(eventId);
      const participantRef = eventRef.collection("participants").doc(userId);
      
      // Check if user is a participant
      const participantDoc = await participantRef.get();
      if (!participantDoc.exists) {
        response.status(400).send({message: "Not a participant of this event"});
        return;
      }

      // Remove user from participants and decrement count
      await admin.firestore().runTransaction(async (transaction) => {
        transaction.delete(participantRef);
        transaction.update(eventRef, {
          currentParticipants: admin.firestore.FieldValue.increment(-1),
        });
      });

      response.status(200).send({
        message: "Successfully left event",
      });
    } catch (error) {
      logger.error("Leave event error:", error);
      response.status(500).send({
        message: "Failed to leave event",
        error: error.message,
      });
    }
  });
});
