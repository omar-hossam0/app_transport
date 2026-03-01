# Firebase Authentication & Database Integration

## Overview

This document describes the complete authentication system integrated with Firebase Authentication and Realtime Database.

---

## Architecture

### Components

#### 1. **AuthService** (`lib/services/auth_service.dart`)

- **Purpose**: Central authentication service using Firebase Auth & Realtime Database
- **Extends**: `ChangeNotifier` for state management with Provider
- **Key Methods**:
  - `signUp()` - Create new user account
  - `signIn()` - Login existing user
  - `signOut()` - Logout current user
  - `updateUserProfile()` - Update user data
  - `getUserData()` - Fetch user from database
  - `emailExists()` - Check if email is registered

**Properties**:

```dart
UserModel? currentUser         // Currently logged-in user
bool isLoading               // Loading state during auth operations
String? errorMessage         // Error details from operations
bool isLoggedIn              // Quick check if user is authenticated
User? firebaseUser           // Firebase user object
```

#### 2. **UserModel** (`lib/models/user_model.dart`)

- **Purpose**: Represents a user with all profile information
- **Fields**:
  ```dart
  String uid              // Firebase unique ID
  String email            // User email
  String name             // Full name
  String phoneNumber      // Optional phone number
  DateTime createdAt      // Account creation time
  DateTime lastLogin      // Last login timestamp
  ```
- **Methods**:
  - `toMap()` - Convert to JSON for database storage
  - `fromMap()` - Create from JSON from database
  - `copyWith()` - Create modified copy

#### 3. **Sign In Page** (`lib/pages/sign_in_page.dart`)

- Email and password input fields
- Handles sign-in validation and error display
- Shows loading state during authentication
- Navigates to HomePage on success
- Displays Arabic and English error messages

#### 4. **Sign Up Page** (`lib/pages/sign_up_page.dart`)

- Email, name, and password input fields
- Password strength indicator
- Validates password requirements
- Shows loading state during account creation
- Navigates to HomePage on success

---

## Database Schema

### Users Collection Structure

```
Realtime Database: users/
├── {uid1}/
│   ├── uid: "user_id_1"
│   ├── email: "user@example.com"
│   ├── name: "User Name"
│   ├── phoneNumber: "+20123456789"
│   ├── createdAt: "2026-02-28T22:31:16.000Z"
│   └── lastLogin: "2026-02-28T22:31:16.000Z"
├── {uid2}/
│   ├── uid: "user_id_2"
│   ├── email: "another@example.com"
│   ├── name: "Another User"
│   ├── phoneNumber: ""
│   ├── createdAt: "2026-02-28T20:00:00.000Z"
│   └── lastLogin: "2026-02-28T21:00:00.000Z"
```

---

## Firebase Configuration

### Realtime Database Rules

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### User Authentication Flow

```
┌─────────────────────────────────────────────────────┐
│              User Entry Point                       │
│         (SplashScreen → SignInPage)                 │
└─────────────────────────────────────────────────────┘
                      ↓
        ┌─────────────┴──────────────┐
        ↓                            ↓
   [Sign In]                    [Sign Up]
   (Existing User)           (New Account)
        ↓                            ↓
  ┌─────────────────────────────────────────┐
  │  Firebase Auth Verification             │
  │  • Validate credentials                 │
  │  • Create/Verify auth token             │
  └─────────────────────────────────────────┘
        ↓ (Auth Success)
  ┌─────────────────────────────────────────┐
  │  Realtime Database Operations           │
  │  • Save user profile (Sign Up)          │
  │  • Load user data (Sign In)             │
  │  • Update lastLogin timestamp           │
  └─────────────────────────────────────────┘
        ↓ (DB Success)
  ┌─────────────────────────────────────────┐
  │  ✅ Set AuthService.currentUser         │
  │  🔔 Notify listeners (UI rebuilds)      │
  │  ➡️ Navigate to HomePage                │
  └─────────────────────────────────────────┘
```

---

## Usage Examples

### Sign Up New User

```dart
// In SignUpPage or any component
final authService = context.read<AuthService>();

final success = await authService.signUp(
  email: 'user@example.com',
  password: 'SecurePassword123!',
  name: 'Omar Ahmed',
  phoneNumber: '+20123456789',
);

if (success) {
  // User saved to database, navigate to home
  Navigator.pushReplacementNamed(context, '/home');
} else {
  // Show error message
  print(authService.errorMessage);
}
```

### Sign In Existing User

```dart
final authService = context.read<AuthService>();

final success = await authService.signIn(
  email: 'user@example.com',
  password: 'SecurePassword123!',
);

if (success) {
  // User data loaded from database
  print('Welcome ${authService.currentUser?.name}');
  Navigator.pushReplacementNamed(context, '/home');
} else {
  print(authService.errorMessage);
}
```

### Get Current User in Any Widget

