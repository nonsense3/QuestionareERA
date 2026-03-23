import '../../../core/constants/app_constants.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.userType,
    required this.displayName,
    this.provider,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final UserType userType;
  final String displayName;
  final String? provider;
  final String? avatarUrl;
}

