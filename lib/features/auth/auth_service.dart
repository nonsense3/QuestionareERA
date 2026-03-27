import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'models/app_user.dart';

class AuthService extends ChangeNotifier {
  AuthService() {
    _initSupabaseListener();
    _loadSession();
  }

  final _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  String? get currentUserId => _currentUser?.id;

  bool get isProfileComplete => _currentUser?.userType != null;

  UserType get profileUserType => _currentUser?.userType ?? UserType.individual;

  String get profileDisplayName => _currentUser?.displayName ?? 'Questioare User';

  String get profileUsername => _currentUser?.username ?? '';

  bool get isGoogleLinked => _currentUser?.isGoogleLinked ?? false;
  bool get isGithubLinked => _currentUser?.isGithubLinked ?? false;

  /// Provider used for the **current session** (e.g. 'google' or 'github').
  /// When both are linked, we display the avatar for this provider.
  String? get sessionProvider => _sessionProvider;

  String? get googleProfilePictureUrl {
    if (isGoogleLinked) return _googleAvatarUrl;
    return null;
  }

  String? get githubProfilePictureUrl {
    if (isGithubLinked) return _githubAvatarUrl;
    return null;
  }

  /// Avatar URL to show in UI based on [sessionProvider].
  /// If unknown, falls back to Google then GitHub.
  String? get activeAvatarUrl =>
      _pickAvatarForProvider(_sessionProvider, _googleAvatarUrl, _githubAvatarUrl);

  String? _sessionProvider;
  String? _googleAvatarUrl;
  String? _githubAvatarUrl;

  StreamSubscription<AuthState>? _supabaseAuthSubscription;

  /// Ensures provider metadata (e.g. Google `picture`) is fetched from server.
  /// Some sessions don't include full identity data until `getUser()` is called.
  Future<void> refreshSupabaseUser() async {
    try {
      final res = await Supabase.instance.client.auth.getUser();
      final user = res.user;
      if (user == null) return;
      _sessionProvider ??= user.appMetadata['provider'] as String?;
      await _handleSupabaseSession(user);
    } catch (e) {
      if (kDebugMode) print('Failed to refresh Supabase user: $e');
    }
  }

  void _initSupabaseListener() {
    _supabaseAuthSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _sessionProvider = session.user.appMetadata['provider'] as String?;
        _handleSupabaseSession(session.user);
      } else {
        _currentUser = null;
        _sessionProvider = null;
        _googleAvatarUrl = null;
        _githubAvatarUrl = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _handleSupabaseSession(User user) async {
    final cachedTypeStr = await _storage.read(key: 'userType_${user.id}');
    final cachedName = await _storage.read(key: 'displayName_${user.id}');
    final cachedUsername = await _storage.read(key: 'username_${user.id}');

    UserType? resolvedType;
    if (cachedTypeStr == 'individual') resolvedType = UserType.individual;
    if (cachedTypeStr == 'company') resolvedType = UserType.company;

    // Collect all linked provider IDs from Supabase identities
    final identities = user.identities ?? [];
    final linkedProviders = identities
        .map((i) => i.provider)
        .toSet();

    final usernameOverride = cachedUsername ??
        user.userMetadata?['user_name'] ??
        user.userMetadata?['preferred_username'] ??
        user.email?.split('@').first ??
        '';

    final displayNameOverride = cachedName ??
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        'Questioare User';

    final avatars = _resolveProviderAvatars(user);
    _googleAvatarUrl = avatars.googleUrl;
    _githubAvatarUrl = avatars.githubUrl;
    final avatarUrl =
        _pickAvatarForProvider(_sessionProvider, _googleAvatarUrl, _githubAvatarUrl);

    _currentUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      userType: resolvedType,
      displayName: displayNameOverride,
      username: usernameOverride,
      linkedProviders: linkedProviders,
      avatarUrl: avatarUrl,
    );
    _isLoading = false;
    notifyListeners();
  }

  ({String? googleUrl, String? githubUrl}) _resolveProviderAvatars(User user) {
    final meta = user.userMetadata;
    final googleFromMeta = meta?['picture'] as String?;
    final githubFromMeta = meta?['avatar_url'] as String?;

    final identities = user.identities;
    if (identities == null) {
      return (
        googleUrl: (googleFromMeta != null && googleFromMeta.isNotEmpty)
            ? googleFromMeta
            : null,
        githubUrl: (githubFromMeta != null && githubFromMeta.isNotEmpty)
            ? githubFromMeta
            : null,
      );
    }
    String? googleUrl =
        (googleFromMeta != null && googleFromMeta.isNotEmpty) ? googleFromMeta : null;
    String? githubUrl =
        (githubFromMeta != null && githubFromMeta.isNotEmpty) ? githubFromMeta : null;
    for (final identity in identities) {
      final provider = identity.provider;
      final data = identity.identityData;
      if (data == null) continue;
      if (provider == 'google') {
        final u = (data['picture'] ?? data['avatar_url']) as String?;
        if (u != null && u.isNotEmpty) googleUrl ??= u;
      } else if (provider == 'github') {
        final u = (data['avatar_url'] ?? data['picture']) as String?;
        if (u != null && u.isNotEmpty) githubUrl ??= u;
      }
    }
    return (googleUrl: googleUrl, githubUrl: githubUrl);
  }

