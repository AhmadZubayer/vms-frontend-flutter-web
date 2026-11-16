import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_toast.dart';
import 'auth_controller.dart';

/// Sign-in screen, built from stock Material 3 components.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _submitting = false;
  bool _showPassword = false;
  String? _failure;

  @override
  void dispose() {
    _userEmail.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_form.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _submitting = true;
      _failure = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(userEmail: _userEmail.text.trim(), password: _password.text);
      if (mounted) {
        AppToast.success(context, 'Signed in.');
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _failure = error.message);
      }
    } on Object {
      if (mounted) {
        setState(() => _failure = 'Sign-in failed. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Stark VMS', style: theme.typography.display.xl2),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to manage the vehicle registry.',
                          style: theme.typography.body.base.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _userEmail,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'User email',
                            prefixIcon: Icon(FLucideIcons.mail),
                          ),
                          validator: (String? value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter your user email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const <String>[AutofillHints.password],
                          onFieldSubmitted: (String _) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(FLucideIcons.lockKeyhole),
                            suffixIcon: FButton.icon(variant: FButtonVariant.ghost,
                              semanticsLabel: _showPassword
                                  ? 'Hide password'
                                  : 'Show password',
                              onPress: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? FLucideIcons.eyeOff
                                    : FLucideIcons.eye,
                              ),
                            ),
                          ),
                          validator: (String? value) =>
                              (value == null || value.isEmpty)
                              ? 'Enter your password'
                              : null,
                        ),
                        if (_failure != null) ...<Widget>[
                          const SizedBox(height: 16),
                          _FailureNotice(message: _failure!),
                        ],
                        const SizedBox(height: 24),
                        FButton(mainAxisSize: MainAxisSize.min,
                          onPress: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: _submitting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colors.primaryForeground,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            FLucideIcons.circleAlert,
            size: 18,
            color: theme.colors.errorForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.errorForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
