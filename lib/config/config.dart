// Create a separate config.dart file
class AppConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'AIzaSyAPw_uTorkc1PLIbAwiKOjK_yUK8UjXRWo',
    defaultValue: '', // Empty default for security
  );
}