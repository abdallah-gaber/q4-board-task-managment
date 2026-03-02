import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/services/auth_service.dart';

class FirebaseAuthServiceImpl implements AuthService {
  FirebaseAuthServiceImpl(this._auth, {GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ?? (kIsWeb ? null : GoogleSignIn(scopes: ['email']));

  final FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;

  @override
  AuthAvailability get availability => AuthAvailability.enabled;

  @override
  AuthSession get currentSession => _mapUser(_auth.currentUser);

  @override
  Stream<AuthSession> watchSession() {
    return Stream<AuthSession>.multi((multi) {
      multi.add(currentSession);
      final authSub = _auth.authStateChanges().listen((user) {
        multi.add(_mapUser(user));
      });
      multi.onCancel = () async {
        await authSub.cancel();
      };
    });
  }

  @override
  Future<void> signIn() async {
    if (_auth.currentUser != null) {
      return;
    }
    await _auth.signInAnonymously();
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()..addScope('email');
      await _signInOrLinkWithPopup(provider);
      return;
    }

    final googleSignIn = _googleSignIn;
    if (googleSignIn == null) {
      throw StateError('google-sign-in-unavailable');
    }
    GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } catch (error) {
      // Surface the original plugin/Firebase error if available.
      rethrow;
    }
    if (account == null) {
      throw StateError('google-sign-in-cancelled');
    }

    final auth = await account.authentication;
    if (auth.idToken == null && auth.accessToken == null) {
      throw StateError('google-sign-in-missing-token');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    await _signInOrLinkWithCredential(credential);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        await current.linkWithCredential(
          EmailAuthProvider.credential(
            email: normalizedEmail,
            password: password,
          ),
        );
        return;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'email-already-in-use' &&
            error.code != 'credential-already-in-use') {
          rethrow;
        }
        // Existing account: sign in to that account. The app can then pull/merge.
      }
    }

    await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: normalizedEmail,
        password: password,
      );
      await current.linkWithCredential(credential);
      return;
    }
    await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = _googleSignIn;
    if (!kIsWeb && googleSignIn != null) {
      try {
        await googleSignIn.signOut();
      } catch (_) {
        // Firebase sign-out still proceeds even if GoogleSignIn local state is stale.
      }
    }
    await _auth.signOut();
  }

  Future<void> _signInOrLinkWithCredential(AuthCredential credential) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        await current.linkWithCredential(credential);
        return;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use' &&
            error.code != 'provider-already-linked' &&
            error.code != 'email-already-in-use') {
          rethrow;
        }
        if (error.code == 'provider-already-linked') {
          return;
        }
        // Existing provider account: sign into it instead.
      }
    }
    await _auth.signInWithCredential(credential);
  }

  Future<void> _signInOrLinkWithPopup(GoogleAuthProvider provider) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        await current.linkWithPopup(provider);
        return;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use' &&
            error.code != 'provider-already-linked' &&
            error.code != 'email-already-in-use') {
          rethrow;
        }
        if (error.code == 'provider-already-linked') {
          return;
        }
      }
    }
    await _auth.signInWithPopup(provider);
  }

  AuthSession _mapUser(User? user) {
    if (user == null) {
      return const AuthSession(userId: null, isAuthenticated: false);
    }

    final providerIds = user.providerData
        .map((provider) => provider.providerId)
        .toSet();
    final providerKind = user.isAnonymous
        ? AuthProviderKind.anonymous
        : providerIds.contains('google.com')
        ? AuthProviderKind.google
        : providerIds.contains('password')
        ? AuthProviderKind.emailPassword
        : providerIds.contains('apple.com')
        ? AuthProviderKind.apple
        : providerIds.isEmpty
        ? AuthProviderKind.unknown
        : AuthProviderKind.unknown;

    return AuthSession(
      userId: user.uid,
      isAuthenticated: true,
      providerKind: providerKind,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName: user.displayName,
    );
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  static const _session = AuthSession(userId: null, isAuthenticated: false);

  @override
  AuthAvailability get availability => AuthAvailability.unavailable;

  @override
  AuthSession get currentSession => _session;

  @override
  Stream<AuthSession> watchSession() => Stream<AuthSession>.value(_session);

  @override
  Future<void> signIn() async {
    throw StateError('Firebase auth is not available.');
  }

  @override
  Future<void> signInWithGoogle() async {
    throw StateError('Firebase auth is not available.');
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    throw StateError('Firebase auth is not available.');
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    throw StateError('Firebase auth is not available.');
  }

  @override
  Future<void> signOut() async {}
}
