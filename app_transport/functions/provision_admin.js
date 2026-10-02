const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL:
    process.env.FIREBASE_DATABASE_URL ||
    "https://transit-app-307ac-default-rtdb.firebaseio.com",
});

const db = admin.database();

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new Error(`Missing ${name}`);
  }
  return value;
}

function encodeEmail(email) {
  return email.toLowerCase().replaceAll(".", ",").replaceAll("@", "_at_");
}

async function main() {
  const email = required("ADMIN_EMAIL").toLowerCase();
  const password = required("ADMIN_PASSWORD");
  const displayName = process.env.ADMIN_NAME?.trim() || "Admin User";

  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
    user = await admin.auth().updateUser(user.uid, {
      displayName,
      password,
      emailVerified: true,
      disabled: false,
    });
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    user = await admin.auth().createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
  }

  const now = new Date().toISOString();
  await db.ref(`users/${user.uid}`).update({
    uid: user.uid,
    email,
    name: displayName,
    phoneNumber: "",
    photoUrl: "",
    isAdmin: true,
    createdAt: now,
    lastLogin: now,
  });
  await db.ref(`email_index/${encodeEmail(email)}`).set({ uid: user.uid });

  console.log(`Admin provisioned: ${email} (${user.uid})`);
}

main()
  .catch((error) => {
    console.error(error.message || error);
    process.exitCode = 1;
  })
  .finally(() => admin.app().delete());
