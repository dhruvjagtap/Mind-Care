// login_screen.dart
import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import './register_screen.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _prn = TextEditingController();
  final _pin = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String? _college;
  final AuthService _auth = AuthService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate() && _college != null) {
      final user = await _auth.loginWithPRN(
        _college!,
        _prn.text.trim(),
        _pin.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showError("Invalid PRN or PIN");
      }
    } else {
      _showError("Please select a college");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _prn.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _toRegister() {
    Navigator.pushReplacementNamed(context, RegisterScreen.routeName);
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
                  child: Column(
                    children: [
                      const Text(
                        'MindCare',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // College Dropdown
                      DropdownButtonFormField<String>(
                        value: _college,
                        items: ["I²IT", "College B", "College C"]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
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

                            // PIN
                            TextFormField(
                              controller: _pin,
                              obscureText: _obscure,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: 'PIN',
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _login,
                              child: const Text("Login"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _toRegister,
                        child: const Text(
                          "New user? Register here",
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
    );
  }
}
