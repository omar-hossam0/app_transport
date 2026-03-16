import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

/// Authentication service using Firebase Realtime Database only (no Firebase Auth SDK)
class AuthService extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _needsEmailVerification = false;
  String? _pendingVerificationEmail;

  static const _seedAdminAccounts = [
    ('omaradmin@gmail.com', '123456', 'Omar Admin'),
    ('abdo@gmail.com', '123456', 'Abdo Admin'),
  ];

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get needsEmailVerification => _needsEmailVerification;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  AuthService() {
    _ensureAdminSeed();
    _loadSavedSession();
  }

  // ─────────────────────────────────────────────────
  // Session Persistence
  // ─────────────────────────────────────────────────

  Future<void> _loadSavedSession() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        final refreshed = _auth.currentUser;
        if (refreshed != null && refreshed.emailVerified) {
          var profile = await _ensureUserProfile(firebaseUser: refreshed);
          profile = await _ensureSeededAdminRole(
            firebaseUser: refreshed,
            profile: profile,
          );
          _currentUser = profile;
          notifyListeners();
          await _saveSession(refreshed.uid);
          return;
        }
        if (refreshed != null && !refreshed.emailVerified) {
          var profile = await _ensureUserProfile(firebaseUser: refreshed);
          profile = await _ensureSeededAdminRole(
            firebaseUser: refreshed,
            profile: profile,
          );

          if (_isSeededAdminEmail(
                (refreshed.email ?? '').trim().toLowerCase(),
              ) &&
              profile.isAdmin) {
            _currentUser = profile;
            _needsEmailVerification = false;
            _pendingVerificationEmail = null;
            notifyListeners();
            await _saveSession(refreshed.uid);
            return;
          }

          _needsEmailVerification = true;
          _pendingVerificationEmail = refreshed.email;
          _currentUser = profile;
          notifyListeners();
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('logged_in_uid');
      if (savedUid != null && savedUid.isNotEmpty) {
        await _loadUserFromDatabase(savedUid);
      }
    } catch (e) {
      debugPrint('[Auth] Error loading saved session: $e');
    }
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_uid', uid);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_uid');
  }

  // ─────────────────────────────────────────────────
  // Password Hashing (SHA-256)
  // ─────────────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ─────────────────────────────────────────────────
  // Email Key Encoding (Firebase doesn't allow . @ in keys)
  // ─────────────────────────────────────────────────

  String _encodeEmail(String email) {
    return email.toLowerCase().replaceAll('.', ',').replaceAll('@', '_at_');
  }

  // ─────────────────────────────────────────────────
  // Admin Seed (one-time)
  // ─────────────────────────────────────────────────

  Future<void> _ensureAdminSeed() async {
    try {
      final admins = _seedAdminAccounts;

      final now = DateTime.now();

      for (final (adminEmail, adminPassword, adminName) in admins) {
        await _ensureAdminAccount(
          adminEmail: adminEmail,
          adminPassword: adminPassword,
          adminName: adminName,
          now: now,
        );
      }
    } catch (e) {
      debugPrint('[Auth] Admin seed skipped: $e');
    }
  }

  Future<void> _ensureAdminAccount({
    required String adminEmail,
    required String adminPassword,
    required String adminName,
    required DateTime now,
  }) async {
    try {
      final emailKey = _encodeEmail(adminEmail);
      final passwordHash = _hashPassword(adminPassword);

      // Always ensure this specific admin account exists and has admin role.
      final indexSnap = await _database
          .ref('email_index/$emailKey')
          .get()
          .timeout(const Duration(seconds: 8));

      if (indexSnap.exists && indexSnap.value is Map) {
        final uid = (indexSnap.value as Map)['uid'] as String?;
        if (uid != null && uid.isNotEmpty) {
          await _database
              .ref('users/$uid')
              .update({
                'email': adminEmail,
                'name': adminName,
                'isAdmin': true,
                'passwordHash': passwordHash,
              })
              .timeout(const Duration(seconds: 8));
          return;
        }
      }

      final uid = const Uuid().v4();

      final adminUser = UserModel(
        uid: uid,
        email: adminEmail,
        name: adminName,
        isAdmin: true,
        createdAt: now,
        lastLogin: now,
      );

      await _database
          .ref('users/$uid')
          .set({...adminUser.toMap(), 'passwordHash': passwordHash})
          .timeout(const Duration(seconds: 8));

      await _database
          .ref('email_index/$emailKey')
          .set({'uid': uid})
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Auth] Error creating admin account for $adminEmail: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Load User from Database
  // ─────────────────────────────────────────────────

  Future<void> _loadUserFromDatabase(String uid) async {
    try {
      final snapshot = await _database
          .ref('users/$uid')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _currentUser = UserModel.fromMap(data);
        notifyListeners();
        debugPrint('[Auth] Session restored for: ${_currentUser!.email}');
      }
    } catch (e) {
      debugPrint('[Auth] Error loading user: $e');
    }
  }

  Future<UserModel> _ensureUserProfile({
    required fb_auth.User firebaseUser,
    String? name,
    String phoneNumber = '',
  }) async {
    final uid = firebaseUser.uid;
    final now = DateTime.now();
    final userRef = _database.ref('users/$uid');
    final userSnap = await userRef.get().timeout(const Duration(seconds: 10));

    if (userSnap.exists && userSnap.value != null) {
      final data = Map<String, dynamic>.from(userSnap.value as Map);
      // Keep profile synced with verified auth email.
      if ((data['email'] as String? ?? '') != (firebaseUser.email ?? '')) {
        await userRef.update({'email': firebaseUser.email ?? ''});
        data['email'] = firebaseUser.email ?? '';
      }
      if ((data['lastLogin'] as String?) == null) {
        data['lastLogin'] = now.toIso8601String();
        await userRef.update({'lastLogin': data['lastLogin']});
      }
      return UserModel.fromMap(data);
    }

    final profile = UserModel(
      uid: uid,
      email: (firebaseUser.email ?? '').trim().toLowerCase(),
      name: (name ?? firebaseUser.displayName ?? '').trim().isEmpty
          ? 'User'
          : (name ?? firebaseUser.displayName!).trim(),
      phoneNumber: phoneNumber.trim(),
      isAdmin: false,
      createdAt: now,
      lastLogin: now,
    );

    await userRef.set(profile.toMap()).timeout(const Duration(seconds: 10));
    final emailKey = _encodeEmail(profile.email);
    await _database
        .ref('email_index/$emailKey')
        .set({'uid': uid})
        .timeout(const Duration(seconds: 10));

    return profile;
  }

  // ─────────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String phoneNumber = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim().toLowerCase();

      if (trimmedEmail.isEmpty || password.isEmpty || name.isEmpty) {
        _setError('All fields are required');
        return false;
      }
      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        _setError('Invalid email address');
        return false;
      }
      if (password.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _setError('Failed to create account');
        return false;
      }

      await firebaseUser.updateDisplayName(name.trim());
      await firebaseUser.sendEmailVerification();
      _currentUser = await _ensureUserProfile(
        firebaseUser: firebaseUser,
        name: name.trim(),
        phoneNumber: phoneNumber,
      );
      _needsEmailVerification = true;
      _pendingVerificationEmail = trimmedEmail;
      _errorMessage =
          'Verification email sent to $trimmedEmail. Please verify your email to continue.';
      _isLoading = false;
      notifyListeners();

      debugPrint(
        '[Auth] Sign up successful (verification required): $trimmedEmail',
      );
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError('This email is already registered');
      } else if (e.code == 'invalid-email') {
        _setError('Please enter a valid email');
      } else if (e.code == 'weak-password') {
        _setError('Password is too weak');
      } else if (e.code == 'operation-not-allowed' ||
          e.code == 'invalid-api-key' ||
          e.code == 'app-not-authorized') {
        _setError(_authSetupMessage());
      } else {
        _setError('Sign up failed: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      final raw = e.toString();
      if (_looksLikeAuthConfigError(raw)) {
        _setError(_authSetupMessage());
      } else {
        _setError('An unexpected error occurred: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    final trimmedEmail = email.trim().toLowerCase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (trimmedEmail.isEmpty || password.isEmpty) {
        _setError('Email and password are required');
        return false;
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _setError('Sign in failed');
        return false;
      }

      await firebaseUser.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        _setError('Failed to refresh user session');
        return false;
      }

      var profile = await _ensureUserProfile(firebaseUser: refreshedUser);
      profile = await _ensureSeededAdminRole(
        firebaseUser: refreshedUser,
        profile: profile,
      );

      final canBypassVerification =
          _isSeededAdminEmail(trimmedEmail) && profile.isAdmin;

      if (!refreshedUser.emailVerified && !canBypassVerification) {
        await refreshedUser.sendEmailVerification();
        _needsEmailVerification = true;
        _pendingVerificationEmail = trimmedEmail;
        await _loadUserFromDatabase(refreshedUser.uid);
        _isLoading = false;
        _errorMessage =
            'Please verify your email to continue. A verification link has been sent.';
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      await _database.ref('users/${profile.uid}').update({
        'lastLogin': now.toIso8601String(),
      });

      _currentUser = profile.copyWith(lastLogin: now);
      await _saveSession(profile.uid);
      _isLoading = false;
      _needsEmailVerification = false;
      _pendingVerificationEmail = null;
      _errorMessage = null;
      notifyListeners();

      debugPrint('[Auth] Sign in successful: $trimmedEmail');
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        final adminBootstrap = await _trySeededAdminBootstrapLogin(
          email: trimmedEmail,
          password: password,
        );
        if (adminBootstrap) {
          return signIn(email: trimmedEmail, password: password);
        }
      }

      if (e.code == 'user-not-found') {
        _setError('Email not found. Please sign up');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        if (e.code == 'invalid-credential') {
          await _resolveInvalidCredential(trimmedEmail);
        } else {
          _setError('Incorrect password');
        }
      } else if (e.code == 'invalid-email') {
        _setError('Invalid email address');
      } else if (e.code == 'too-many-requests') {
        _setError('Too many login attempts. Please try again later');
      } else if (e.code == 'operation-not-allowed' ||
          e.code == 'invalid-api-key' ||
          e.code == 'app-not-authorized') {
        _setError(_authSetupMessage());
      } else {
        _setError('Sign in failed: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      final raw = e.toString();
      if (_looksLikeAuthConfigError(raw)) {
        _setError(_authSetupMessage());
      } else {
        _setError('Sign in error: $e');
      }
      return false;
    }
  }

  Future<bool> signInWithGoogle({bool requireNewAccount = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      late final fb_auth.UserCredential cred;

      if (kIsWeb) {
        final provider = fb_auth.GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        cred = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn(scopes: ['email']).signIn();

        if (googleUser == null) {
          _setError('Google sign in was cancelled');
          return false;
        }

        final googleAuth = await googleUser.authentication;
        final credential = fb_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _setError('Google sign in failed');
        return false;
      }

      final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
      final normalizedEmail = (firebaseUser.email ?? '').trim().toLowerCase();

      if (requireNewAccount &&
          (!isNewUser ||
              (normalizedEmail.isNotEmpty &&
                  await _emailExistsInDatabase(normalizedEmail)))) {
        if (!kIsWeb) {
          try {
            await GoogleSignIn().signOut();
          } catch (_) {}
        }
        await _auth.signOut();
        _setError('This Google account is already registered. Please sign in');
        return false;
      }

      String? successMessage;
      if (requireNewAccount && isNewUser) {
        await _sendFirstSocialConfirmationEmailIfPossible(firebaseUser);
        if (normalizedEmail.isNotEmpty) {
          successMessage =
              'Account created. A confirmation email was sent to $normalizedEmail';
        }
      }

      var profile = await _ensureUserProfile(
        firebaseUser: firebaseUser,
        name: firebaseUser.displayName,
      );
      profile = await _ensureSeededAdminRole(
        firebaseUser: firebaseUser,
        profile: profile,
      );

      final now = DateTime.now();
      await _database.ref('users/${profile.uid}').update({
        'lastLogin': now.toIso8601String(),
      });

      _currentUser = profile.copyWith(lastLogin: now);
      await _saveSession(profile.uid);
      _isLoading = false;
      _needsEmailVerification = false;
      _pendingVerificationEmail = null;
      _errorMessage = successMessage;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _setError('This email is already linked to another sign in method');
      } else if (e.code == 'operation-not-allowed' ||
          e.code == 'invalid-api-key' ||
          e.code == 'app-not-authorized') {
        _setError(_googleAuthSetupMessage());
      } else {
        _setError('Google sign in failed: ${e.message ?? e.code}');
      }
      return false;
    } on PlatformException catch (e) {
      final raw = '${e.code} ${e.message ?? ''} ${e.details ?? ''}';
      if (_looksLikeGoogleConfigError(raw)) {
        _setError(_googleAuthSetupMessage());
      } else {
        _setError('Google sign in failed: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      final raw = e.toString();
      if (_looksLikeAuthConfigError(raw) || _looksLikeGoogleConfigError(raw)) {
        _setError(_googleAuthSetupMessage());
      } else {
        _setError('Google sign in failed: $e');
      }
      return false;
    }
  }

  Future<bool> signInWithFacebook({bool requireNewAccount = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!kIsWeb &&
          defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS) {
        _setError(
          'Facebook sign in is supported on Android, iOS, and Web only',
        );
        return false;
      }

      late final fb_auth.UserCredential cred;

      if (kIsWeb) {
        final provider = fb_auth.FacebookAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'display': 'popup'});
        cred = await _auth.signInWithPopup(provider);
      } else {
        final result = await FacebookAuth.instance.login(
          permissions: const ['email', 'public_profile'],
        );

        if (result.status == LoginStatus.cancelled) {
          _setError('Facebook sign in was cancelled');
          return false;
        }

        if (result.status != LoginStatus.success ||
            result.accessToken == null) {
          _setError(result.message ?? 'Facebook sign in failed');
          return false;
        }

        final credential = fb_auth.FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _setError('Facebook sign in failed');
        return false;
      }

      final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
      final normalizedEmail = (firebaseUser.email ?? '').trim().toLowerCase();

      if (requireNewAccount &&
          (!isNewUser ||
              (normalizedEmail.isNotEmpty &&
                  await _emailExistsInDatabase(normalizedEmail)))) {
        if (!kIsWeb) {
          try {
            await FacebookAuth.instance.logOut();
          } catch (_) {}
        }
        await _auth.signOut();
        _setError(
          'This Facebook account is already registered. Please sign in',
        );
        return false;
      }

      String? successMessage;
      if (requireNewAccount && isNewUser) {
        await _sendFirstSocialConfirmationEmailIfPossible(firebaseUser);
        if (normalizedEmail.isNotEmpty) {
          successMessage =
              'Account created. A confirmation email was sent to $normalizedEmail';
        }
      }

      var profile = await _ensureUserProfile(
        firebaseUser: firebaseUser,
        name: firebaseUser.displayName,
      );
      profile = await _ensureSeededAdminRole(
        firebaseUser: firebaseUser,
        profile: profile,
      );

      final now = DateTime.now();
      await _database.ref('users/${profile.uid}').update({
        'lastLogin': now.toIso8601String(),
      });

      _currentUser = profile.copyWith(lastLogin: now);
      await _saveSession(profile.uid);
      _isLoading = false;
      _needsEmailVerification = false;
      _pendingVerificationEmail = null;
      _errorMessage = successMessage;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _setError('This email is already linked to another sign in method');
      } else if (e.code == 'operation-not-allowed' ||
          e.code == 'invalid-api-key' ||
          e.code == 'app-not-authorized') {
        _setError(_facebookAuthSetupMessage());
      } else {
        _setError('Facebook sign in failed: ${e.message ?? e.code}');
      }
      return false;
    } on PlatformException catch (e) {
      final raw = '${e.code} ${e.message ?? ''} ${e.details ?? ''}';
      if (_looksLikeFacebookConfigError(raw)) {
        _setError(_facebookAuthSetupMessage());
      } else {
        _setError('Facebook sign in failed: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      final raw = e.toString();
      if (_looksLikeAuthConfigError(raw) ||
          _looksLikeFacebookConfigError(raw)) {
        _setError(_facebookAuthSetupMessage());
      } else {
        _setError('Facebook sign in failed: $e');
      }
      return false;
    }
  }

  Future<void> _resolveInvalidCredential(String email) async {
    try {
      final inIndex = await _database
          .ref('email_index/${_encodeEmail(email)}')
          .get()
          .timeout(const Duration(seconds: 8));

      if (!inIndex.exists) {
        _setError('Email not found. Please sign up');
        return;
      }

      _setError(
        'Incorrect credentials. Try "Forgot Password" or create a new account.',
      );
    } catch (_) {
      _setError('Incorrect password');
    }
  }

  String _seedAdminName(String email) {
    for (final admin in _seedAdminAccounts) {
      if (admin.$1 == email) {
        return admin.$3;
      }
    }
    return 'Admin';
  }

  Future<UserModel> _ensureSeededAdminRole({
    required fb_auth.User firebaseUser,
    required UserModel profile,
  }) async {
    final email = (firebaseUser.email ?? '').trim().toLowerCase();
    if (!_isSeededAdminEmail(email) || profile.isAdmin) {
      return profile;
    }

    final adminName = _seedAdminName(email);
    await _database
        .ref('users/${profile.uid}')
        .update({'email': email, 'name': adminName, 'isAdmin': true})
        .timeout(const Duration(seconds: 8));

    await _database
        .ref('email_index/${_encodeEmail(email)}')
        .set({'uid': profile.uid})
        .timeout(const Duration(seconds: 8));

    return profile.copyWith(email: email, name: adminName, isAdmin: true);
  }

  bool _isSeededAdminEmail(String email) {
    return _seedAdminAccounts.any((admin) => admin.$1 == email);
  }

  Future<bool> _trySeededAdminBootstrapLogin({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isSeededAdminEmail(email)) {
        return false;
      }
      final emailIndex = await _database
          .ref('email_index/${_encodeEmail(email)}')
          .get()
          .timeout(const Duration(seconds: 8));

      if (!emailIndex.exists || emailIndex.value is! Map) {
        return false;
      }

      final uid = (emailIndex.value as Map)['uid'] as String?;
      if (uid == null || uid.isEmpty) {
        return false;
      }

      final userSnap = await _database
          .ref('users/$uid')
          .get()
          .timeout(const Duration(seconds: 8));

      if (!userSnap.exists || userSnap.value is! Map) {
        return false;
      }

      final userData = Map<String, dynamic>.from(userSnap.value as Map);
      final isAdmin = userData['isAdmin'] == true;
      final storedHash = userData['passwordHash'] as String?;
      if (!isAdmin || storedHash == null) {
        return false;
      }

      if (storedHash != _hashPassword(password)) {
        return false;
      }

      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('[Auth] Admin bootstrap login failed for $email: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────

  Future<bool> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {
          // Best effort: keep Firebase sign out successful even if Google cache fails.
        }
        try {
          await FacebookAuth.instance.logOut();
        } catch (_) {
          // Best effort: keep Firebase sign out successful even if Facebook cache fails.
        }
      }
      await _auth.signOut();
      await _clearSession();
      _currentUser = null;
      _needsEmailVerification = false;
      _pendingVerificationEmail = null;
      _errorMessage = null;
      notifyListeners();
      debugPrint('[Auth] 👋 Signed out');
      return true;
    } catch (e) {
      debugPrint('[Auth] Error signing out: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Update Profile
  // ─────────────────────────────────────────────────

  Future<bool> updateUserProfile({
    required String name,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{'name': name.trim()};
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();

      await _database
          .ref('users/${_currentUser!.uid}')
          .update(updates)
          .timeout(const Duration(seconds: 10));

      _currentUser = _currentUser!.copyWith(
        name: name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[Auth] Error updating profile: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Change Password
  // ─────────────────────────────────────────────────

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      _setError('Please sign in first');
      return false;
    }

    try {
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        _setError('All fields are required');
        return false;
      }
      if (newPassword.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      final firebaseUser = _auth.currentUser;
      final email = firebaseUser?.email;
      if (firebaseUser == null || email == null || email.isEmpty) {
        _setError('Invalid user session. Please sign in again');
        return false;
      }

      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPassword);

      final uid = _currentUser!.uid;
      final nowIso = DateTime.now().toIso8601String();
      await _database
          .ref('users/$uid')
          .update({
            // Keep hash for compatibility with old data only.
            'passwordHash': _hashPassword(newPassword),
            'passwordUpdatedAt': nowIso,
          })
          .timeout(const Duration(seconds: 10));

      await _database.ref('user_activity/$uid/password_changes').push().set({
        'changedAt': nowIso,
      });

      _errorMessage = null;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _setError('Current password is incorrect');
      } else if (e.code == 'requires-recent-login') {
        _setError('Please sign in again and try again');
      } else if (e.code == 'weak-password') {
        _setError('New password is too weak');
      } else {
        _setError('Failed to change password: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      _setError('Failed to change password: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Account switch logging
  // ─────────────────────────────────────────────────

  Future<void> logAccountSwitch() async {
    if (_currentUser == null) return;
    try {
      final uid = _currentUser!.uid;
      final nowIso = DateTime.now().toIso8601String();
      await _database.ref('users/$uid').update({'lastAccountSwitchAt': nowIso});
      await _database.ref('user_activity/$uid/account_switches').push().set({
        'switchedAt': nowIso,
      });
    } catch (e) {
      debugPrint('[Auth] Error logging account switch: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
    debugPrint('[Auth] Error: $message');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resendVerificationEmail() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    await firebaseUser.sendEmailVerification();
    _needsEmailVerification = true;
    _pendingVerificationEmail = firebaseUser.email;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      _setError('Please enter your email');
      return false;
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      _errorMessage =
          'Password reset link sent to $trimmedEmail. Check your email to reset your password.';
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        _setError('Email not found');
      } else {
        _setError('Failed to send password reset email');
      }
      return false;
    } catch (_) {
      _setError('Failed to send password reset email');
      return false;
    }
  }

  Future<bool> refreshVerificationAndSyncSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;

    await firebaseUser.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null || !refreshed.emailVerified) {
      _needsEmailVerification = true;
      _pendingVerificationEmail = refreshed?.email ?? _pendingVerificationEmail;
      notifyListeners();
      return false;
    }

    final profile = await _ensureUserProfile(firebaseUser: refreshed);
    final now = DateTime.now();
    await _database.ref('users/${profile.uid}').update({
      'lastLogin': now.toIso8601String(),
    });

    _currentUser = profile.copyWith(lastLogin: now);
    await _saveSession(profile.uid);
    _needsEmailVerification = false;
    _pendingVerificationEmail = null;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool _looksLikeAuthConfigError(String raw) {
    final txt = raw.toLowerCase();
    return txt.trim() == 'error' ||
        txt.contains('configuration_not_found') ||
        txt.contains('getprojectconfig') ||
        txt.contains('identitytoolkit') ||
        txt.contains('operation-not-allowed') ||
        txt.contains('invalid-api-key') ||
        txt.contains('app-not-authorized');
  }

  String _authSetupMessage() {
    return 'Authentication setup is incomplete in Firebase.\n\n'
        'Enable Email/Password in:\n'
        'Firebase Console > Authentication > Sign-in method\n\n'
        'Also verify Authorized domains include localhost.';
  }

  bool _looksLikeGoogleConfigError(String raw) {
    final txt = raw.toLowerCase();
    return txt.contains('developer_error') ||
        txt.contains('api exception: 10') ||
        txt.contains('sign_in_failed') ||
        txt.contains('12500') ||
        txt.contains('12501') ||
        txt.contains('oauth') ||
        txt.contains('sha-1') ||
        txt.contains('sha1') ||
        txt.contains('google_sign_in');
  }

  String _googleAuthSetupMessage() {
    return 'Google sign-in is not fully configured.\n\n'
        'Required steps in Firebase:\n'
        '1) Authentication > Sign-in method > Enable Google\n'
        '2) Project settings > Your Android app > Add SHA-1 and SHA-256\n'
        '3) Download the updated google-services.json and replace android/app/google-services.json\n\n'
        'Then run: flutter clean ; flutter pub get ; flutter run';
  }

  Future<bool> _emailExistsInDatabase(String email) async {
    try {
      final emailKey = _encodeEmail(email);
      final emailIndexSnap = await _database
          .ref('email_index/$emailKey')
          .get()
          .timeout(const Duration(seconds: 8));

      if (!emailIndexSnap.exists || emailIndexSnap.value is! Map) {
        return false;
      }

      final uid = (emailIndexSnap.value as Map)['uid'] as String?;
      if (uid == null || uid.isEmpty) {
        return false;
      }

      final userSnap = await _database
          .ref('users/$uid')
          .get()
          .timeout(const Duration(seconds: 8));

      return userSnap.exists;
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendFirstSocialConfirmationEmailIfPossible(
    fb_auth.User firebaseUser,
  ) async {
    try {
      await firebaseUser.sendEmailVerification();
    } catch (_) {
      // Some social providers already verify email and may reject this call.
    }
  }

  bool _looksLikeFacebookConfigError(String raw) {
    final txt = raw.toLowerCase();
    return txt.contains('facebook') ||
        txt.contains('invalid key hash') ||
        txt.contains('keyhash') ||
        txt.contains('app id') ||
        txt.contains('oauth') ||
        txt.contains('login_failed') ||
        txt.contains('operation_not_supported') ||
        txt.contains('missingpluginexception');
  }

  String _facebookAuthSetupMessage() {
    return 'Facebook sign-in is not fully configured.\n\n'
        'Required setup:\n'
        '1) Firebase Authentication > Sign-in method > Enable Facebook\n'
        '2) Add Facebook App ID and App Secret in Firebase\n'
        '3) In Facebook Developers, add Android package name and key hashes\n'
        '4) Make sure OAuth redirect URI from Firebase is added in Facebook app settings\n\n'
        'Then run: flutter clean ; flutter pub get ; flutter run';
  }
}
