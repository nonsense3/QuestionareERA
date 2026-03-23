import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/public_user_id.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import '../auth/auth_service.dart';
import 'profile_avatar_constants.dart';

/// Profile photo rules (focus: **Google** for provider avatars):
/// - **Google sign-in or linked Google:** show image from Google URL via Supabase session
/// - **Email / phone + password:** optional upload, max [kMaxLocalProfilePhotoBytes].
///
/// Also shows **username** and a **14-digit User ID** (derived from Supabase
/// `auth.users.id` for display only).
class ProfileAvatarHeader extends StatefulWidget {
  const ProfileAvatarHeader({
    super.key,
    required this.authService,
    required this.displayName,
    required this.username,
    required this.userType,
  });

  final AuthService? authService;
  final String displayName;
  final String username;
  final UserType userType;

  @override
  State<ProfileAvatarHeader> createState() => _ProfileAvatarHeaderState();
}

class _ProfileAvatarHeaderState extends State<ProfileAvatarHeader> {
  Uint8List? _localAvatarBytes;

  @override
  Widget build(BuildContext context) {
    final auth = widget.authService;
    if (auth == null) {
      return _buildCard(
        context,
        avatar: _avatarFallback(),
        userId: null,
        caption: 'Sign in with Supabase to get a permanent user ID and avatars.',
      );
    }

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        final googleUrl = auth.googleProfilePictureUrl;
        final githubUrl = auth.githubProfilePictureUrl;
        final avatarUrl = googleUrl ?? githubUrl;

        final Widget avatar;
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          avatar = ClipOval(
            child: Image.network(
              avatarUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _avatarFallback(),
            ),
          );
        } else if (_localAvatarBytes != null) {
          avatar = ClipOval(
            child: Image.memory(
              _localAvatarBytes!,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          );
        } else {
          avatar = _avatarFallback();
        }

        final caption = avatarUrl != null && avatarUrl.isNotEmpty
            ? 'Photo from social provider.'
            : 'Add a profile photo (max 1 MB) or link a social account.';

        return _buildCard(
          context,
          avatar: avatar,
          userId: auth.currentUserId,
          caption: caption,
          extra: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoButton(
                label: 'Upload photo (max 1 MB)',
                onPressed: _pickLocalAvatar,
                color: Theme.of(context).colorScheme.secondary,
              ),
              if (_localAvatarBytes != null)
                TextButton(
                  onPressed: () => setState(() => _localAvatarBytes = null),
                  child: const Text('Remove uploaded photo'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdentityLines({required String? userId}) {
    final isCompany = widget.userType == UserType.company;
    final handle = widget.username.trim();
    final name = widget.displayName.trim();
    final displayUserId =
        (userId != null && userId.isNotEmpty) ? publicUserId14(userId) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompany) ...[
          Text(
            name.isEmpty ? 'Company' : name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ] else if (handle.isNotEmpty) ...[
          Text(
            '@$handle',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ] else if (name.isNotEmpty) ...[
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
        const SizedBox(height: 6),
        const Text(
          'USER ID',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                displayUserId ?? '—',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  fontFamily: 'monospace',
                  letterSpacing: 0.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (displayUserId != null && displayUserId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: IconButton(
                  tooltip: 'Copy user ID',
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: displayUserId));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID copied'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        if (userId == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Assigned automatically after login.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Widget avatar,
    required String? userId,
    required String caption,
    Widget? extra,
  }) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    width: 3,
                  ),
                ),
                child: avatar,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityLines(userId: userId),
                    const SizedBox(height: 10),
                    Text(
                      caption,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra,
          ],
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 96,
      height: 96,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, size: 48),
    );
  }

  Future<void> _pickLocalAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read image file.')),
        );
      }
      return;
    }
    if (bytes.length > kMaxLocalProfilePhotoBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image must be under ${kMaxLocalProfilePhotoBytes ~/ 1024} KB (1 MB).',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _localAvatarBytes = bytes);
    if (kDebugMode) {
      debugPrint('Local avatar set: ${bytes.length} bytes (upload to Supabase Storage separately).');
    }
  }
}
