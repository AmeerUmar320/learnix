import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController             = TextEditingController();
  final _emailController            = TextEditingController();
  final _passwordController         = TextEditingController();
  final _confirmPasswordController  = TextEditingController();
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms           = false;

  late final AnimationController _animationController;
  late final Animation<double>   _fadeAnimation;
  late final Animation<Offset>   _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, .65, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .35), end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(.2, .7, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match');
      return;
    }
    if (!_agreeToTerms) {
      _showSnack('You must accept the Terms of Service');
      return;
    }
    try {
      // *** Pass name as 3rd argument ***
      await AuthService().signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, '/profile_picture', (_) => false);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Unexpected error: $e');
    }
  }

  void _showSnack(String? msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg ?? 'Error')));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor     = Color(0xFF0E1213);
    const accentColor = Color(0xFFB5FB67);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // … your blurred‐circle decorations here …

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // … your logo + title …

                            // Name
                            _buildField(_nameController, 'Full Name',
                                Icons.person_outline),
                            const SizedBox(height: 16),

                            // Email
                            _buildField(_emailController, 'Email',
                                Icons.email_outlined,
                                type: TextInputType.emailAddress),
                            const SizedBox(height: 16),

                            // Password
                            _buildField(
                              _passwordController,
                              'Password',
                              Icons.lock_outline,
                              obscure: _obscurePassword,
                              toggle: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildField(
                              _confirmPasswordController,
                              'Confirm Password',
                              Icons.lock_outline,
                              obscure: _obscureConfirmPassword,
                              toggle: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                            ),

                            // Terms checkbox
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (v) => setState(
                                        () => _agreeToTerms = v ?? false),
                                    fillColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) => states
                                              .contains(WidgetState.selected)
                                          ? accentColor
                                          : Colors.white24,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'I agree to the Terms of Service and Privacy Policy',
                                      style:
                                          TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sign up button (wired up)
                            _buildGlowingButton('SIGN UP', _handleSignup),

                            const SizedBox(height: 24),
                            // … social buttons, etc. …
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: TextField(
            controller: c,
            keyboardType: type,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: toggle == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: toggle,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingButton(String text, VoidCallback onPressed) {
    const accent = Color(0xFFB5FB67);
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: accent.withAlpha(76), blurRadius: 15)],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF0E1213),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
