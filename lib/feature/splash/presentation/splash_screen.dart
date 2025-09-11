import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../home/home_screen.dart';
import '../../profile/presentation/oboarding_modal.dart';
import 'mind_care_loader.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // check if onboarded
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("profiles")
                .doc(user.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: MindCareLoader());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const OnboardingModal();
              }

              final profile = snapshot.data!.data()!;
              final isOnboarded = profile["isOnboarded"] ?? false;

              return isOnboarded ? const HomeScreen() : const OnboardingModal();
            },
          );
        } else {
          // no user → start onboarding flow (this will login anonymously later)
          return const OnboardingModal();
        }
      },
      loading: () => const Scaffold(body: MindCareLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
