// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../home/home_screen.dart';
// import '../../auth/data/auth_service.dart';
// import '../data/profile_service.dart';

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

//   void reset() {
//     state = {};
//   }
// }

// /// Helper to hash PIN
// String hashPin(String pin) {
//   final bytes = utf8.encode(pin);
//   final digest = sha256.convert(bytes);
//   return digest.toString();
// }

// class OnboardingModal extends ConsumerStatefulWidget {
//   const OnboardingModal({super.key});

//   @override
//   ConsumerState<OnboardingModal> createState() => _OnboardingModalState();
// }

// class _OnboardingModalState extends ConsumerState<OnboardingModal> {
//   int _step = 0;
//   String? _collegeId;
//   late TextEditingController prnController;
//   late TextEditingController nameController;
//   late TextEditingController pinController;
//   bool _isNewStudent = false;
//   bool _isPinVisible = false;

//   final List<String> colleges = ["I²IT", "College B", "College C"];

//   @override
//   void initState() {
//     super.initState();
//     prnController = TextEditingController();
//     nameController = TextEditingController();
//     pinController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     prnController.dispose();
//     nameController.dispose();
//     pinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifier = ref.read(onboardingProvider.notifier);
//     final authService = AuthService();

//     // Registration steps
//     final registrationSteps = [
//       _collegeStep(),
//       _prnStep(),
//       _nameStep(),
//       _pinStep(),
//       _hobbiesStep(),
//     ];

//     // Login steps
//     final loginSteps = [_collegeStep(), _prnStep(), _pinStep()];

//     final steps = _isNewStudent ? registrationSteps : loginSteps;

//     return Scaffold(
//       body: Center(
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: SizedBox(
//             width: 350,
//             height: 450,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: (_step == 0)
//                         ? _welcomeStep()
//                         : steps[_step - 1], // step 0 = welcome
//                   ),
//                   const SizedBox(height: 20),
//                   _buildButtons(steps, notifier, authService),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Buttons
//   Widget _buildButtons(
//     List<Widget> steps,
//     OnboardingNotifier notifier,
//     AuthService authService,
//   ) {
//     if (_step == 0) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _isNewStudent = false;
//                 _step = 1;
//               });
//             },
//             child: const Text("Login"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _isNewStudent = true;
//                 _step = 1;
//               });
//             },
//             child: const Text("Register"),
//           ),
//         ],
//       );
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             if (_step > 0) setState(() => _step--);
//           },
//           child: const Text("Previous"),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final isLast = _step == steps.length;

//             if (isLast) {
//               if (_isNewStudent) {
//                 // Register
//                 final exists = await authService.checkStudentExists(
//                   _collegeId!,
//                   prnController.text,
//                 );
//                 if (exists) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("PRN already registered. Please login."),
//                     ),
//                   );
//                   return;
//                 }

//                 await authService.registerPRN(
//                   college: _collegeId!,
//                   prn: prnController.text,
//                   pin: hashPin(pinController.text),
//                   name: nameController.text,
//                   hobbies: List<String>.from(
//                     ref.read(onboardingProvider)["hobbies"] ?? [],
//                   ),
//                 );
//               } else {
//                 // Login
//                 final data = await authService.loginWithPRN(
//                   _collegeId!,
//                   prnController.text,
//                   hashPin(pinController.text),
//                 );
//                 if (data == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Invalid PRN or PIN. Try again."),
//                     ),
//                   );
//                   return;
//                 }
//               }

//               // Update provider & save session
//               notifier.updateData("college", _collegeId);
//               notifier.updateData("prn", prnController.text);
//               notifier.updateData("isOnboarded", true);

//               final prefs = await SharedPreferences.getInstance();
//               await prefs.setString("college", _collegeId!);
//               await prefs.setString("prn", prnController.text);
//               await prefs.setBool("isOnboarded", true);

//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => const HomeScreen()),
//               );
//               return;
//             }

//             setState(() => _step++);
//           },
//           child: Text(_step == steps.length ? "Finish" : "Next"),
//         ),
//       ],
//     );
//   }

//   /// Welcome Step
//   Widget _welcomeStep() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: const [
//         Text(
//           "Welcome to Mind Care",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 10),
//         Text("Login or Register to continue", textAlign: TextAlign.center),
//       ],
//     );
//   }

//   /// College Step
//   Widget _collegeStep() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "Select your College",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         DropdownButton<String>(
//           value: _collegeId,
//           hint: const Text("Choose College"),
//           items: colleges
//               .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//               .toList(),
//           onChanged: (val) {
//             setState(() => _collegeId = val);
//           },
//         ),
//       ],
//     );
//   }

//   /// PRN Step
//   Widget _prnStep() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("Enter your PRN/Enrollment Number"),
//         TextField(
//           controller: prnController,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: "PRN Number",
//           ),
//         ),
//       ],
//     );
//   }

//   /// Name Step (registration only)
//   Widget _nameStep() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("What should I call you?"),
//         TextField(
//           controller: nameController,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: "Your name",
//           ),
//         ),
//       ],
//     );
//   }

//   /// PIN Step
//   Widget _pinStep() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           _isNewStudent
//               ? "Set a 4-digit PIN for login"
//               : "Enter your PIN to continue",
//         ),
//         TextField(
//           controller: pinController,
//           obscureText: !_isPinVisible,
//           keyboardType: TextInputType.number,
//           maxLength: 4,
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             hintText: "PIN",
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _isPinVisible ? Icons.visibility : Icons.visibility_off,
//               ),
//               onPressed: () {
//                 setState(() => _isPinVisible = !_isPinVisible);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Hobbies Step (registration only)
//   Widget _hobbiesStep() {
//     final notifier = ref.read(onboardingProvider.notifier);
//     final profileState = ref.watch(onboardingProvider);
//     final selectedHobbies = List<String>.from(profileState["hobbies"] ?? []);
//     final hobbies = [
//       "Music",
//       "Gaming",
//       "Reading",
//       "Sports",
//       "Traveling",
//       "Others",
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("What do you enjoy doing in your free time?"),
//         Wrap(
//           spacing: 8,
//           children: hobbies.map((hobby) {
//             final isSelected = selectedHobbies.contains(hobby);
//             return FilterChip(
//               label: Text(hobby),
//               selected: isSelected,
//               onSelected: (selected) {
//                 final newList = [...selectedHobbies];
//                 if (selected) {
//                   newList.add(hobby);
//                 } else {
//                   newList.remove(hobby);
//                 }
//                 notifier.updateData("hobbies", newList);
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }
