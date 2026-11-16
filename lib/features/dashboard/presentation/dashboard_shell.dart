import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import 'widgets/side_menu.dart';

/// Frame around every dashboard page: a permanent side menu on a wide window,
/// and the same menu behind a drawer on a narrow one.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.sizeOf(context).width >= AppConfig.wideLayoutBreakpoint;

    if (wide) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            const SideMenu(),
            const VerticalFDivider(),
            Expanded(child: SafeArea(child: child)),
          ],
        ),
      );
    }

    final MenuDestination? current = destinationFor(
      GoRouterState.of(context).uri.path,
    );

    return Scaffold(
      appBar: AppBar(title: Text(current?.label ?? 'Stark VMS')),
      drawer: Drawer(
        width: SideMenu.width,
        child: Builder(
          builder: (BuildContext context) => SideMenu(
            onNavigate: () => Scaffold.of(context).closeDrawer(),
          ),
        ),
      ),
      body: child,
    );
  }
}
