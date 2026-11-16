import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_controller.dart';
import 'error_page_scaffold.dart';

/// Shown when the API rejects the stored token, or when a dashboard page is
/// opened without signing in.
class UnauthorizedPage extends ConsumerWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authControllerProvider);
    final bool expired =
        auth is AuthSignedOut && auth.reason == SignOutReason.sessionExpired;

    return ErrorPageScaffold(
      icon: FLucideIcons.lockKeyhole,
      code: '401',
      title: expired ? 'Your session has ended' : 'Sign-in required',
      message: expired
          ? 'The access token is no longer accepted. Sign in again to carry on.'
          : 'This page is only available to a signed-in operator.',
      actions: <Widget>[
        FButton(mainAxisSize: MainAxisSize.min,
          onPress: () {
            ref.read(authControllerProvider.notifier).acknowledgeSessionEnd();
            context.go(AppRoutes.login);
          },
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}
