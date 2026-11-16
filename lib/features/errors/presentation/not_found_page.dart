import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'error_page_scaffold.dart';

/// Shown for any path the router does not know.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.location});

  /// The path that was asked for, when the router could supply it.
  final String? location;

  @override
  Widget build(BuildContext context) {
    final String? asked = location;

    return ErrorPageScaffold(
      icon: FLucideIcons.compass,
      code: '404',
      title: 'Page not found',
      message: asked == null || asked.isEmpty
          ? 'That page does not exist.'
          : 'There is nothing at $asked.',
      actions: <Widget>[
        FButton(mainAxisSize: MainAxisSize.min,
          onPress: () => context.go(AppRoutes.dashboard),
          child: const Text('Go to dashboard'),
        ),
        FButton(variant: FButtonVariant.outline, mainAxisSize: MainAxisSize.min,
          onPress: () => context.go(AppRoutes.vehicles),
          child: const Text('Go to vehicles'),
        ),
      ],
    );
  }
}
