# 🧪 Testing Firebase Auth System

## Prerequisites

- ✅ Flutter 3.11.0+
- ✅ Android device or emulator
- ✅ Internet connection
- ✅ Firebase project: `transit-app-307ac`

---

## Test Suite 1: Basic Build & Run

### Test 1.1: Clean Build

```bash
cd e:\app_transport\app_transport
flutter clean
flutter pub get
```

**Expected Result**: ✅ No errors, dependencies resolve

### Test 1.2: Run App

```bash
flutter run
```

**Expected Result**:

- ✅ App builds successfully
- ✅ Splash screen appears
- ✅ Green SnackBar shows "متصل بنجاح"
- ✅ Sign In page loads

---

## Test Suite 2: Authentication Flow

### Test 2.1: Navigate to Sign Up

1. On Splash Screen or Sign In page
2. Look for "Get Started" or "Sign up" button
3. Tap button

**Expected Result**: ✅ Sign Up page displays with fields:

- Email input
- Name input
- Password input
- Password strength indicator

### Test 2.2: Attempt Sign Up with Empty Fields

1. Leave all fields empty
2. Tap "Sign up" button

**Expected Result**: ✅ Error SnackBar appears:

- Message: "جميع الحقول مطلوبة (All fields required)"
- Color: Red

### Test 2.3: Attempt Sign Up with Weak Password

1. Email: `test@example.com`
2. Name: `Test User`
3. Password: `123` (too short)
4. Tap "Sign up"

**Expected Result**: ✅ Error SnackBar appears:

- Message: "كلمة المرور يجب أن تكون 6 أحرف على الأقل"

### Test 2.4: Valid Sign Up

1. Email: `testuser+{timestamp}@example.com`
2. Name: `Test User`
3. Password: `TestPass123`
4. Tap "Sign up"

**Expected Result**:

- ✅ Loading state shows "جاري الإنشاء..."
- ✅ Success SnackBar (green): "✅ تم إنشاء الحساب بنجاح"
- ✅ Navigates to HomePage after 500ms
- ✅ Button becomes disabled during operation

### Test 2.5: Verify Data in Database

1. Open Firebase Console
2. Go to: Project → Realtime Database
3. Check path: `users/`

**Expected Result**: ✅ New user document exists with:

```json
{
  "uid": "Firebase User ID",
  "email": "testuser+...@example.com",
  "name": "Test User",
  "phoneNumber": "",
  "createdAt": "2026-02-28T...",
  "lastLogin": "2026-02-28T..."
}
```

---

## Test Suite 3: Sign In Flow

### Test 3.1: Navigate to Sign In

1. From HomePage (if signed up)
2. Or from Splash → Sign In button
3. Or Tap "Already have an account?" on Sign Up page

**Expected Result**: ✅ Sign In page displays with:

- Email input
- Password input
- "Sign In" button

### Test 3.2: Attempt Sign In with Wrong Credentials

1. Email: `testuser+...@example.com`
2. Password: `WrongPassword`
3. Tap "Sign In"

**Expected Result**: ✅ Error SnackBar (red) appears:

- Message includes: "wrong password" or "user not found"

### Test 3.3: Attempt Sign In with Duplicate Email

_If already signed up same device:_

1. Email: Already registered email
2. Password: Correct password
3. Tap "Sign In"

**Expected Result**:

- ✅ Either: Signs in successfully, OR
- ✅ Shows error about duplicate account

### Test 3.4: Valid Sign In

1. Email: `testuser+...@example.com`
2. Password: `TestPass123`
3. Tap "Sign In"

**Expected Result**:

- ✅ Loading state shows "جاري التسجيل..."
- ✅ Success SnackBar (green): "✅ تم تسجيل الدخول بنجاح"
- ✅ Navigates to HomePage
- ✅ Button disabled during operation

### Test 3.5: Verify Last Login Updated

1. Open Firebase Console
2. Go to: `users/{uid}/lastLogin`

**Expected Result**: ✅ Timestamp is recent (within last minute)

---

## Test Suite 4: Error Handling

### Test 4.1: Invalid Email Format

**Test Case**: Try to sign up with invalid email

1. Email: `notanemail` (missing @)
2. Name: `Test User`
3. Password: `TestPass123`
4. Tap "Sign up"

**Expected Result**: ✅ Error message indicates invalid email

### Test 4.2: Network Disconnect

**Prerequisite**: Have internet connection test available

1. Disconnect device from WiFi/Mobile data
2. Try to sign up
3. Tap "Sign up"

**Expected Result**: ✅ Error appears (network timeout or similar)

### Test 4.3: Firebase Error

**Test Case**: Try using same email twice

1. First: Sign up with `testuser@example.com`
2. Second: Try to sign up with same email
3. Tap "Sign up"

**Expected Result**: ✅ Error SnackBar (red):

- Message: "البريد الإلكتروني مستخدم بالفعل"

---

## Test Suite 5: UI/UX Features

