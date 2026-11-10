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

/// Create-account screen with glassmorphism design.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text,
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AuthLayout(
      title: t('register_title'),
      subtitle: t('register_subtitle'),
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            GlassTextField(
              label: t('label_name'),
              controller: _nameController,
              icon: Icons.person_outline_rounded,
              validator: Validators.name,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 18),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 18),
            GlassTextField(
              label: t('label_confirm_password'),
              controller: _confirmController,
              icon: Icons.lock_reset_rounded,
              validator: Validators.confirmPassword(_passwordController),
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            GlassButton(
              label: t('btn_create_account'),
              onPressed: _submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
      footer: AuthSwitchRow(
        prompt: t('have_account'),
        actionLabel: t('sign_in_link'),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.login),
      ),
    );
  }
}
