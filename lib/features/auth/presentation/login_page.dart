import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_toast.dart';
import 'auth_controller.dart';

/// Sign-in screen using Forui form controls.
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
    final theme = context.theme;
    return FScaffold(
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
                    children: [
                      Text(
                        'Stark VMS',
                        style: theme.typography.display.xl2.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage the vehicle registry.',
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FTextFormField.email(
                        control: FTextFieldControl.managed(
                          controller: _userEmail,
                        ),
                        autofocus: true,
                        enabled: !_submitting,
                        textInputAction: TextInputAction.next,
                        label: const Text('User email'),
                        hint: 'you@company.com',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your user email'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      FTextFormField.password(
                        control: FTextFieldControl.managed(
                          controller: _password,
                        ),
                        enabled: !_submitting,
                        label: const Text('Password'),
                        textInputAction: TextInputAction.done,
                        onSubmit: (_) => _submit(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter your password'
                            : null,
                      ),
                      if (_failure != null) ...[
                        const SizedBox(height: 18),
                        FAlert(
                          variant: FAlertVariant.destructive,
                          icon: const Icon(FLucideIcons.circleAlert),
                          title: Text(_failure!),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FButton(
                        onPress: _submitting ? null : _submit,
                        child: _submitting
                            ? FCircularProgress(
                                style: .delta(
                                  iconStyle: .delta(
                                    color:
                                        context.theme.colors.primaryForeground,
                                  ),
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
    );
  }
}
