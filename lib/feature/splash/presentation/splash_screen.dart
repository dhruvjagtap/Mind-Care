import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../home/home_screen.dart';
import '../../profile/presentation/onboarding_modal1.dart';
import 'mind_care_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkAuth(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: MindCareLoader());
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          return const OnboardingModal();
        }
      },
    );
  }

  Future<bool> _checkAuth(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final college = prefs.getString("college");
    final prn = prefs.getString("prn");

    if (college != null && prn != null) {
      // ✅ Update auth state
      ref.read(authStateProvider.notifier).state = StudentAuth(
        college: college,
        prn: prn,
      );

      // ✅ Check Firestore if you want extra safety
      final doc = await FirebaseFirestore.instance
          .collection("colleges")
          .doc(college)
          .collection("students")
          .doc(prn)
          .get();

      return doc.exists && (doc.data()?["isOnboarded"] ?? false);
    }

    return false;
  }
}
