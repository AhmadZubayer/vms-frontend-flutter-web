import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// What a toast is reporting, which decides its icon and border.
enum ToastKind { success, error, info }

/// Short confirmations shown at the top middle of the screen.
///
/// Toasts live in the root overlay, so they survive the page changing and
/// stack downwards when several arrive at once.
class AppToast {
  const AppToast._();

  static const Duration _visibleFor = Duration(seconds: 3);

  static final ValueNotifier<List<_ToastMessage>> _messages =
      ValueNotifier<List<_ToastMessage>>(<_ToastMessage>[]);
  static OverlayEntry? _entry;
  static int _nextId = 0;

  static void success(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.error);

  static void show(
    BuildContext context,
    String message, {
    ToastKind kind = ToastKind.info,
  }) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    if (_entry == null) {
      _entry = OverlayEntry(builder: (BuildContext _) => const _ToastLayer());
      overlay.insert(_entry!);
    }

    final _ToastMessage toast = _ToastMessage(
      id: _nextId++,
      message: message,
      kind: kind,
    );
    _messages.value = <_ToastMessage>[..._messages.value, toast];
    Timer(_visibleFor, () => _dismiss(toast.id));
  }

  static void _dismiss(int id) {
    _messages.value = _messages.value
        .where((_ToastMessage toast) => toast.id != id)
        .toList(growable: false);

    if (_messages.value.isEmpty) {
      _entry?.remove();
      _entry = null;
    }
  }
}

class _ToastMessage {
  const _ToastMessage({
    required this.id,
    required this.message,
    required this.kind,
  });

  final int id;
  final String message;
  final ToastKind kind;
}

class _ToastLayer extends StatelessWidget {
  const _ToastLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      left: 16,
      right: 16,
      child: ValueListenableBuilder<List<_ToastMessage>>(
        valueListenable: AppToast._messages,
        builder: (BuildContext context, List<_ToastMessage> toasts, Widget? _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final _ToastMessage toast in toasts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ToastFCard(
                    key: ValueKey<int>(toast.id),
                    toast: toast,
                    onDismiss: () => AppToast._dismiss(toast.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastFCard({super.key, required this.toast, required this.onDismiss});

  final _ToastMessage toast;
  final VoidCallback onDismiss;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.25),
          end: Offset.zero,
        ).animate(curve),
        child: Align(
          child: Semantics(
            liveRegion: true,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              color: theme.colors.foreground,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        _icon,
                        size: 20,
                        color: theme.colors.background,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.toast.message,
                          style: theme.typography.body.base.copyWith(
                            color: theme.colors.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FButton.icon(variant: FButtonVariant.ghost,
                        onPress: widget.onDismiss,
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        semanticsLabel: 'Dismiss',
                        color: theme.colors.background,
                        prefix: const Icon(FLucideIcons.x),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (widget.toast.kind) {
      case ToastKind.success:
        return FLucideIcons.circleCheck;
      case ToastKind.error:
        return FLucideIcons.circleAlert;
      case ToastKind.info:
        return FLucideIcons.info;
    }
  }
}
