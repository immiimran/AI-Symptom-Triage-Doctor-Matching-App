import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../providers/auth_provider.dart';

/// Temporary screen used until the real screen is built.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.showSignOut = false,
  });

  final String title;

  /// Temporary testing helper: shows a sign out button.
  final bool showSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (showSignOut) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final navigator = Navigator.of(context);
                  await auth.signOut();
                  navigator.pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                child: const Text('Sign out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
