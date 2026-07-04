import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Strongly-typed access to environment variables.
/// Call [AppEnv.load()] before runApp().
abstract class AppEnv {
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get anthropicApiKey =>
      dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  static String get anthropicBaseUrl =>
      dotenv.env['ANTHROPIC_BASE_URL'] ?? 'https://api.anthropic.com/v1';

  static String get claudeModel =>
      dotenv.env['CLAUDE_MODEL'] ?? 'claude-sonnet-4-6';

  static String get appEnv =>
      dotenv.env['APP_ENV'] ?? 'development';

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  static int get freeScanLimit =>
      int.tryParse(dotenv.env['FREE_SCAN_LIMIT'] ?? '3') ?? 3;

  static String get revenueCatIos =>
      dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';

  static String get revenueCatAndroid =>
      dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
}
