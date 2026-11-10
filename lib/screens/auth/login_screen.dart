import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../texts/app_texts.dart';
import '../../utils/validators.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_text_field.dart';
import 'auth_layout.dart';

/// Email/password sign in screen with glassmorphism design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(auth.errorKey ?? 'err_auth_unknown'))),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AuthLayout(
      title: t('login_title'),
      subtitle: t('login_subtitle'),
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            GlassTextField(
              label: t('label_email'),
              controller: _emailController,
              icon: Icons.mail_outline_rounded,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 18),
            GlassTextField(
              label: t('label_password'),
              controller: _passwordController,
              icon: Icons.lock_outline_rounded,
              validator: Validators.password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 24),
            GlassButton(
              label: t('btn_sign_in'),
              onPressed: _submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
      footer: AuthSwitchRow(
        prompt: t('no_account'),
        actionLabel: t('create_account_link'),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.register),
      ),
    );
  }
}
