import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fqa/models/auth_user.dart';
import 'package:fqa/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  @override
  AuthUser? get currentUser => _firebaseAuth.currentUser?.toAuthUser();

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.toAuthUser());
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final UserCredential credential;
    if (kIsWeb) {
      credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
    } else {
      await _ensureGoogleInitialized();
      if (!_googleSignIn.supportsAuthenticate()) {
        throw StateError('Google sign-in is not available on this platform.');
      }
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      credential = await _firebaseAuth.signInWithCredential(oauthCredential);
    }
    return credential.user?.toAuthUser();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _googleSignIn.initialize();
  }
}

extension on User {
  AuthUser toAuthUser() {
    return AuthUser(
      uid: uid,
      displayName: displayName,
      email: email,
      photoUrl: photoURL,
    );
  }
}
