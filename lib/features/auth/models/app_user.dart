import '../../../core/constants/app_constants.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.userType,
    required this.displayName,
    required this.username,
    this.linkedProviders = const {},
    this.avatarUrl,
  });

  final String id;
  final String email;
  final UserType? userType;
  final String displayName;
  final String username;

  /// All OAuth providers attached to this account (e.g. {'google', 'github'}).
  final Set<String> linkedProviders;

  final String? avatarUrl;

  bool get isGoogleLinked => linkedProviders.contains('google');
  bool get isGithubLinked => linkedProviders.contains('github');

  /// Primary provider for avatar display (prefer google, then github)
  String? get primaryProvider {
    if (isGoogleLinked) return 'google';
    if (isGithubLinked) return 'github';
    if (linkedProviders.isNotEmpty) return linkedProviders.first;
    return null;
  }
}
