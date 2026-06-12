import 'package:fqa/models/auth_user.dart';

abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser?> signInWithGoogle();
  Future<void> signOut();
}

class NoopAuthService implements AuthService {
  const NoopAuthService();

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser?> signInWithGoogle() {
    throw StateError('Firebase is not configured.');
  }

  @override
  Future<void> signOut() async {}
}