  String? _pickAvatarForProvider(
    String? provider,
    String? googleUrl,
    String? githubUrl,
  ) {
    if (provider == 'github') return githubUrl ?? googleUrl;
    if (provider == 'google') return googleUrl ?? githubUrl;
    return googleUrl ?? githubUrl;
  }

  Future<void> _loadSession() async {
    try {
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      if (supabaseSession != null) {
        await _handleSupabaseSession(supabaseSession.user);
        return;
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load session: $e');
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ── Supabase Email/Password ─────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) print('Supabase Auth Error: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) print('Supabase Sign Up Error: $e');
      rethrow;
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: otp,
        email: email,
      );
    } catch (e) {
      if (kDebugMode) print('Supabase OTP Verify Error: $e');
      rethrow;
    }
  }

  // ── Supabase Social OAuth ───────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.questioare://login-callback',
      );
    } catch (e) {
      if (kDebugMode) print('Google OAuth Error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGithub() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb ? null : 'io.supabase.questioare://login-callback',
      );
    } catch (e) {
      if (kDebugMode) print('GitHub OAuth Error: $e');
      rethrow;
    }
  }

  /// Links Google to the CURRENT existing account (does not create new user).
  Future<void> linkGoogleIdentity() async {
    try {
      await Supabase.instance.client.auth.linkIdentity(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.questioare://login-callback',
      );
    } catch (e) {
      if (kDebugMode) print('Google link identity error: $e');
      rethrow;
    }
  }

  /// Links GitHub to the CURRENT existing account (does not create new user).
  Future<void> linkGithubIdentity() async {
    try {
      await Supabase.instance.client.auth.linkIdentity(
        OAuthProvider.github,
        redirectTo: kIsWeb ? null : 'io.supabase.questioare://login-callback',
      );
    } catch (e) {
      if (kDebugMode) print('GitHub link identity error: $e');
      rethrow;
    }
  }

  // ── Guest ───────────────────────────────────────────────────────────────────

  Future<void> signInAsGuest() async {
    _currentUser = const AppUser(
      id: 'guest',
      email: 'guest@questioare.app',
      userType: UserType.individual,
      displayName: 'Guest User',
      username: 'guest_001',
      linkedProviders: {},
    );
    notifyListeners();
  }

  // ── Profile ─────────────────────────────────────────────────────────────────

  Future<void> completeProfile({
    required UserType userType,
    required String displayName,
    required String username,
  }) async {
    if (_currentUser != null) {
      await _storage.write(
          key: 'userType_${_currentUser!.id}', value: userType.name);
      await _storage.write(
          key: 'displayName_${_currentUser!.id}', value: displayName);
      await _storage.write(
          key: 'username_${_currentUser!.id}', value: username);

      _currentUser = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        userType: userType,
        displayName: displayName,
        username: username,
        linkedProviders: _currentUser!.linkedProviders,
        avatarUrl: _currentUser!.avatarUrl,
      );
      notifyListeners();
    }
  }

  // ── Social linking (in-memory after OAuth completes) ───────────────────────

  Future<void> linkSocialProvider(String provider) async {
    if (_currentUser != null) {
      _currentUser = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        userType: _currentUser!.userType,
        displayName: _currentUser!.displayName,
        username: _currentUser!.username,
        linkedProviders: {..._currentUser!.linkedProviders, provider},
        avatarUrl: _currentUser!.avatarUrl,
      );
      notifyListeners();
    }
  }

  Future<void> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
    } catch (e) {
      if (kDebugMode) print('Link email/password error: $e');
      rethrow;
    }
  }

  // ── Account deletion ────────────────────────────────────────────────────────
  ///
  /// Deleting a Supabase Auth user requires **service role** privileges.
  /// This client method calls a Supabase Edge Function to perform the deletion
  /// securely, then signs out locally.
  ///
  /// Required Edge Function (create in Supabase):
  /// - Name: `delete-account` (or `delete_account`)
  /// - Must verify the caller JWT and delete ONLY that user + related data.
  Future<void> deleteAccount() async {
    final session = Supabase.instance.client.auth.currentSession;
    final uid = session?.user.id ?? _currentUser?.id;
    if (uid == null || uid.isEmpty || uid == 'guest') {
      await signOut();
      return;
    }

    // Prefer kebab-case; fallback to snake_case.
    final res = await _invokeDeleteAccount();
    if (res == null) {
      throw Exception('Edge Function not found: delete-account / delete_account');
    }
    if (res.status != 200) {
      throw Exception('Delete failed (${res.status}): ${res.data}');
    }

    await _storage.delete(key: 'userType_$uid');
    await _storage.delete(key: 'displayName_$uid');
    await _storage.delete(key: 'username_$uid');
    await signOut();
  }

  Future<FunctionResponse?> _invokeDeleteAccount() async {
    try {
      return await Supabase.instance.client.functions.invoke('delete-account');
    } catch (_) {
      // try snake_case
    }
    try {
      return await Supabase.instance.client.functions.invoke('delete_account');
    } catch (_) {
      return null;
    }
  }

  // ── Sign out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _supabaseAuthSubscription?.cancel();
    super.dispose();
  }
}
