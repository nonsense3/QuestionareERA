import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/config/elixpo_env.dart';
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

  String get profileUsername => _currentUser?.email.split('@').first ?? '';

  bool get isGoogleLinked => _currentUser?.provider == 'google';
  bool get isGithubLinked => _currentUser?.provider == 'github';
  
  String? get googleProfilePictureUrl {
    if (isGoogleLinked) return _currentUser?.avatarUrl;
    return null;
  }
  
  String? get githubProfilePictureUrl {
    if (isGithubLinked) return _currentUser?.avatarUrl;
    return null;
  }

  StreamSubscription<AuthState>? _supabaseAuthSubscription;

  void _initSupabaseListener() {
    _supabaseAuthSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _handleSupabaseSession(session.user);
      } else {
        // Only clear if Elixpo is ALSO bare. 
        // We will manage sign-out independently.
      }
    });
  }

  void _handleSupabaseSession(User user) {
    _currentUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      userType: UserType.individual, // Defaults
      displayName: user.userMetadata?['display_name'] ?? 'Supabase User',
      provider: 'email', 
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSession() async {
    try {
      // 1. Check Supabase first (it auto-persists)
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      if (supabaseSession != null) {
        _handleSupabaseSession(supabaseSession.user);
        return;
      }

      // 2. Check Elixpo
      final token = await _storage.read(key: 'elixpo_access_token');
      if (token != null) {
        await _fetchUserProfile(token);
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

  Future<void> signInWithElixpo() async {
    try {
      final baseUri = Uri.parse(ElixpoEnv.authorizationUrl);
      final authUrl = baseUri.replace(
        queryParameters: {
          ...baseUri.queryParameters,
          'response_type': 'code',
          'client_id': ElixpoEnv.clientId,
          'redirect_uri': ElixpoEnv.redirectUri,
          'state': 'xyz123',
          if (!baseUri.queryParameters.containsKey('scope')) 'scope': 'openid profile email',
        },
      );

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'questioare',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No authorization code returned');

      await _exchangeCodeForToken(code);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Elixpo Auth Error: $e');
      rethrow;
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse(ElixpoEnv.tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': ElixpoEnv.redirectUri,
        'client_id': ElixpoEnv.clientId,
        if (ElixpoEnv.clientSecret.isNotEmpty) 'client_secret': ElixpoEnv.clientSecret,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to exchange code: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final accessToken = data['access_token'];

    await _storage.write(key: 'elixpo_access_token', value: accessToken);
    if (data['refresh_token'] != null) {
      await _storage.write(key: 'elixpo_refresh_token', value: data['refresh_token']);
    }

    await _fetchUserProfile(accessToken);
  }



  Future<void> signInWithEmail({required String email, required String password}) async {
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

  Future<void> signUpWithEmail({required String email, required String password}) async {
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

  Future<void> verifyEmailOtp({required String email, required String otp}) async {
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

  Future<void> linkEmailAndPassword({required String email, required String password}) async {
    // Attempting to link email to an Elixpo user or Supabase user
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
        ),
      );
    } catch (e) {
      if (kDebugMode) print('Supabase Link Email Error: $e');
      rethrow;
    }
  }

  Future<void> signInAsGuest() async {
    _currentUser = const AppUser(
      id: 'guest',
      email: 'guest@questioare.app',
      userType: UserType.individual,
      displayName: 'Guest User',
    );
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse(ElixpoEnv.userInfoUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = AppUser(
        id: data['id'] ?? 'unknown',
        email: data['email'] ?? '',
        userType: UserType.individual, 
        displayName: data['displayName'] ?? 'Elixpo User',
        provider: data['provider'],
        avatarUrl: data['picture'] ?? data['avatar_url'],
      );
    } else {
      await signOut(); // Invalid token
    }
  }

  Future<void> completeProfile({
    required UserType userType,
    required String displayName,
    required String username,
  }) async {
    // In a real app with Elixpo, you'd send this to your own backend 
    // to map the Elixpo user ID to these app-specific details.
    // For now, we update local state cache:
    if (_currentUser != null) {
      _currentUser = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        userType: userType,
        displayName: displayName,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _supabaseAuthSubscription?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // Ignore failure, proceed to local clear
    }
    await _storage.delete(key: 'elixpo_access_token');
    await _storage.delete(key: 'elixpo_refresh_token');
    _currentUser = null;
    notifyListeners();
  }
}
