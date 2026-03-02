enum AuthProviderKind { none, anonymous, emailPassword, google, apple, unknown }

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.isAuthenticated,
    this.providerKind = AuthProviderKind.none,
    this.isAnonymous = false,
    this.email,
    this.displayName,
  });

  final String? userId;
  final bool isAuthenticated;
  final AuthProviderKind providerKind;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
}

enum AuthAvailability { enabled, unavailable }

abstract interface class AuthService {
  Stream<AuthSession> watchSession();

  AuthSession get currentSession;

  AuthAvailability get availability;

  Future<void> signIn();

  Future<void> signInWithGoogle();

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
