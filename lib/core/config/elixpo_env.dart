import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElixpoEnv {
  static String get clientId => dotenv.env['ELIXPO_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['ELIXPO_CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['ELIXPO_REDIRECT_URI'] ?? 'questioare://login-callback';
  
  static String get authorizationUrl => dotenv.env['ELIXPO_AUTHORIZATION_URL'] ?? 'https://accounts.elixpo.com/oauth/authorize';
  static String get tokenUrl => dotenv.env['ELIXPO_TOKEN_URL'] ?? 'https://accounts.elixpo.com/oauth/token';
  static String get userInfoUrl => dotenv.env['ELIXPO_USERINFO_URL'] ?? 'https://accounts.elixpo.com/api/user';

  static bool get isConfigured => clientId.isNotEmpty && clientId != 'your_elixpo_client_id';
}
