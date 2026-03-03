import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(); // ✅ Added
  final _passwordCtrl = TextEditingController();

  String _role = 'client';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose(); // ✅ dispose
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 24),

              /// NAME
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// EMAIL
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'abc@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PHONE NUMBER ✅ NEW FIELD
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length != 10) {
                    return 'Enter valid 10-digit phone number';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Phone number must contain only digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PASSWORD (Show / Hide)
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Create password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// ROLE DROPDOWN
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey3.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey3),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _role,
                    style: const TextStyle(
                      color: AppColors.grey1,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.black,
                    iconEnabledColor: AppColors.grey2,
                    items: const [
                      DropdownMenuItem(
                        value: 'client',
                        child: Text('Client (Book services)'),
                      ),
                      DropdownMenuItem(
                        value: 'Creator',
                        child: Text('Creator (List my services)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'client'),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// SIGN UP BUTTON
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
                    await ref.read(sessionProvider.notifier).signUp(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(), // ✅ pass phone
                          role: _role,
                          password: _passwordCtrl.text,
                        );

                    if (!context.mounted) return;

                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: {'index': 0},
                    );
                  } on FirebaseAuthException catch (e) {
                    String message = 'Signup failed';

                    switch (e.code) {
                      case 'email-already-in-use':
                        message = 'Email already in use';
                        break;
                      case 'weak-password':
                        message = 'Password too weak (min 6 characters)';
                        break;
                      case 'invalid-email':
                        message = 'Invalid email address';
                        break;
                      default:
                        message = e.message ?? message;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SIGN UP'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: AppColors.grey2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSocialButton(
                'Login with Google',
                'assets/images/google_icon.png',
              ),

              const SizedBox(height: 16),

              _buildSocialButton(
                'Login with Facebook',
                'assets/images/facebook_icon.png',
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: AppColors.grey2),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, String iconPath) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 58),
        backgroundColor: AppColors.grey3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.grey1),
          ),
        ],
      ),
    );
  }
}
