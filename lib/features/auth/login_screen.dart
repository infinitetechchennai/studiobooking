import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.grey1,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                hintText: 'abc@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    if (_emailCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter your email first')),
                      );
                      return;
                    }

                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailCtrl.text.trim(),
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Password reset link sent to your email'),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? 'Error occurred')),
                      );
                    }
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final email = _emailCtrl.text.trim();
                final password = _passwordCtrl.text.trim();

                // 🔹 Empty field validation
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter email and password')),
                  );
                  return;
                }

                // 🔹 Password length validation
                if (password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Password must be at least 6 characters')),
                  );
                  return;
                }

                try {
                  final notifier = ref.read(sessionProvider.notifier);

                  final user = await notifier.signIn(
                    email: _emailCtrl.text.trim(),
                    password: _passwordCtrl.text.trim(),
                  );

                  if (!context.mounted) return;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Account exists but profile not found. Contact support.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {'index': 0},
                  );
                } on FirebaseAuthException catch (e) {
                  String message = '';

                  switch (e.code) {
                    case 'user-not-found':
                      message = 'This email is not registered.';
                      break;
                    case 'wrong-password':
                      message = 'Incorrect password.';
                      break;
                    case 'invalid-email':
                      message = 'Invalid email format.';
                      break;
                    case 'invalid-credential':
                      message = 'Invalid email or password.';
                      break;
                    case 'too-many-requests':
                      message = 'Too many attempts. Try again later.';
                      break;
                    default:
                      message = 'Login failed. Please try again.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SIGN IN'),
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
                    color: AppColors.grey2, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildSocialButton('Login with Google',
                'assets/images/google_icon.png'), // Placeholder icon names
            const SizedBox(height: 16),
            _buildSocialButton(
                'Login with Facebook', 'assets/images/facebook_icon.png'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ",
                    style: TextStyle(color: AppColors.grey2)),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, String iconPath) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: AppColors.grey3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.g_mobiledata), // Should use actual icons
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.grey1)),
        ],
      ),
    );
  }
}
