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
  const SideMenu({super.key, this.onNavigate, this.location});

  final String? location;

  /// Called after a destination is chosen, so a drawer can close itself.
  final VoidCallback? onNavigate;

  static const double width = 276;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLocation =
        location ?? GoRouterState.of(context).uri.path;
    final MenuDestination? current = destinationFor(currentLocation);

    return SizedBox(
      width: width,
      child: FSidebar(
        header: const _Brand(),
        footer: _AccountTile(onSignedOut: onNavigate),
        children: [
          for (final destination in dashboardDestinations)
            _MenuItem(
              destination: destination,
              selected: destination == current,
              onPress: () {
                if (destination != current) context.go(destination.path);
                onNavigate?.call();
              },
            ),
        ],
      ),
    );
  }
}

/// One menu entry.
///
/// Hover is a quiet grey wash and the selected entry is a tinted pill in the
/// primary colour, so the two never read the same.
class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.destination,
    required this.selected,
    required this.onPress,
  });

  final MenuDestination destination;
  final bool selected;
  final VoidCallback onPress;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    final Color background = widget.selected
        ? theme.colors.primary.withValues(alpha: 0.12)
        : _hovered
        ? theme.colors.muted
        : const Color(0x00000000);

    final Color foreground = widget.selected
        ? theme.colors.primary
        : _hovered
        ? theme.colors.foreground
        : theme.colors.mutedForeground;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPress,
          child: Semantics(
            button: true,
            selected: widget.selected,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  Icon(widget.destination.icon, size: 18, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: foreground,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Product mark at the top of the side menu.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: theme.colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              FLucideIcons.car,
              size: 20,
              color: theme.colors.primaryForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stark VMS',
                  style: theme.typography.body.lg.copyWith(
                    color: theme.colors.primary,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Vehicle registry',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colors.background,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colors.border),
              ),
              child: Text(
                account.isEmpty ? '?' : account.characters.first.toUpperCase(),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Signed in',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  FTooltip(
                    tipBuilder: (context, controller) => Text(account),
                    child: Text(
                      account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            FButton.icon(
              variant: FButtonVariant.ghost,
              onPress: _signingOut ? null : _signOut,
              semanticsLabel: 'Log out',
              child: _signingOut
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: FCircularProgress(),
                    )
                  : const Icon(FLucideIcons.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
