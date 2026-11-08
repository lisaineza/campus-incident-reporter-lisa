import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _department = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _department.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final created = await context.read<AuthController>().register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          department: _department.text,
        );
    if (!mounted || !created) return;
    // The auth gate is already showing the home screen underneath.
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join your campus community and help keep it safe and working.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                const FieldLabel('Full name'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Amina Hassan',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: Validators.fullName,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Email'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'you@alustudent.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Department or programme'),
                TextFormField(
                  controller: _department,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Software Engineering',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: Validators.department,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Password', hint: 'at least 8 characters, letters and numbers'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Confirm password'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Repeat your password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: Validators.confirmPassword(() => _password.text),
                ),
                const SizedBox(height: 24),
                if (auth.error != null) ErrorBanner(message: auth.error!),
                PrimaryButton(
                  label: 'Create account',
                  loading: auth.isBusy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                const Text(
                  'New accounts are created as student accounts. Campus staff '
                  'access is granted by the administration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
