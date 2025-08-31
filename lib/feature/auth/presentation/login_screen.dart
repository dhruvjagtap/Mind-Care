import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authService.signInAnonymously();
          },
          child: const Text('Continue Anonymously'),
        ),
      ),
    );
  }
}
