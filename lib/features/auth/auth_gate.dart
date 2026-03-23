import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import '../home/home_screen.dart';
import 'auth_service.dart';
import 'auth_welcome_screen.dart';
import 'profile_onboarding_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.supabaseReady});
  final bool supabaseReady;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthService? _authService;
  UserType _demoUserType = UserType.individual;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  /// Guest without Supabase session (anonymous sign-in disabled / not wanted).
  bool _guestOfflineMode = false;
  bool _guestHomeActive = false;
  UserType _guestUserType = UserType.individual;
  String _guestDisplayName = '';
  String _guestUsername = '';
  @override
  void initState() {
    super.initState();
    if (widget.supabaseReady) {
      _authService = AuthService();
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.supabaseReady) {
      return _buildDemoSignIn(context);
    }
    return AnimatedBuilder(
      animation: _authService!,
      builder: (context, _) {
        if (_authService!.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (_guestHomeActive) {
          return HomeScreen(
            authService: null,
            userType: _guestUserType,
            displayName: _guestDisplayName,
            username: _guestUsername,
            onGuestExit: () => setState(() {
              _guestHomeActive = false;
            }),
          );
        }

        if (_guestOfflineMode) {
          return ProfileOnboardingScreen(
            onGuestComplete: (userType, displayName, username) {
              setState(() {
                _guestOfflineMode = false;
                _guestHomeActive = true;
                _guestUserType = userType;
                _guestDisplayName = displayName;
                _guestUsername = username;
              });
            },
            onGuestCancel: () => setState(() => _guestOfflineMode = false),
          );
        }

        if (!_authService!.isSignedIn) {
          return AuthWelcomeScreen(
            authService: _authService!,
            onContinueAsGuestOffline: () => setState(() => _guestOfflineMode = true),
          );
        }

        if (!_authService!.isProfileComplete) {
          return ProfileOnboardingScreen(authService: _authService!);
        }

        return HomeScreen(
          authService: _authService,
          userType: _authService!.profileUserType,
          displayName: _authService!.profileDisplayName,
          username: _authService!.profileUsername,
        );
      },
    );
  }

  String get _resolvedDisplayName {
    final fallback = _demoUserType == UserType.company
        ? 'Company Admin'
        : 'Individual User';
    final typed = _displayNameController.text.trim();
    return typed.isEmpty ? fallback : typed;
  }

  String get _resolvedUsername {
    final cleaned = _usernameController.text.trim().toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9_.]'),
          '',
        );
    return cleaned;
  }

  /// Offline demo — no Supabase; single screen with name + username.
  Widget _buildDemoSignIn(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NeoCard(
                backgroundColor: colors.secondary,
                child: const Text(
                  'QUESTIOARE ERA',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demo mode (no Supabase)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: UserType.values
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type.name.toUpperCase()),
                              selected: _demoUserType == type,
                              onSelected: (_) => setState(() {
                                _demoUserType = type;
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: _demoUserType == UserType.company
                            ? 'Company Name'
                            : 'Display Name',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_demoUserType == UserType.individual) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Unique Username',
                          prefixText: '@',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    NeoButton(
                      label: 'Continue in demo',
                      onPressed: () {
                              if (_demoUserType == UserType.individual &&
                                  _resolvedUsername.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please add a unique username.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => HomeScreen(
                                    authService: null,
                                    userType: _demoUserType,
                                    displayName: _resolvedDisplayName,
                                    username: _resolvedUsername,
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Add SUPABASE_URL + SUPABASE_ANON_KEY for real sign-in.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
