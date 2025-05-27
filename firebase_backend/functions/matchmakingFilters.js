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

  // 3) Persist to Firestore in the correct location
  const userRef = db.collection('users').doc(uid).collection('filters').doc('preferences');
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
  const filtersSnap = await db.collection('users').doc(uid).collection('filters').doc('preferences').get();

  if (!filtersSnap.exists) {
    return { filters: null, filtersUpdatedAt: null };
  }

  const data = filtersSnap.data();
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
  const userRef = db.collection('users').doc(uid).collection('filters').doc('preferences');

  await userRef.update({
    filters: admin.firestore.FieldValue.delete(),
    filtersUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { status: 'cleared', clearedAt: new Date().toISOString() };
});

/**
 * Obtain the potential matches based on the user's set filters and users they have ignored/requested
 */
exports.getPotentialMatches = functions.https.onCall(async (data, context) => {
  if(!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be signed in to get potential matches.'
    );
  }

  const uid = context.auth.uid;
  
  // Get user's filters first
  const filtersDoc = await db.collection('users').doc(uid).collection('filters').doc('preferences').get();
  const filters = filtersDoc.exists ? filtersDoc.data().filters : null;

  // Build query based on filters
  let query = db.collection('users').where('uid', '!=', uid).limit(20);

  if (filters && filters.interests && filters.interests.length > 0) {
    query = query.where('interests', 'array-contains-any', filters.interests);
  }

  const snapshot = await query.get();
  const potentialMatches = [];
  snapshot.forEach(doc => {
    potentialMatches.push({
      uid: doc.id,
      ...doc.data()
    });
  });

  return {
    matches: potentialMatches,
    hasMore: potentialMatches.length > 0
  };
});

/**
 * Add user to the list of ignored/rejected potential matches
 */
exports.ignoreUser = functions.https.onCall(async (data, context) => {
  if(!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be signed in to ignore users.'
    );
  }
  
  const uid = context.auth.uid;
  const ignoredUid = data.ignoredUid;

  if(!ignoredUid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Ignored user ID is required.'
    );
  }

  const userRef = db.collection('users').doc(uid);
  await userRef.update({
    ignoredUsers: admin.firestore.FieldValue.arrayUnion(ignoredUid)
  });

  return {
    status: 'success'
  };
})

/**
 * Send an add request to the potential match
 */
exports.sendRequest = functions.https.onCall(async (data, context) => {
  if(!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be signed in to send requests.'
    );
  }

  const uid = context.auth.uid;
  const targetUID = data.targetUID;

  if(!targetUID) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Target user ID is required.'
    );
  }

  // Add potential match to user's list of sent requests
  const senderRef = db.collection('users').doc(uid);
  await senderRef.update({
    addedUsers: admin.firestore.FieldValue.arrayUnion(targetUID)
  });

  // Add user to potential match's list of received requests
  const receiverRef = db.collection('users').doc(targetUID);
  await receiverRef.update({
    pendingUsers: admin.firestore.FieldValue.arrayUnion(uid)
  });

  return {
    status: 'success'
  };
});