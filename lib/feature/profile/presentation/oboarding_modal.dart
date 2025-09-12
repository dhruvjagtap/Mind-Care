// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/profile_service.dart';
// import '../../home/home_screen.dart';
// // import '../../auth/presentation/auth_provider.dart';

// final onboardingProvider =
//     StateNotifierProvider<OnboardingNotifier, Map<String, dynamic>>((ref) {
//       return OnboardingNotifier(ProfileService());
//     });

// class OnboardingNotifier extends StateNotifier<Map<String, dynamic>> {
//   final ProfileService _service;
//   OnboardingNotifier(this._service) : super({});

//   void updateData(String key, dynamic value) {
//     state = {...state, key: value};
//   }

//   Future<void> saveProfile() async {
//     final updatedState = {...state, "isOnboarded": true};
//     state = updatedState;
//     await _service.updateProfile(updatedState);
//   }
// }

// class OnboardingModal extends ConsumerStatefulWidget {
//   const OnboardingModal({super.key});

//   @override
//   ConsumerState<OnboardingModal> createState() => _OnboardingModalState();
// }

// class _OnboardingModalState extends ConsumerState<OnboardingModal> {
//   int _step = 0;
//   late TextEditingController nameController;
//   late TextEditingController prnController;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController();
//     prnController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     prnController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final onboardingNotifier = ref.read(onboardingProvider.notifier);

//     List<Widget> steps = [
//       _welcomeStep(onboardingNotifier),
//       _nameStep(onboardingNotifier),
//       _prnStep(onboardingNotifier),
//       _hobbiesStep(onboardingNotifier),
//     ];

//     return Scaffold(
//       body: Center(
//         child: Card(
//           elevation: 4,
//           color: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 steps[_step],
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_step < steps.length - 1) {
//                       setState(() => _step++);
//                     } else {
//                       await onboardingNotifier.saveProfile();
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const HomeScreen()),
//                       );
//                     }
//                   },
//                   child: Text(_step < steps.length - 1 ? "Next" : "Finish"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _hobbiesStep(OnboardingNotifier notifier) {
//     final profileState = ref.watch(onboardingProvider);
//     final selectedHobbies = List<String>.from(profileState["hobbies"] ?? []);
//     final hobbies = [
//       "Music",
//       "Gaming",
//       "Reading",
//       "Sports",
//       "Traveling",
//       "Cooking",
//       "Others",
//     ];

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "What do you enjoy doing in your free time?",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: hobbies.map((hobby) {
//             final isSelected = selectedHobbies.contains(hobby);
//             return FilterChip(
//               label: Text(hobby),
//               selected: isSelected,
//               onSelected: (selected) {
//                 if (hobby == "Others") {
//                   if (selected) {
//                     selectedHobbies.add(hobby);
//                   } else {
//                     selectedHobbies.remove(hobby);
//                     notifier.updateData(
//                       "otherHobby",
//                       "",
//                     ); // clear text if deselected
//                   }
//                 } else {
//                   if (selected) {
//                     selectedHobbies.add(hobby);
//                   } else {
//                     selectedHobbies.remove(hobby);
//                   }
//                 }
//                 notifier.updateData("hobbies", selectedHobbies);
//               },
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 12),
//         if (selectedHobbies.contains("Others")) ...[
//           TextField(
//             decoration: const InputDecoration(
//               hintText: "Please specify your hobby",
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) {
//               notifier.updateData("otherHobby", value);
//             },
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _welcomeStep(OnboardingNotifier notifier) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Text(
//           "Welcome to Mind Care",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _nameStep(OnboardingNotifier notifier) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "What should I call you?",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: nameController,
//           decoration: const InputDecoration(
//             hintText: "Enter your name",
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (value) {
//             notifier.updateData("name", value);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _prnStep(OnboardingNotifier notifier) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Can I know your PRN / Enrollment number to personalize your experience?",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: prnController,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(
//             hintText: "Enter your PRN / Enrollment No.",
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (value) {
//             notifier.updateData("prn", value);
//           },
//         ),
//       ],
//     );
//   }
// }
