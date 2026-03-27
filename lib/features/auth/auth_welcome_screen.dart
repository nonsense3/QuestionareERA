import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import '../../shared/widgets/neo_loader.dart';
import 'auth_service.dart';

/// Sign in / Sign up **before** profile (name & username).
class AuthWelcomeScreen extends StatefulWidget {
  const AuthWelcomeScreen({
    super.key,
    required this.authService,
    this.onContinueAsGuestOffline,
  });

  final AuthService authService;

  /// No Supabase session — goes to local profile setup then home (no anonymous auth).
  final VoidCallback? onContinueAsGuestOffline;

  @override
  State<AuthWelcomeScreen> createState() => _AuthWelcomeScreenState();
}

class _AuthWelcomeScreenState extends State<AuthWelcomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  var _createAccount = false;
  var _needsOtp = false;
  var _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoCard(
                backgroundColor: colors.primary,
                child: const Text(
                  'QUESTIOARE ERA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Use email or continue with Google / GitHub. Guest skips email.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    if (_needsOtp) ...[
                      const Text(
                        'Check your email for the 6-digit verification code.',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '6-Digit OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      NeoButton(
                        label: _loading ? 'Verifying...' : 'Verify Email Code',
                        onPressed: _loading ? () {} : _verifyOtp,
                      ),
                      TextButton(
                        onPressed: _loading ? null : () => setState(() => _needsOtp = false),
                        child: const Text('Back to Login'),
                      ),
                    ] else ...[
                      TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    NeoButton(
                      label: _loading
                          ? 'Please wait...'
                          : (_createAccount ? 'Sign up' : 'Sign in'),
                      onPressed: _loading ? () {} : _submitEmailAuth,
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() => _createAccount = !_createAccount),
                      child: Text(
                        _createAccount
                            ? 'Already have an account? Sign in'
                            : 'Need an account? Create one',
                      ),
                    ),
                    ],
                    const Divider(height: 28),
                    NeoButton(
                      label: 'Continue with Google',
                      onPressed: _loading ? () {} : _signInWithGoogle,
                      color: Colors.white,
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: SvgPicture.asset(
                            'assets/icons/google_logo.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    NeoButton(
                      label: 'Continue with GitHub',
                      onPressed: _loading ? () {} : _signInWithGithub,
                      color: Colors.black,
                      foregroundColor: Colors.white,
                      icon: SvgPicture.asset(
                        'assets/icons/github_logo.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    NeoButton(
                      label: 'Continue as guest',
                      onPressed: _loading ? () {} : _guest,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: NeoLoader(label: 'Signing in', size: 34),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await widget.authService.signInWithGoogle();
    } on TimeoutException {
      if (!mounted) return;
      _snack('Session time out');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGithub() async {
    setState(() => _loading = true);
    try {
      await widget.authService.signInWithGithub();
    } on TimeoutException {
      if (!mounted) return;
      _snack('Session time out');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Enter email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_createAccount) {
        await widget.authService.signUpWithEmail(email: email, password: password).timeout(const Duration(seconds: 10));
        if (!mounted) return;
        _snack('Sign up successful! Please check your email for the OTP.');
        setState(() => _needsOtp = true);
      } else {
        await widget.authService.signInWithEmail(email: email, password: password).timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _snack('Please enter a valid 6-digit OTP.');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.authService.verifyEmailOtp(email: email, otp: otp).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guest() async {
    final offline = widget.onContinueAsGuestOffline;
    if (offline != null) {
      offline();
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.authService.signInAsGuest();
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
