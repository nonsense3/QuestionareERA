import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import '../../shared/widgets/neo_loader.dart';
import 'auth_service.dart';

/// Shown **after** sign-in when profile is not complete yet (name, username, type).
/// Or for **offline guest** with no [authService] — [onGuestComplete] is required then.
class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({
    super.key,
    this.authService,
    this.onGuestComplete,
    this.onGuestCancel,
  }) : assert(
          (authService != null && onGuestComplete == null) ||
              (authService == null && onGuestComplete != null),
        );

  final AuthService? authService;
  final void Function(UserType userType, String displayName, String username)?
      onGuestComplete;
  final VoidCallback? onGuestCancel;

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  UserType _selectedType = UserType.individual;
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String get _resolvedUsername {
    final cleaned = _usernameController.text.trim().toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9_.]'),
          '',
        );
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        actions: [
          if (widget.authService != null)
            _NeoAppBarAction(
              label: 'Sign out',
              onTap: _loading ? null : () => widget.authService!.signOut(),
            )
          else
            _NeoAppBarAction(
              label: 'Back',
              onTap: _loading ? null : widget.onGuestCancel,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoCard(
                backgroundColor: colors.secondary,
                child: const Text(
                  'Tell us who you are',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose profile type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: UserType.values
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type.name.toUpperCase()),
                              selected: _selectedType == type,
                              onSelected: (_) => setState(() {
                                _selectedType = type;
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: _selectedType == UserType.company
                            ? 'Company name'
                            : 'Full name',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_selectedType == UserType.individual) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Unique username',
                          hintText: 'quest_player07',
                          prefixText: '@',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    NeoButton(
                      label: _loading ? 'Saving...' : 'Continue to app',
                      onPressed: _loading ? () {} : _save,
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 14),
                      const Center(
                        child: NeoLoader(label: 'Saving', size: 34),
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

  Future<void> _save() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name or company name.')),
      );
      return;
    }
    if (_selectedType == UserType.individual && _resolvedUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a unique username.')),
      );
      return;
    }
    final username = _selectedType == UserType.individual
        ? _resolvedUsername
        : name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();

    if (widget.authService == null) {
      widget.onGuestComplete?.call(_selectedType, name, username);
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.authService!.completeProfile(
        userType: _selectedType,
        displayName: name,
        username: username,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

/// Compact neo-brutalist button for AppBar actions.
class _NeoAppBarAction extends StatelessWidget {
  const _NeoAppBarAction({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    final bg = isDark
        ? Theme.of(context).colorScheme.surface
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.8,
              color: borderColor,
            ),
          ),
        ),
      ),
    );
  }
}
