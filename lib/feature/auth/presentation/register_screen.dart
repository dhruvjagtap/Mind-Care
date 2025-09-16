// register_screen.dart
import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _prn = TextEditingController();
  final _name = TextEditingController();
  final _pin = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String? _college;
  List<String> _hobbies = [];

  final AuthService _auth = AuthService();
  final List<String> hobbiesOptions = [
    "Music",
    "Gaming",
    "Reading",
    "Sports",
    "Traveling",
    "Others",
  ];

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _college != null) {
      await _auth.registerPRN(
        college: _college!,
        prn: _prn.text.trim(),
        pin: _pin.text.trim(),
        name: _name.text.trim(),
        hobbies: _hobbies,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showError("Fill all fields & select college");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _prn.dispose();
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _toLogin() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Register - MindCare',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // College
                        DropdownButtonFormField<String>(
                          value: _college,
                          items: ["I²IT", "College B", "College C"]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _college = val),
                          decoration: const InputDecoration(
                            labelText: "College",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null ? "Select college" : null,
                        ),
                        const SizedBox(height: 12),

                        // PRN
                        TextFormField(
                          controller: _prn,
                          decoration: const InputDecoration(
                            labelText: 'PRN',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter PRN' : null,
                        ),
                        const SizedBox(height: 12),

                        // Name
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter name' : null,
                        ),
                        const SizedBox(height: 12),

                        // PIN
                        TextFormField(
                          controller: _pin,
                          obscureText: _obscure,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: 'Set PIN',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _obscure = !_obscure);
                              },
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (v) => (v == null || v.length != 4)
                              ? 'Enter 4-digit PIN'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Hobbies
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            children: hobbiesOptions.map((hobby) {
                              final selected = _hobbies.contains(hobby);
                              return FilterChip(
                                label: Text(hobby),
                                selected: selected,
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _hobbies.add(hobby);
                                    } else {
                                      _hobbies.remove(hobby);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Register Button
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _register,
                                child: const Text("Register"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: _toLogin,
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
