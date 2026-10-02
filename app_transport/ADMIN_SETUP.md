# Firebase Auth and Admin Setup

## Google sign-in

1. In Firebase Console, open Authentication > Sign-in method and enable Google.
2. Add `localhost` and the deployed web hostname under Authentication > Settings > Authorized domains.
3. Run `flutterfire configure --project=transit-app-307ac` from this directory while logged in with `firebase login`. Keep the generated Web App ID in `lib/firebase_options.dart`; do not leave an `xxxxxxxx` placeholder.
4. For Android, register the SHA-1 certificate used by the installed build. The Debug Firebase file now includes the existing project OAuth clients, but a different machine or release keystore needs its own SHA-1 registered in Firebase.

## Create the admin user

The Flutter app does not create admin accounts or admin roles. Provision one with the Firebase Admin SDK from the `functions` directory:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\firebase-service-account.json'
$env:ADMIN_EMAIL = 'admin@example.com'
$env:ADMIN_PASSWORD = 'use-a-long-unique-password'
$env:ADMIN_NAME = 'Admin User'
npm install
npm run provision-admin
```

The command creates or updates the Firebase Authentication user and writes its `users/{uid}` profile with `isAdmin: true`. Never put the service-account JSON, admin password, or credentials in the Flutter app or Git.

After provisioning, deploy the database rules:

```powershell
firebase deploy --only database --project transit-app-307ac
```

## Enable the chatbot

Rotate the exposed Groq key first, then configure the replacement as a Firebase Functions secret from the `functions` directory:

```powershell
firebase functions:secrets:set GROQ_API_KEY --project transit-app-307ac
firebase deploy --only functions:chatWithGroq --project transit-app-307ac
```

The chat now requires a signed-in Firebase user and never sends the Groq key to the browser.
