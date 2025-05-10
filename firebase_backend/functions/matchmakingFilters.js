const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();

/**
 * Save the user's matchmaking filter preferences under /users/{uid}/filters
 * Expects data.filters as an object of key→value mappings.
 */
exports.saveUserFilters = functions.https.onCall(async (data, context) => {
  // 1) Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Only authenticated users can save filters.'
    );
  }
  const uid = context.auth.uid;
  const filters = data.filters;

  // 2) Input validation
  if (typeof filters !== 'object' || Array.isArray(filters)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Filters must be an object mapping filter keys to values.'
    );
  }

  // 3) Persist to Firestore
  const userRef = db.collection('users').doc(uid);
  await userRef.set(
    {
      filters: filters,
      filtersUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return { status: 'success', savedAt: new Date().toISOString() };
});

/**
 * Retrieve the user's current filters. Returns { filters, filtersUpdatedAt }.
 */
exports.getUserFilters = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be signed in to retrieve filters.'
    );
  }
  const uid = context.auth.uid;
  const userSnap = await db.collection('users').doc(uid).get();

  if (!userSnap.exists) {
    return { filters: null, filtersUpdatedAt: null };
  }

  const data = userSnap.data();
  return {
    filters: data.filters || null,
    filtersUpdatedAt: data.filtersUpdatedAt || null,
  };
});

/**
 * Clear the user's filters (removes the filters field).
 */
exports.clearUserFilters = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be signed in to clear filters.'
    );
  }
  const uid = context.auth.uid;
  const userRef = db.collection('users').doc(uid);

  await userRef.update({
    filters: admin.firestore.FieldValue.delete(),
    filtersUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { status: 'cleared', clearedAt: new Date().toISOString() };
});
