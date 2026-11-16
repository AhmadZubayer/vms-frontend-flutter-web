import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/session_events.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';
import '../domain/auth_user.dart';

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Holds the session for the whole app and keeps it in step with the API.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final StreamSubscription<void> subscription = ref
        .watch(sessionEventsProvider)
        .sessionExpired
        .listen((void _) => _onSessionExpired());
    ref.onDispose(subscription.cancel);

    // Checking the stored token takes a round trip, so start in the restoring
    // state and settle once the API has answered.
    Future<void>.microtask(_restore);

    return const AuthRestoring();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Settles the session exactly once.
  ///
  /// Everything here is guarded: whatever goes wrong, the app must leave the
  /// restoring state, or it would sit on the splash screen for ever.
  Future<void> _restore() async {
    try {
      final String? token = await _repository.storedToken();
      if (token == null || token.isEmpty) {
        state = const AuthSignedOut();
        return;
      }

      final AuthUser user = await _repository.currentUser();
      state = AuthSignedIn(user);
    } on Object catch (error, stackTrace) {
      // A token the API no longer accepts is worth nothing, and a broken
      // client configuration must still reach the sign-in screen.
      debugPrint('Session could not be restored: $error');
      debugPrintStack(stackTrace: stackTrace);
      try {
        await _repository.forgetToken();
      } on Object {
        // Nothing left to clean up.
      }
      state = const AuthSignedOut();
    }
  }

  /// Signs in, or throws the API failure for the form to show.
  Future<void> signIn({
    required String userEmail,
    required String password,
  }) async {
    final AuthUser user = await _repository.signIn(
      userEmail: userEmail,
      password: password,
    );
    state = AuthSignedIn(user);
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } finally {
      state = const AuthSignedOut();
    }
  }

  /// Drops the "your session ended" notice, so the sign-in screen can be
  /// shown again instead of the unauthorized page.
  void acknowledgeSessionEnd() {
    if (state is AuthSignedOut) {
      state = const AuthSignedOut();
    }
  }

  void _onSessionExpired() {
    if (state is! AuthSignedIn) {
      return;
    }

    _repository.forgetToken();
    state = const AuthSignedOut(reason: SignOutReason.sessionExpired);
  }
}