```dart
// Using Consumer to observe changes
Consumer<AuthService>(
  builder: (context, authService, child) {
    if (authService.isLoggedIn) {
      return Text('Hello ${authService.currentUser?.name}');
    } else {
      return Text('Not logged in');
    }
  },
)

// Or using context.watch()
final authService = context.watch<AuthService>();
final userName = authService.currentUser?.name ?? 'Guest';
```

### Update User Profile

```dart
final authService = context.read<AuthService>();

final success = await authService.updateUserProfile(
  name: 'New Name',
  phoneNumber: '+20987654321',
);

if (success) {
  print('Profile updated');
} else {
  print(authService.errorMessage);
}
```

### Sign Out

```dart
final authService = context.read<AuthService>();

final success = await authService.signOut();

if (success) {
  Navigator.pushReplacementNamed(context, '/signin');
}
```

---

## Error Handling

All authentication operations include comprehensive error handling:

| Error Code             | English Message                    | Arabic Message                  |
| ---------------------- | ---------------------------------- | ------------------------------- |
| `email-already-in-use` | This email is already registered   | البريد الإلكتروني مستخدم بالفعل |
| `weak-password`        | Password is too weak               | كلمة المرور ضعيفة               |
| `invalid-email`        | Invalid email format               | البريد الإلكتروني غير صحيح      |
| `user-not-found`       | User not found                     | المستخدم غير موجود              |
| `wrong-password`       | Wrong password                     | كلمة المرور غير صحيحة           |
| `too-many-requests`    | Too many attempts, try again later | عدد محاولات كثير                |

---

## State Management Integration

### Provider Setup (In main.dart)

```dart
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthService()),
    ],
    child: const MyApp(),
  ),
);
```

### Accessing AuthService

```dart
// Read-only (one-time)
final authService = context.read<AuthService>();

// Watch for changes (rebuilds on change)
final authService = context.watch<AuthService>();

// Using Consumer
Consumer<AuthService>(
  builder: (context, authService, child) {
    // UI that depends on authService
  },
)
```

---

## Validation Rules

### Email Validation

- Must contain '@' symbol
- Checked by Firebase Auth

### Password Validation

- Minimum 6 characters (required by app)
- Firebase allows even weak passwords, but higher requirements recommended

### Name Validation

- Cannot be empty
- Required for account creation

### Sign In Validation

- Both email and password required
- Exact match with stored credentials

---

## Loading States

The `AuthService.isLoading` property indicates ongoing operations:

```dart
Consumer<AuthService>(
  builder: (context, authService, _) {
    return AuthGradientButton(
      label: authService.isLoading ? 'جاري التسجيل...' : 'Sign In',
      onTap: authService.isLoading ? () {} : _handleSignIn,
    );
  },
)
```

---

## Database Connectivity

Before authentication works:

1. ✅ Firebase Realtime Database must be enabled in Firebase Console
2. ✅ Database URL must be configured in `firebase_options.dart`
3. ✅ Database rules must allow user read/write access to their own data

---

## Testing the Auth System

### Test Sign Up

1. Open app → "Get Started" button
2. Enter email, name, and password
3. Click "Sign up"
4. Should navigate to HomePage
5. Check Firebase Console: users/{uid}/data should exist

### Test Sign In

1. Open app → "Sign In" button
2. Enter registered email and password
3. Click "Sign In"
4. Should navigate to HomePage
5. Check Firebase Console: lastLogin timestamp should update

### Test Error Cases

1. **Duplicate Email**: Try signing up with existing email
2. **Weak Password**: Try password with < 6 characters
3. **Wrong Password**: Sign in with correct email but wrong password
4. **Missing Fields**: Leave fields empty and try submitting

---

## Future Enhancements

- [ ] Password reset functionality
- [ ] Email verification
- [ ] Social login (Google, Facebook)
- [ ] User profile picture upload
- [ ] Phone number verification
- [ ] Two-factor authentication
- [ ] User search and friend system

---

## Dependencies

```yaml
provider: ^6.1.5 # State management
firebase_core: ^4.4.0 # Firebase initialization
firebase_auth: ^6.1.4 # Authentication
firebase_database: ^12.1.3 # Realtime database
```

---

## Documents Structure

```
lib/
├── models/
│   └── user_model.dart       # User data model
├── services/
│   └── auth_service.dart     # Authentication service
├── pages/
│   ├── sign_in_page.dart     # Login page
│   ├── sign_up_page.dart     # Registration page
│   ├── home_page.dart        # Main app page
│   └── auth_widgets.dart     # Shared UI components
├── firebase_options.dart     # Firebase configuration
└── main.dart                 # App entry point
```

---

**Created**: Feb 28, 2026  
**Firebase Project**: transit-app-307ac  
**Database URL**: https://transit-app-307ac-default-rtdb.firebaseio.com
