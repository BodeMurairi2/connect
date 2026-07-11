import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connect/repositories/auth_repository.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final String role;

  const RegisterForm({super.key, required this.onSuccess, required this.role});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 4),
            const Center(
              child: Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "Join the ALU startup ecosystem",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 28),

            const Text("First Name", style: _labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: "Enter your first name",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "First name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text("Last Name", style: _labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: "Enter your last name",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Last name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Text(
              widget.role == 'student' ? "ALU Email" : "Email",
              style: _labelStyle,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: widget.role == 'student'
                    ? "you@alustudent.com"
                    : "you@example.com",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
              ),
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
                hintText: "Create a strong password",
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
              // for user safety, only password with at least 8 chars will be accepted
              validator: (value) {
                if (value == null || value.length < 8 || value.length > 16) {
                  return "Password must be between 8 and 16 characters";
                } // additional validation rules will be implemented later
                return null;
              },
            ),
            const SizedBox(height: 16),

            const Text("Confirm Password", style: _labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: "Confirm your password",
                filled: true,
                fillColor: _fieldFill,
                border: _fieldBorder,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please confirm your password";
                }
                if (value != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final credential = await _authRepository
                          .registerWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                      await _authRepository.saveUserToFirestore(
                        uid: credential.user!.uid,
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        email: _emailController.text.trim(),
                        role: widget.role,
                      );
                      await _authRepository.sendEmailVerification();
                      widget.onSuccess();
                    } on FirebaseAuthException catch (error) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(error.message ?? 'Registration failed'),
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
                  "Create Account",
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
