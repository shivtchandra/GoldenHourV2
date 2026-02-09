
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (auth.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Title
                FadeInDown(
                  child: Column(
                    children: [
                      Text(
                        'JOIN THE CLUB',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 28,
                          letterSpacing: 8,
                          color: tc.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CREATE YOUR PREMIUM ACCOUNT',
                        textAlign: TextAlign.center,
                        style: AppTypography.monoMedium.copyWith(
                          fontSize: 10,
                          letterSpacing: 3,
                          color: tc.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),

                // Name Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _nameController,
                    style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary),
                    decoration: _inputDecoration(context, 'FULL NAME', Icons.person_outline),
                    validator: (value) => 
                      value == null || value.isEmpty ? 'NAME IS REQUIRED' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Email Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: TextFormField(
                    controller: _emailController,
                    style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary),
                    decoration: _inputDecoration(context, 'EMAIL', Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => 
                      value == null || !value.contains('@') ? 'ENTER A VALID EMAIL' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Password Field
                FadeInLeft(
                  delay: const Duration(milliseconds: 600),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary),
                    decoration: _inputDecoration(context, 'PASSWORD', Icons.lock_outline),
                    validator: (value) => 
                      value == null || value.length < 6 ? 'MINIMUM 6 CHARACTERS' : null,
                  ),
                ),
                const SizedBox(height: 48),

                // Sign Up Button
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: auth.isLoading
                    ? Center(child: CircularProgressIndicator(color: tc.accent))
                    : ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tc.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: tc.accent.withOpacity(0.4),
                        ),
                        child: Text(
                          'START YOUR JOURNEY',
                          style: AppTypography.monoMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                ),
                
                const Spacer(),
                
                // Back to Login
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ALREADY HAVE AN ACCOUNT? SIGN IN',
                      style: AppTypography.monoMedium.copyWith(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: tc.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final tc = context.colors;
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.monoMedium.copyWith(
        color: tc.textSecondary,
        fontSize: 12,
        letterSpacing: 2,
      ),
      prefixIcon: Icon(icon, color: tc.accent, size: 20),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: tc.borderMuted),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: tc.accent),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: tc.error),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: tc.error),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
