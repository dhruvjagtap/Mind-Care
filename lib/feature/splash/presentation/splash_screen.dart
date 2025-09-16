import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../home/home_screen.dart';
import '../../auth/presentation/welcome_screen.dart'; // <-- new import
import 'mind_care_loader.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkAuth(ref),
      builder: (context, snapshot) {
        // Show MindCare loader while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: MindCareLoader());
        }

        // If user is logged in
        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          // If no user logged in, go to Welcome
          return const WelcomeScreen();
        }
      },
    );
  }

  Future<bool> _checkAuth(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final college = prefs.getString("college");
    final prn = prefs.getString("prn");

    if (college != null && prn != null) {
      // Update Riverpod auth state
      ref.read(authStateProvider.notifier).state = StudentAuth(
        college: college,
        prn: prn,
      );

      // Optional: check Firestore to confirm onboarding
      final doc = await FirebaseFirestore.instance
          .collection("colleges")
          .doc(college)
          .collection("students")
          .doc(prn)
          .get();

      // Return true if student exists and is onboarded
      return doc.exists && (doc.data()?["isOnboarded"] ?? true);
    }

    return false; // No user found
  }
}
