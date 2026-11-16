import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../config/app_config.dart';

/// Opens [builder] as a panel: sliding in from the right and covering 40% of
/// a desktop window, and rising from the bottom on a narrow one.
///
/// The panel paints its own opaque background, so the page behind it only
/// shows through the scrim.
Future<T?> showResponsiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final Size screen = MediaQuery.sizeOf(context);
  final bool wide = screen.width >= AppConfig.wideLayoutBreakpoint;

  // 40% of the window, kept readable on very wide and very narrow desktops.
  final double width = (screen.width * AppConfig.sideSheetWidthRatio).clamp(
    AppConfig.sideSheetMinWidth,
    AppConfig.sideSheetMaxWidth,
  );

  return showFSheet<T>(
    context: context,
    side: wide ? FLayout.rtl : FLayout.btt,
    mainAxisMaxRatio: wide ? null : 0.92,
    constraints: wide
        ? BoxConstraints.tightFor(width: width)
        : const BoxConstraints(),
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      final FThemeData theme = sheetContext.theme;

      return Container(
        height: wide ? MediaQuery.sizeOf(sheetContext).height : null,
        decoration: BoxDecoration(
          color: theme.colors.background,
          border: wide
              ? Border(left: BorderSide(color: theme.colors.border))
              : null,
        ),
        child: SafeArea(top: false, child: Builder(builder: builder)),
      );
    },
  );
}
