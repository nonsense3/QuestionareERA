import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_notifier.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import '../auth/auth_service.dart';
import 'profile_avatar_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userType,
    required this.displayName,
    required this.username,
    this.authService,
  });

  final UserType userType;
  final String displayName;
  final String username;
  final AuthService? authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _memberNameController = TextEditingController();
  String _selectedRole = 'Moderator';
  final List<_TeamMember> _teamMembers = [
    const _TeamMember(name: 'Aarav Sharma', role: 'Admin'),
    const _TeamMember(name: 'Meera Singh', role: 'Moderator'),
    const _TeamMember(name: 'Rohan Patel', role: 'Manager'),
  ];
  bool _pushNotification = true;
  bool _weeklyDigest = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.displayName);
    // Sync themeNotifier with the platform brightness on first load.
    themeNotifier.syncWithPlatform(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmailAuth = widget.authService?.currentUser?.provider == 'email';

    return ListView(
      children: [
        ProfileAvatarHeader(
          authService: widget.authService,
          displayName: widget.displayName,
          username: widget.username,
          userType: widget.userType,
        ),
        NeoCard(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.userType == UserType.company
                      ? 'Company Name'
                      : 'Full Name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enabled: !isEmailAuth,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  filled: isEmailAuth,
                  fillColor: isEmailAuth ? Colors.grey.withOpacity(0.2) : null,
                  hintText: isEmailAuth ? 'Change password in Security below' : 'Enter a password to link email',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              NeoButton(
                label: 'Save Profile',
                onPressed: () => _saveProfile(isEmailAuth),
              ),
            ],
          ),
        ),
        if (widget.userType == UserType.company) _buildTeamManagementCard(),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Social Linking',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkedinController,
                decoration: const InputDecoration(
                  labelText: 'LinkedIn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.authService?.isGoogleLinked == true
                          ? 'Google: linked (avatar from Google)'
                          : 'Google: not linked',
                    ),
                  ),
                  Icon(
                    widget.authService?.isGoogleLinked == true
                        ? Icons.check_circle
                        : Icons.error_outline,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.authService?.isGithubLinked == true
                          ? 'GitHub: linked (avatar from GitHub)'
                          : 'GitHub: not linked',
                    ),
                  ),
                  Icon(
                    widget.authService?.isGithubLinked == true
                        ? Icons.check_circle
                        : Icons.error_outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        NeoCard(
          child: Column(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use Dark Theme'),
                    value: themeNotifier.isDark,
                    onChanged: (v) => themeNotifier.toggle(v),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push Notifications'),
                value: _pushNotification,
                onChanged: (v) => setState(() => _pushNotification = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Weekly Quiz Digest'),
                value: _weeklyDigest,
                onChanged: (v) => setState(() => _weeklyDigest = v),
              ),
            ],
          ),
        ),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 10),
              NeoButton(
                label: 'Change Password',
                onPressed: () {},
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 10),
              NeoButton(
                label: 'Delete Account',
                onPressed: () {},
                color: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamManagementCard() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Roles & Access',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 6),
          const Text(
            'Assign admins, moderators, managers, and custom roles for company control.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memberNameController,
            decoration: const InputDecoration(
              labelText: 'Member Name',
              hintText: 'Enter member name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Assign Role',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Moderator', child: Text('Moderator')),
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Quiz Host', child: Text('Quiz Host')),
              DropdownMenuItem(value: 'Support', child: Text('Support')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedRole = value);
            },
          ),
          const SizedBox(height: 10),
          NeoButton(
            label: 'Add Team Member',
            onPressed: () {
              final name = _memberNameController.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _teamMembers.add(_TeamMember(name: name, role: _selectedRole));
                _memberNameController.clear();
              });
            },
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _teamMembers.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_teamMembers[i].name} - ${_teamMembers[i].role}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _teamMembers.removeAt(i));
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _saveProfile(bool isEmailAuth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // In a real app, you would save name, phone, etc to the database here.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile details saved!')));

    // If they are an OAuth user trying to link an email/password
    if (!isEmailAuth && email.isNotEmpty && password.isNotEmpty) {
      _showOtpVerificationDialog(email, password);
    }
  }

  Future<void> _showOtpVerificationDialog(String email, String password) async {
    final otpCtrl = TextEditingController();
    var loading = false;

    // Send the OTP immediately
    try {
      await widget.authService?.linkEmailAndPassword(email: email, password: password);
    } catch (_) {
      try {
        await widget.authService?.signUpWithEmail(email: email, password: password);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to link: $e')));
        return;
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Verify OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Check your email for the 6-digit OTP code to complete linking.', style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 14),
                  TextField(controller: otpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '6-digit OTP', border: OutlineInputBorder())),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                NeoButton(
                  label: loading ? 'Verifying...' : 'Verify',
                  onPressed: loading ? () {} : () async {
                    setDialogState(() => loading = true);
                    try {
                      await widget.authService?.verifyEmailOtp(email: email, otp: otpCtrl.text);
                      if (context.mounted) Navigator.pop(ctx);
                      _passwordController.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email and Password successfully linked!')));
                      }
                    } catch (e) {
                      setDialogState(() => loading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}


class _TeamMember {
  const _TeamMember({required this.name, required this.role});

  final String name;
  final String role;
}
