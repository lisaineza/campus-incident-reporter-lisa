import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../routes.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().signIn(_email.text, _password.text);
  }

  Future<void> _forgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    if (Validators.email(_email.text) != null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Enter your email above, then tap "Forgot password?" again.'),
      ));
      return;
    }
    final sent =
        await context.read<AuthController>().sendPasswordReset(_email.text);
    if (!mounted || !sent) return;
    messenger.showSnackBar(SnackBar(
      content: Text('A reset link has been sent to ${_email.text.trim()}.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppLogo(),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to report campus issues and follow their progress.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    const FieldLabel('Email'),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'you@alustudent.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Password'),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.loginPassword,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: auth.isBusy ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (auth.error != null) ErrorBanner(message: auth.error!),
                    PrimaryButton(
                      label: 'Sign in',
                      loading: auth.isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('New here?',
                            style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: auth.isBusy
                              ? null
                              : () {
                                  auth.clearError();
                                  Navigator.of(context).pushNamed(AppRoutes.register);
                                },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
