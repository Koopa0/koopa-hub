class AppConstants {
  // App Info
  static const String appName = 'Koopa Hub';
  static const String appVersion = '1.0.0';

  // Default Server Config
  static const String defaultServerUrl = 'http://localhost:8080';

  // AI Models
  static const List<String> aiModels = [
    'Koopa (Local RAG)',
    'Koopa (Web Search)',
    'Gemini (Cloud)',
  ];

  // App Modes
  static const String modeHome = 'home';
  static const String modeChat = 'chat';
  static const String modeMindMap = 'mindmap';
  static const String modeKnowledge = 'knowledge';
  static const String modeCanvas = 'canvas';
  static const String modeArena = 'arena';
  static const String modeAudio = 'audio';
  static const String modeTools = 'tools';

  // Message Types
  static const String messageTypeUser = 'user';
  static const String messageTypeAssistant = 'assistant';
  static const String messageTypeSystem = 'system';

  // Storage Keys
  static const String keyServerUrl = 'server_url';
  static const String keyGeminiApiKey = 'gemini_api_key';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedModel = 'selected_model';
  static const String keySidebarExpanded = 'sidebar_expanded';

  // UI Constants
  static const double sidebarWidthExpanded = 280.0;
  static const double sidebarWidthCollapsed = 72.0;
  static const double maxContentWidth = 1000.0;
  static const double borderRadius = 12.0;
  static const double toolbarWidth = 56.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}
