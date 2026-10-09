/**
 * create_admin_user.js
 * Creates/updates the admin user using Firebase Admin SDK.
 * Reads the OAuth2 access token that firebase-tools already stored locally
 * so no separate service-account JSON file is required.
 */

"use strict";

const admin = require("firebase-admin");
const path  = require("path");
const fs    = require("fs");

// ─── Config ───────────────────────────────────────────────────────────────────
const PROJECT_ID    = "transit-app-307ac";
const DATABASE_URL  = "https://transit-app-307ac-default-rtdb.firebaseio.com";
const ADMIN_EMAIL   = "admin@gmail.com";
const ADMIN_PASSWORD = "admin123";
const ADMIN_NAME    = "Admin";

// ─── Read stored OAuth2 token from firebase-tools ────────────────────────────
function loadFirebaseToolsToken() {
  const configPath = path.join(
    process.env.USERPROFILE || process.env.HOME || "",
    ".config", "configstore", "firebase-tools.json"
  );
  try {
    const raw = fs.readFileSync(configPath, "utf8");
    const cfg = JSON.parse(raw);
    const tokens = cfg.tokens;
    if (!tokens?.access_token) throw new Error("access_token not found");
    return tokens;
  } catch (err) {
    throw new Error(
      `Cannot read firebase-tools credentials: ${err.message}\n` +
      `Make sure you ran: firebase login`
    );
  }
}

// ─── Custom firebase-admin Credential ────────────────────────────────────────
function makeCredential(tokens) {
  return {
    getAccessToken() {
      return Promise.resolve({
        access_token: tokens.access_token,
        expires_in:   tokens.expires_in ?? 3600,
      });
    },
  };
}

// ─── Encode email for DB key ──────────────────────────────────────────────────
function encodeEmail(email) {
  return email.toLowerCase().replaceAll(".", ",").replaceAll("@", "_at_");
}

// ─── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log("🔧 Provisioning admin user with Firebase Admin SDK");
  console.log(`   Project : ${PROJECT_ID}`);
  console.log(`   Email   : ${ADMIN_EMAIL}`);
  console.log(`   DB URL  : ${DATABASE_URL}\n`);

  // 1. Load credentials & initialise firebase-admin
  const tokens = loadFirebaseToolsToken();
  admin.initializeApp({
    credential:  makeCredential(tokens),
    databaseURL: DATABASE_URL,
    projectId:   PROJECT_ID,
  });

  const auth = admin.auth();
  const db   = admin.database();

  // 2. Create or update the Firebase Auth user
  let user;
  try {
    user = await auth.getUserByEmail(ADMIN_EMAIL);
    console.log(`✅ [Auth] Found existing user  → UID: ${user.uid}`);
    user = await auth.updateUser(user.uid, {
      displayName:   ADMIN_NAME,
      password:      ADMIN_PASSWORD,
      emailVerified: true,
      disabled:      false,
    });
    console.log(`✅ [Auth] Updated credentials`);
  } catch (err) {
    if (err.code !== "auth/user-not-found") throw err;
    console.log(`📝 [Auth] User not found – creating...`);
    user = await auth.createUser({
      email:         ADMIN_EMAIL,
      password:      ADMIN_PASSWORD,
      displayName:   ADMIN_NAME,
      emailVerified: true,
    });
    console.log(`✅ [Auth] Created new user → UID: ${user.uid}`);
  }

  // 3. Write user profile to Realtime Database (isAdmin: true)
  const now = new Date().toISOString();
  const userData = {
    uid:         user.uid,
    email:       ADMIN_EMAIL,
    name:        ADMIN_NAME,
    phoneNumber: "",
    photoUrl:    "",
    isAdmin:     true,
    createdAt:   now,
    lastLogin:   now,
  };

  await db.ref(`users/${user.uid}`).update(userData);
  console.log(`✅ [DB] Written → users/${user.uid}`);

  await db.ref(`email_index/${encodeEmail(ADMIN_EMAIL)}`).set({ uid: user.uid });
  console.log(`✅ [DB] Written → email_index/${encodeEmail(ADMIN_EMAIL)}`);

  console.log(`\n🎉 Admin provisioned successfully!`);
  console.log(`   Email    : ${ADMIN_EMAIL}`);
  console.log(`   Password : ${ADMIN_PASSWORD}`);
  console.log(`   UID      : ${user.uid}`);
  console.log(`   isAdmin  : true`);
}

main()
  .catch((err) => {
    console.error("❌ Error:", err.message || err);
    process.exitCode = 1;
  })
  .finally(() => admin.app().delete());
