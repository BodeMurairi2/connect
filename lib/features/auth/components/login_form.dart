import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connect/repositories/auth_repository.dart';
import 'package:connect/repositories/startup_repository.dart';

class LoginForm extends StatefulWidget {
  final Function(String destination) onSuccess;
  final String role;
  const LoginForm({super.key, required this.onSuccess, required this.role});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _authRepository = AuthService();

  static const _fieldFill = Color(0xFFF0F4FF);
  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Center(
              child: Image.asset(
                "assets/anzaconnect_brand_art.png",
                height: 64,
                width: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "AnzaConnect",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Connect with ALU startups.\nFind your next opportunity.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 36),

            const Text("Email", style: _labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "you@alustudent.com",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
              ),
              // validate only alustudent.com and alueducation.com
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                if (widget.role == 'student' &&
                    !value.trim().toLowerCase().endsWith('@alustudent.com')) {
                  return "Must be a valid ALU email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text("Password", style: _labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "Enter your password",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 4),

            // Add forgot password in case an user needs to change password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final emailController = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Password'),
                      content: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your ALU email',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await _authRepository.resetPassword(
                                emailController.text.trim(),
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset email sent!'),
                                ),
                              );
                            } on FirebaseAuthException catch (error) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.message ??
                                        'Failed to send reset email',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Send',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Forgot password?"),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final credential = await _authRepository.signInWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                      final uid = credential.user!.uid;
                      final adminCheck = await _authRepository.isAdmin(uid);

                      // get now role from firestore
                      final userDoc = await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(uid)
                          .get();
                      final role =
                          userDoc.data()?['role'] as String? ?? 'student';

                      if (adminCheck) {
                        widget.onSuccess('admin');
                      } else if (role == 'startup') {
                        final hasProfile = await StartupRepository().hasCompletedOnboarding(uid);
                        widget.onSuccess(hasProfile ? 'startup' : 'onboarding/startup');
                      } else {
                        widget.onSuccess(role);
                      }
                    } on FirebaseAuthException catch (error) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(error.message ?? 'Login Failed'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
