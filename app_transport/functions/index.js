const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const db = admin.database();

function createMailTransport() {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const user = process.env.SMTP_USER || process.env.APP_EMAIL;
  const pass = process.env.SMTP_PASS || process.env.APP_EMAIL_PASS;

  if (host && user && pass) {
    return nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: { user, pass },
    });
  }

  if (user && pass) {
    return nodemailer.createTransport({
      service: "gmail",
      auth: { user, pass },
    });
  }

  return null;
}

function formatDate(epoch) {
  if (!epoch) return "N/A";
  try {
    return new Date(epoch).toLocaleDateString("en-GB");
  } catch (_) {
    return "N/A";
  }
}

async function getAllTokens() {
  const snap = await db.ref("user_tokens").get();
  if (!snap.exists()) return [];
  const data = snap.val() || {};
  const tokens = [];
  Object.values(data).forEach((userTokens) => {
    if (userTokens && typeof userTokens === "object") {
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
  .ref("trips/{tripId}")
  .onCreate(async (snap, context) => {
    const trip = snap.val() || {};
    const tokens = await getAllTokens();
    if (!tokens.length) return null;

    const payload = {
      notification: {
        title: "New Trip Added",
        body: `${trip.name || "A new trip"} is now available`,
      },
      data: {
        tripId: context.params.tripId,
        type: trip.type || "",
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    functions.logger.info("Trip notifications sent", {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    return null;
  });

exports.onBookingStatusChange = functions.database
  .ref("bookings_all/{bookingKey}/status")
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
        title: "Booking Update",
        body: `Your booking is now ${after}.`,
      },
      data: {
        bookingId: booking.id || "",
        status: after,
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    functions.logger.info("Booking status notification sent", {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    return null;
  });

exports.onBookingCreatedSendEmail = functions.database
  .ref("bookings_all/{bookingKey}")
  .onCreate(async (snap, context) => {
    const booking = snap.val() || {};
    const toEmail = (booking.userEmail || "").trim();
    if (!toEmail) return null;

    const transport = createMailTransport();
    if (!transport) {
      functions.logger.warn("SMTP not configured. Skip booking email.", {
        bookingKey: context.params.bookingKey,
      });
      await db.ref(`booking_email_logs/${context.params.bookingKey}`).set({
        status: "skipped",
        reason: "smtp_not_configured",
        email: toEmail,
        at: Date.now(),
      });
      return null;
    }

    const fromEmail =
      process.env.BOOKING_EMAIL_FROM ||
      process.env.SMTP_USER ||
      process.env.APP_EMAIL ||
      "no-reply@apptransport.com";

    const bookingId = booking.id || context.params.bookingKey;
    const tripName = booking.tripName || "Your Trip";
    const dateText = formatDate(booking.dateEpoch);
    const totalPrice =
      Number(booking.pricePerPerson || 0) * Number(booking.travelers || 1);

    const subject = `Booking Confirmation - ${bookingId}`;
    const text = [
      `Hello ${booking.userName || "Traveler"},`,
      "",
      "Your booking is confirmed.",
      `Booking ID: ${bookingId}`,
      `Trip: ${tripName}`,
      `Date: ${dateText}`,
      `Travelers: ${booking.travelers || 1}`,
      `Payment Method: ${booking.paymentMethod || "N/A"}`,
      `Total: $${totalPrice.toFixed(2)}`,
      "",
      "Thank you for using App Transport.",
    ].join("\n");

    const html = `
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #1b1f24;">
        <h2 style="margin-bottom: 8px;">Booking Confirmation</h2>
        <p>Hello ${booking.userName || "Traveler"},</p>
        <p>Your booking is confirmed.</p>
        <table cellpadding="6" cellspacing="0" border="0" style="border-collapse: collapse;">
          <tr><td><strong>Booking ID</strong></td><td>${bookingId}</td></tr>
          <tr><td><strong>Trip</strong></td><td>${tripName}</td></tr>
          <tr><td><strong>Date</strong></td><td>${dateText}</td></tr>
          <tr><td><strong>Travelers</strong></td><td>${booking.travelers || 1}</td></tr>
          <tr><td><strong>Payment</strong></td><td>${booking.paymentMethod || "N/A"}</td></tr>
          <tr><td><strong>Total</strong></td><td>$${totalPrice.toFixed(2)}</td></tr>
        </table>
        <p style="margin-top: 16px;">Thank you for using App Transport.</p>
      </div>
    `;

    try {
      await transport.sendMail({
        from: fromEmail,
        to: toEmail,
        subject,
        text,
        html,
      });

      await db.ref(`booking_email_logs/${context.params.bookingKey}`).set({
        status: "sent",
        email: toEmail,
        bookingId,
        at: Date.now(),
      });
    } catch (error) {
      functions.logger.error("Booking email send failed", {
        bookingKey: context.params.bookingKey,
        error: error?.message || String(error),
      });

      await db.ref(`booking_email_logs/${context.params.bookingKey}`).set({
        status: "failed",
        email: toEmail,
        bookingId,
        reason: error?.message || String(error),
        at: Date.now(),
      });
    }

    return null;
  });