### Test 5.1: Password Visibility Toggle

1. On Sign Up page
2. Enter password: `TestPass`
3. Tap eye icon to show/hide password

**Expected Result**:

- ✅ Icon toggles between visibility on/off
- ✅ Password text shows/hides

### Test 5.2: Password Strength Indicator

1. On Sign Up page
2. Enter password: `abc` (weak)

**Expected Result**: ✅ Strength indicator shows:

- Red bar
- Label: "Weak"

3. Enter password: `TestPass123!@` (strong)

**Expected Result**: ✅ Strength indicator shows:

- Blue bar
- Label: "Strong"

### Test 5.3: Button States

1. On Sign Up page with all fields empty

**Expected Result**: ✅ Button appears pressable

2. Start typing, then focus on field

**Expected Result**: ✅ Button shows loading state when pressed

### Test 5.4: Navigation Animations

1. Tap "Get Started" from Sign In

**Expected Result**: ✅ Smooth slide transition from left

2. Tap back or "Already have account?"

**Expected Result**: ✅ Smooth slide transition in opposite direction

---

## Test Suite 6: Data Persistence

### Test 6.1: Data Survives App Restart

1. Sign up user: `persistence@test.com`
2. Close app completely
3. Reopen app
4. Try to sign in with same credentials

**Expected Result**: ✅ Sign in successful, user data loads

### Test 6.2: Last Login Updates

1. Sign in user
2. Close app
3. Reopen within 5 minutes
4. Sign in again
5. Check Firebase Console

**Expected Result**: ✅ `lastLogin` timestamp is recent

---

## Test Suite 7: Multilingual Support

### Test 7.1: Error Messages in Arabic

1. Trigger an error (e.g., empty fields)

**Expected Result**: ✅ Error message includes Arabic text:

- "جميع الحقول مطلوبة"
- "كلمة المرور ضعيفة"

### Test 7.2: Error Messages in English

1. Same error

**Expected Result**: ✅ Message also includes English:

- "All fields required"
- "Password too weak"

---

## Test Suite 8: Performance & Reliability

### Test 8.1: Rapid Submissions

1. Fill Sign Up form correctly
2. Tap "Sign up" multiple times rapidly

**Expected Result**: ✅

- Button remains disabled during first operation
- Rapid taps don't cause crashes
- Only one account created

### Test 8.2: Long Password

1. Enter very long password (100+ characters)
2. Try to sign up

**Expected Result**: ✅ Works without issues

### Test 8.3: Special Characters

1. Email with special chars: `user+test@example.co.uk`
2. Name with emojis or unicode: `ओमर فترة`
3. Password with special chars: `Pas$w0rd!@#`
4. Sign up

**Expected Result**: ✅ All special characters allowed and stored

---

## Common Testing Issues

### Issue: "CONFIGURATION_NOT_FOUND" on Sign In/Up

**Solution**: See `FIREBASE_RECAPTCHA_FIX.md`

1. Disable reCAPTCHA in Firebase Console for testing
2. Or configure it properly for production

### Issue: Page doesn't load

**Solution**:

```bash
flutter clean
flutter pub get
flutter run
```

### Issue: User data not in database

**Solution**: Check Firebase Console → Realtime Database rules allow writes

### Issue: Sign In says "user not found"

**Solution**: Make sure you're using same email that was registered

---

## Test Checklist

- [ ] App builds without errors
- [ ] Splash screen shows Firebase connection success
- [ ] Can navigate to Sign Up page
- [ ] Can navigate to Sign In page
- [ ] Can create new account
- [ ] Account data appears in Firebase Database
- [ ] Can sign in with created account
- [ ] Error messages display in Arabic/English
- [ ] Loading states work correctly
- [ ] Password strength indicator works
- [ ] All UI animations work smoothly
- [ ] Special characters handled correctly
- [ ] Rapid submissions don't cause issues

---

## Firebase Console Verification Steps

1. **Check Users Created**:

   ```
   Firebase Console → Authentication
   Should see test accounts created
   ```

2. **Check Database Data**:

   ```
   Firebase Console → Realtime Database → users/
   Should see user documents with all fields
   ```

3. **Check Timestamps**:
   ```
   Click on a user → lastLogin
   Should be recent (within last few minutes)
   ```

---

## Success Criteria

✅ All basic tests pass  
✅ Data appears in database  
✅ Error messages are clear  
✅ No crashes during operation  
✅ Performance is responsive  
✅ Bilingual support works

---

## Final Notes

- Always test on real device if possible (emulator can be slower)
- Test with real Firebase project, not local emulator
- Clear app data between major test cycles: `adb shell pm clear com.omar.app_transport`
- Check device logs: `adb logcat -s flutter`

---

**Testing Completed**: [Date]  
**Tested By**: [Your Name]  
**Device**: [Device Model]  
**Result**: ✅ PASS / ❌ FAIL

---

_Last Updated: Feb 28, 2026_
