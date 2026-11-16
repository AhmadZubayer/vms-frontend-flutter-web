import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../config/app_config.dart';

/// Opens [builder] as a panel sliding in from the right on a wide window, and
/// from the bottom on a narrow one.
Future<T?> showResponsiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double width = 460,
}) {
  final bool wide =
      MediaQuery.sizeOf(context).width >= AppConfig.wideLayoutBreakpoint;

  if (!wide) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: builder,
    );
  }

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (BuildContext context, Animation<double> _, Animation<double> _) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            minWidth: width,
            maxHeight: MediaQuery.sizeOf(context).height,
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(child: Builder(builder: builder)),
          ),
        ),
      );
    },
    transitionBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> _,
      Widget child,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}
