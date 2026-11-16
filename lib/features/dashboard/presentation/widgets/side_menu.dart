import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/auth_controller.dart';

/// One entry in the side menu.
class MenuDestination {
  const MenuDestination({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}

const List<MenuDestination> dashboardDestinations = <MenuDestination>[
  MenuDestination(
    label: 'Dashboard',
    icon: FLucideIcons.layoutDashboard,
    path: AppRoutes.dashboard,
  ),
  MenuDestination(
    label: 'Vehicles',
    icon: FLucideIcons.car,
    path: AppRoutes.vehicles,
  ),
];

/// Returns the destination that matches [location], longest path first so
/// `/dashboard/vehicles` does not match `/dashboard`.
MenuDestination? destinationFor(String location) {
  final List<MenuDestination> byDepth = dashboardDestinations.toList()
    ..sort(
      (MenuDestination a, MenuDestination b) =>
          b.path.length.compareTo(a.path.length),
    );

  for (final MenuDestination destination in byDepth) {
    if (location == destination.path ||
        location.startsWith('${destination.path}/')) {
      return destination;
    }
  }
  return null;
}

/// The dashboard side menu: product name, the sections, and the signed-in
/// account with its sign-out button at the bottom.
class SideMenu extends ConsumerWidget {
  const SideMenu({super.key, this.onNavigate});

  /// Called after a destination is chosen, so a drawer can close itself.
  final VoidCallback? onNavigate;

  static const double width = 264;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FThemeData theme = context.theme;
    final String location = GoRouterState.of(context).uri.path;
    final MenuDestination? current = destinationFor(location);

    return SizedBox(
      width: width,
      child: Material(
        color: theme.colors.card,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Text(
                  'Stark VMS',
                  style: theme.typography.display.xl.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: <Widget>[
                    for (final MenuDestination destination
                        in dashboardDestinations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(destination.icon),
                          title: Text(destination.label),
                          selected: destination == current,
                          selectedTileColor:
                              theme.colorScheme.secondaryContainer,
                          selectedColor: theme.colorScheme.onSecondaryContainer,
                          onTap: () {
                            if (destination != current) {
                              context.go(destination.path);
                            }
                            onNavigate?.call();
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const FDivider(),
              _AccountTile(onSignedOut: onNavigate),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends ConsumerStatefulWidget {
  const _AccountTile({this.onSignedOut});

  final VoidCallback? onSignedOut;

  @override
  ConsumerState<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<_AccountTile> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) {
      return;
    }
    setState(() => _signingOut = true);

    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) {
        AppToast.success(context, 'Signed out.');
        widget.onSignedOut?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final AuthState auth = ref.watch(authControllerProvider);
    final String account = auth is AuthSignedIn
        ? auth.user.userEmail
        : 'Signed out';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      child: Row(
        children: <Widget>[
          Icon(
            FLucideIcons.circleUser,
            color: theme.colors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Signed in as',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                Tooltip(
                  message: account,
                  child: Text(
                    account,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.base,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          FButton.icon(variant: FButtonVariant.ghost,
            onPress: _signingOut ? null : _signOut,
            semanticsLabel: 'Log out',
            icon: _signingOut
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: FCircularProgress(),
                  )
                : const Icon(FLucideIcons.logOut),
          ),
        ],
      ),
    );
  }
}
