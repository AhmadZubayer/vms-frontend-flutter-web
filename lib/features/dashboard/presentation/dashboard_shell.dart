import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import 'widgets/side_menu.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= AppConfig.wideLayoutBreakpoint;
    if (wide) {
      return FScaffold(
        childPad: false,
        sidebar: const SideMenu(),
        child: child,
      );
    }
    final location = GoRouterState.of(context).uri.path;
    final current = destinationFor(location);
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(current?.label ?? 'Stark VMS'),
        prefixes: [
          FButton.icon(
            variant: FButtonVariant.ghost,
            semanticsLabel: 'Open navigation',
            onPress: () => showFSheet<void>(
              context: context,
              side: FLayout.ltr,
              constraints: const BoxConstraints.tightFor(width: SideMenu.width),
              mainAxisMaxRatio: null,
              builder: (sheetContext) => SideMenu(
                location: location,
                onNavigate: () => Navigator.of(sheetContext).pop(),
              ),
            ),
            child: const Icon(FLucideIcons.menu),
          ),
        ],
      ),
      child: child,
    );
  }
}
