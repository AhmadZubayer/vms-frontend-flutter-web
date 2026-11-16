import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Asks before an action that cannot be undone.
///
/// Answers `true` only when the person chose [confirmLabel].
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FButton(variant: FButtonVariant.ghost, mainAxisSize: MainAxisSize.min,
            onPress: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FButton(mainAxisSize: MainAxisSize.min,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPress: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
