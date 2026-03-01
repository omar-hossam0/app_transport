# Firebase Realtime Database Setup Guide

## Current Status

Your Firebase configuration is set up, but **Realtime Database is not initialized**.

## ✅ What's Done

- ✅ `google-services.json` is configured with package name: `com.omar.app_transport`
- ✅ Firebase Core and Database dependencies are added in `pubspec.yaml` and `build.gradle.kts`
- ✅ `firebase_options.dart` has all project credentials
- ✅ `lib/main.dart` checks Realtime Database connection on startup

## ❌ What's Missing

### Step 1: Open Firebase Console and Enable Realtime Database

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **transitapp-7717f**
3. From left menu: **Build** → **Realtime Database**
4. Click **Create Database**
5. Choose region: **us-central1** (or closest to you)
6. Security rules: Select **Start in test mode** (for development)
7. Click **Enable**

### Step 2: After Enabling, You'll See

- Database URL: `https://transitapp-7717f.firebaseio.com`
- Rules editor where you can define access permissions

### Step 3: Run Your App

When you run `flutter run`, the app will:

- ✅ Show GREEN SnackBar: "✅ متصل بنجاح" → Database is working
- ❌ Show RED SnackBar with error details → Something is wrong

## Troubleshooting

### If Still Not Connected After Enabling DB:

**Check Internet Connection**

```bash
adb shell ping 8.8.8.8
```

**Check Logs**

```bash
flutter logs
```

Look for:

- `[DB Test] ✅✅✅ Realtime Database is CONNECTED` → Success!
- `[DB Test] ⏱️ Connection check timed out` → Network issue
- `[DB Test] ❌ Firebase Error` → Configuration issue

### Common Issues

1. **"Realtime Database not enabled"**
   - Go to Firebase Console and enable it in the UI

2. **"Connection timeout"**
   - Check your device's internet connection
   - Disable VPN if using one
   - Check device timezone (Firebase SDK is timezone-sensitive)

3. **"Settings request failed"**
   - This is Crashlytics trying to connect (not critical)
   - Your Realtime Database should still work

## Firebase Project Details

- **Project ID**: transitapp-7717f
- **Package Name**: com.omar.app_transport
- **API Key**: AIzaSyA5KNIVOMMHyfl9NqfZRWE-by6dQ27uDpc
- **App ID (Android)**: 1:301146837722:android:415da8aa02ef1c27098be3
- **Database URL**: https://transitapp-7717f.firebaseio.com

## Next Steps After DB is Connected

Once Realtime Database is enabled:

1. Test write/read operations:

```dart
FirebaseDatabase.instance.ref('test').set({'message': 'Hello Firebase'});
```

2. View data in Firebase Console → Realtime Database → Data tab

3. Update security rules for production in Firebase Console
