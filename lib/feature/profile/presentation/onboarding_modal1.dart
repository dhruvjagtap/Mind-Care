import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_service.dart';
import '../../home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, Map<String, dynamic>>((ref) {
      return OnboardingNotifier(ProfileService());
    });

class OnboardingNotifier extends StateNotifier<Map<String, dynamic>> {
  final ProfileService _service;
  OnboardingNotifier(this._service) : super({});

  void updateData(String key, dynamic value) {
    state = {...state, key: value};
  }

  // Future<void> saveProfile() async {
  //   final updatedState = {...state, "isOnboarded": true};
  //   state = updatedState;
  //   await _service.updateProfile(updatedState);
  // }

  Future<void> saveProfile() async {
    if (state["college"] == null || state["prn"] == null) return;

    final updatedState = {...state, "isOnboarded": true};
    state = updatedState;

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection("colleges")
        .doc(state["college"])
        .collection("students")
        .doc(state["prn"])
        .set({...updatedState, "createdAt": FieldValue.serverTimestamp()});

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("college", state["college"]);
    await prefs.setString("prn", state["prn"]);
  }

  void reset() {
    state = {};
  }
}

class OnboardingModal extends ConsumerStatefulWidget {
  const OnboardingModal({super.key});

  @override
  ConsumerState<OnboardingModal> createState() => _OnboardingModalState();
}

class _OnboardingModalState extends ConsumerState<OnboardingModal> {
  int _step = 0;
  String? _collegeId;
  late TextEditingController prnController;
  late TextEditingController nameController;
  late TextEditingController pinController;

  bool _isNewStudent = false;

  @override
  void initState() {
    super.initState();
    prnController = TextEditingController();
    nameController = TextEditingController();
    pinController = TextEditingController();
  }

  @override
  void dispose() {
    prnController.dispose();
    nameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);

    final steps = [
      _welcomeStep(notifier), // NEW FIRST STEP
      _collegeStep(),
      _prnStep(notifier),
      if (_isNewStudent) _nameStep(notifier),
      _pinStep(notifier),
      _hobbiesStep(notifier),
    ];

    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                steps[_step],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final notifier = ref.read(onboardingProvider.notifier);

                    if (_step < steps.length - 1) {
                      // Step-specific logic
                      if (_step == 1) {
                        notifier.updateData("college", _collegeId);
                      } else if (_step == 2) {
                        notifier.updateData("prn", prnController.text);
                        final exists = await _checkStudentExists();
                        setState(() => _isNewStudent = !exists);
                      } else if (_step == 3 && _isNewStudent) {
                        notifier.updateData("name", nameController.text);
                      } else if (_step == (_isNewStudent ? 4 : 3)) {
                        notifier.updateData("pinHash", pinController.text);
                      }

                      setState(() => _step++);
                    } else {
                      await notifier.saveProfile();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  },
                  child: Text(
                    _step == 0
                        ? "Let's Start"
                        : (_step < steps.length - 1 ? "Next" : "Finish"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Welcome Step
  Widget _welcomeStep(OnboardingNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          "Welcome to Mind Care",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text("Let's get you set up quickly!", textAlign: TextAlign.center),
      ],
    );
  }

  /// Step 1: Select College
  Widget _collegeStep() {
    final colleges = ["I²IT", "College B", "College C"];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Select your College",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: _collegeId,
          hint: const Text("Choose College"),
          items: colleges.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          onChanged: (val) {
            setState(() => _collegeId = val);
          },
        ),
      ],
    );
  }

  /// Step 2: Enter PRN
  Widget _prnStep(OnboardingNotifier notifier) {
    return Column(
      children: [
        const Text("Enter your PRN/Enrollment Number"),
        TextField(
          controller: prnController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "PRN Number",
          ),
          onChanged: (val) {
            notifier.updateData("prn", val);
          },
        ),
      ],
    );
  }

  /// Step 3 (if new student): Enter Name
  Widget _nameStep(OnboardingNotifier notifier) {
    return Column(
      children: [
        const Text("What should I call you?"),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Your name",
          ),
          onChanged: (val) {
            notifier.updateData("name", val);
          },
        ),
      ],
    );
  }

  /// Step 4: PIN setup / validation
  Widget _pinStep(OnboardingNotifier notifier) {
    return Column(
      children: [
        Text(
          _isNewStudent
              ? "Set a 4-digit PIN for login"
              : "Enter your PIN to continue",
        ),
        TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "PIN",
          ),
          onChanged: (val) {
            // hash before saving ideally
            notifier.updateData("pinHash", val);
          },
        ),
      ],
    );
  }

  /// Step 5: Hobbies
  Widget _hobbiesStep(OnboardingNotifier notifier) {
    final profileState = ref.watch(onboardingProvider);
    final selectedHobbies = List<String>.from(profileState["hobbies"] ?? []);
    final hobbies = [
      "Music",
      "Gaming",
      "Reading",
      "Sports",
      "Traveling",
      "Others",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("What do you enjoy doing in your free time?"),
        Wrap(
          spacing: 8,
          children: hobbies.map((hobby) {
            final isSelected = selectedHobbies.contains(hobby);
            return FilterChip(
              label: Text(hobby),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  selectedHobbies.add(hobby);
                } else {
                  selectedHobbies.remove(hobby);
                }
                notifier.updateData("hobbies", selectedHobbies);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Firestore check for student
  Future<bool> _checkStudentExists() async {
    if (_collegeId == null || prnController.text.isEmpty) return false;
    final doc = await FirebaseFirestore.instance
        .collection("colleges")
        .doc(_collegeId)
        .collection("students")
        .doc(prnController.text)
        .get();
    return doc.exists;
  }
}
