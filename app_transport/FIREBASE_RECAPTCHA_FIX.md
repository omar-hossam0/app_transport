# Firebase Recaptcha Fix - CONFIGURATION_NOT_FOUND

## Issue Description

When attempting sign-in or sign-up, users may see error:

```
CONFIGURATION_NOT_FOUND - An internal error has occurred
```

This is caused by Firebase's reCAPTCHA validation, which requires configuration in Firebase console.

---

## ✅ Quick Fix for Development

### Option 1: Disable reCAPTCHA (Fastest - Development Only)

```
1. Go to Firebase Console
   https://console.firebase.google.com/

2. Select project: "transit-app-307ac"

3. Go to: Authentication → Settings

4. Scroll down to "App Check" section

5. Click "DISABLE" (for development testing only)

6. Run: flutter run
```

### Option 2: Configure reCAPTCHA (Recommended for Production)

#### Step 1: Enable reCAPTCHA Enterprise API

```
1. Go to Google Cloud Console
   https://console.cloud.google.com/

2. Select project: "transit-app-307ac"

3. Search and enable: "reCAPTCHA Enterprise API"

4. Wait for enabling to complete (2-3 minutes)
```

#### Step 2: Create reCAPTCHA Key

```
1. In Cloud Console, go to:
   Security Services → reCAPTCHA Enterprise → Create Assessment

2. Or go to Firebase Console → Authentication → App Check

3. Select App: "Android"
   - App ID: "com.omar.app_transport"

4. Provider: "Google Play Integrity"

5. Click: "Register app"
```

#### Step 3: Update Firebase Project

```
1. Go back to Firebase Console

2. Authentication → Settings

3. Ensure reCAPTCHA is set to:
   - Enforcement: "Cloud-based Enterprise API" or "reCAPTCHA v3"

4. Save settings
```

#### Step 4: Test

```bash
flutter clean
flutter run
```

---

## 🔧 Temporary Workaround

If reCAPTCHA configuration is delayed, temporarily disable email Auth checks:

### In AuthService (lib/services/auth_service.dart)

The current code already has error handling:

```dart
} catch (e) {
  dbConnected = false;
  print('[Auth Service] Error: $e');
  // The error is logged but app continues
}
```

So the app will show an error message but not crash.

---

## 📱 Alternative: Use Firebase Emulator

For local development without Firebase cloud:

```bash
# 1. Install Firebase Emulator Suite
npm install -g firebase-tools

# 2. Start emulator
firebase emulators:start

# 3. In Flutter app, connect to emulator
# (Requires additional configuration)
```

---

## ✅ Verification Steps

After fixing reCAPTCHA:

1. **Run app**:

   ```bash
   flutter clean && flutter run
   ```

2. **Test Sign Up**:
   - Tap "Get Started"
   - Enter email: `test@example.com`
   - Enter name: `Test User`
   - Enter password: `Test@123`
   - Tap "Sign up"
   - Should navigate to HomePage (not show error)

3. **Verify in Firebase Console**:
   - Go to Realtime Database
   - Navigate to: `users/`
   - Should see new user document

4. **Test Sign In**:
   - Sign out (if sign-out implemented)
   - Try signing in with same email/password
   - Should navigate to HomePage

---

## 📋 Troubleshooting Checklist

- [ ] Firebase project is selected in Console
- [ ] Realtime Database is ENABLED
- [ ] Authentication method "Email/Password" is ENABLED
- [ ] reCAPTCHA is DISABLED (dev) or properly CONFIGURED (prod)
- [ ] google-services.json is up to date
- [ ] Device has internet connection
- [ ] App was rebuilt after changes: `flutter clean && flutter run`
- [ ] No VPN blocking Firebase connections

---

## 🔗 Useful Console Links

**Firebase Console**: https://console.firebase.google.com/  
**Google Cloud Console**: https://console.cloud.google.com/  
**reCAPTCHA Admin**: https://www.google.com/recaptcha/admin

---

## 💡 Why This Error Occurs

Firebase Authentication in recent versions uses reCAPTCHA v3 for bot protection:

1. When you sign up/sign in, Firebase validates with reCAPTCHA
2. reCAPTCHA needs to be configured in your project
3. Without configuration, validation fails with `CONFIGURATION_NOT_FOUND`
4. You can disable it for development, but should enable for production

---

## 🎯 Next Steps

1. Choose option (Disable for dev OR Configure for prod)
2. Apply the fix
3. Run `flutter clean && flutter run`
4. Test sign up and sign in
5. Verify data appears in Firebase Console

---

**This is a temporary configuration issue, not a code problem.**  
**The authentication system itself is correctly implemented!**

---

_Last Updated: Feb 28, 2026_
