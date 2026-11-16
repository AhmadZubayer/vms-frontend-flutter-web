import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<SessionEvents> sessionEventsProvider = Provider<SessionEvents>((
  Ref ref,
) {
  final SessionEvents events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

/// Carries "the token is no longer accepted" from the HTTP layer to the auth
/// layer without the two depending on each other.
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _expired.stream;

  void reportSessionExpired() {
    if (!_expired.isClosed) {
      _expired.add(null);
    }
  }

  void dispose() => _expired.close();
}
