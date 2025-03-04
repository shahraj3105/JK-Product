exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Verify if the requester is an admin
  if (!context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Must be an admin to delete users.');
  }

  try {
    await admin.auth().deleteUser(data.uid);
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
}); 