const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.database();

async function getAllTokens() {
  const snap = await db.ref('user_tokens').get();
  if (!snap.exists()) return [];
  const data = snap.val() || {};
  const tokens = [];
  Object.values(data).forEach((userTokens) => {
    if (userTokens && typeof userTokens === 'object') {
      tokens.push(...Object.keys(userTokens));
    }
  });
  return tokens;
}

async function getTokensForUser(uid) {
  const snap = await db.ref(`user_tokens/${uid}`).get();
  if (!snap.exists()) return [];
  const data = snap.val() || {};
  return Object.keys(data);
}

exports.onTripCreated = functions.database
  .ref('trips/{tripId}')
  .onCreate(async (snap, context) => {
    const trip = snap.val() || {};
    const tokens = await getAllTokens();
    if (!tokens.length) return null;

    const payload = {
      notification: {
        title: 'New Trip Added',
        body: `${trip.name || 'A new trip'} is now available`,
      },
      data: {
        tripId: context.params.tripId,
        type: trip.type || '',
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    functions.logger.info('Trip notifications sent', {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    return null;
  });

exports.onBookingStatusChange = functions.database
  .ref('bookings_all/{bookingKey}/status')
  .onWrite(async (change, context) => {
    const after = change.after.val();
    const before = change.before.val();
    if (!after || after === before) return null;

    const bookingSnap = await change.after.ref.parent.get();
    if (!bookingSnap.exists()) return null;

    const booking = bookingSnap.val() || {};
    const uid = booking.userId;
    if (!uid) return null;

    const tokens = await getTokensForUser(uid);
    if (!tokens.length) return null;

    const payload = {
      notification: {
        title: 'Booking Update',
        body: `Your booking is now ${after}.`,
      },
      data: {
        bookingId: booking.id || '',
        status: after,
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    functions.logger.info('Booking status notification sent', {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    return null;
  });
