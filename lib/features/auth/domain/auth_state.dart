import 'auth_user.dart';

/// Why the app is showing the sign-in screen.
enum SignOutReason {
  /// Nobody has signed in yet, or they signed out on purpose.
  none,

  /// The API rejected the stored token, so the session ended on its own.
  sessionExpired,
}

/// Who, if anyone, is signed in.
sealed class AuthState {
  const AuthState();
}

/// The stored token is still being checked against the API.
class AuthRestoring extends AuthState {
  const AuthRestoring();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.reason = SignOutReason.none});

  final SignOutReason reason;
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.user);

  final AuthUser user;
}
