import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../app/theme.dart';

enum ToastKind { success, error, info }

class AppToast {
  const AppToast._();

  static void success(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.error);

  static void show(
    BuildContext context,
    String message, {
    ToastKind kind = ToastKind.info,
  }) {
    showFToast(
      context: context,
      title: Text(message),
      alignment: FToastAlignment.topCenter,
      duration: const Duration(seconds: 3),
      variant: kind == ToastKind.error
          ? FToastVariant.destructive
          : FToastVariant.primary,
      icon: Icon(switch (kind) {
        ToastKind.success => FLucideIcons.circleCheck,
        ToastKind.error => FLucideIcons.circleAlert,
        ToastKind.info => FLucideIcons.info,
      }, color: kind == ToastKind.success ? AppTheme.success : null),
      suffixBuilder: (context, entry) => FButton.icon(
        variant: FButtonVariant.ghost,
        semanticsLabel: 'Dismiss',
        onPress: entry.dismiss,
        child: const Icon(FLucideIcons.x),
      ),
    );
  }
}
