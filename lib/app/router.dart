import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/dashboard/presentation/dashboard_shell.dart';
import '../features/dashboard/presentation/overview_page.dart';
import '../features/errors/presentation/not_found_page.dart';
import '../features/errors/presentation/unauthorized_page.dart';
import '../features/vehicles/presentation/vehicles_page.dart';
import 'routes.dart';

/// The app router, rebuilt against the session so a signed-out operator
/// cannot sit on a dashboard page.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  // go_router re-runs its redirect whenever this notifies.
  final ValueNotifier<int> sessionChanges = ValueNotifier<int>(0);
  ref.listen<AuthState>(
    authControllerProvider,
    (AuthState? _, AuthState _) => sessionChanges.value++,
  );
  ref.onDispose(sessionChanges.dispose);

  return GoRouter(
    initialLocation: AppRoutes.root,
    refreshListenable: sessionChanges,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.uri.path;

      if (auth is AuthRestoring) {
        return null;
      }

      if (auth is AuthSignedIn) {
        final bool onEntryPage =
            location == AppRoutes.login ||
            location == AppRoutes.unauthorized ||
            location == AppRoutes.root;
        return onEntryPage ? AppRoutes.dashboard : null;
      }

      // A session that the API ended deserves an explanation, not the form.
      if (auth is AuthSignedOut &&
          auth.reason == SignOutReason.sessionExpired) {
        return location == AppRoutes.unauthorized
            ? null
            : AppRoutes.unauthorized;
      }

      final bool openToGuests =
          location == AppRoutes.login ||
          location == AppRoutes.unauthorized ||
          location == AppRoutes.notFound;
      return openToGuests ? null : AppRoutes.login;
    },
    errorBuilder: (BuildContext context, GoRouterState state) =>
        NotFoundPage(location: state.uri.path),
    routes: <RouteBase>[
      GoRoute(
        // The site root is the sign-in screen; a signed-in operator is sent
        // on to the dashboard by the redirect above.
        path: AppRoutes.root,
        redirect: (BuildContext _, GoRouterState _) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext _, GoRouterState _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (BuildContext _, GoRouterState _) => const UnauthorizedPage(),
      ),
      GoRoute(
        path: AppRoutes.notFound,
        builder: (BuildContext _, GoRouterState _) => const NotFoundPage(),
      ),
      ShellRoute(
        builder: (BuildContext _, GoRouterState _, Widget child) =>
            DashboardShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (BuildContext _, GoRouterState _) => const OverviewPage(),
          ),
          GoRoute(
            path: AppRoutes.vehicles,
            builder: (BuildContext _, GoRouterState _) => const VehiclesPage(),
          ),
        ],
      ),
    ],
  );
});
