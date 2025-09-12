// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import '../../home/home_screen.dart';
// import 'login_screen.dart';
// import '../../profile/presentation/oboarding_modal.dart';
// import 'auth_provider.dart';

// class AuthChecker extends ConsumerWidget {
//   const AuthChecker({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     return authState.when(
//       data: (user) {
//         if (user != null) {
//           // check Firestore profile
//           return FutureBuilder(
//             future: FirebaseFirestore.instance
//                 .collection("profiles")
//                 .doc(user.uid)
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }

//               // if profile does not exist → show onboarding modal
//               if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return const OnboardingModal();
//               }

//               final profile = snapshot.data!.data()!;
//               final isOnboarded = profile["isOnboarded"] ?? false;

//               // if profile exists but onboarding not done → show modal
//               if (!isOnboarded) {
//                 return const OnboardingModal();
//               }

//               // otherwise go to Home
//               return const HomeScreen();
//             },
//           );
//         } else {
//           return const LoginScreen();
//         }
//       },
//       loading: () =>
//           const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
//     );
//   }
// }
