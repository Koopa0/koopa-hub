class AppConstants {
  // App Info
  static const String appName = 'Koopa Hub';
  static const String appVersion = '1.0.0';

  // Default Server Config
  static const String defaultServerUrl = 'http://localhost:8080';

  // AI Models
  static const List<String> aiModels = [
    'Koopa (本地 RAG)',
    'Koopa (網路搜尋)',
    'Gemini (雲端)',
  ];

  // Message Types
  static const String messageTypeUser = 'user';
  static const String messageTypeAssistant = 'assistant';
  static const String messageTypeSystem = 'system';

  // Storage Keys
  static const String keyServerUrl = 'server_url';
  static const String keyGeminiApiKey = 'gemini_api_key';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedModel = 'selected_model';

  // UI Constants
  static const double sidebarWidth = 280.0;
  static const double maxContentWidth = 800.0;
  static const double borderRadius = 12.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}
