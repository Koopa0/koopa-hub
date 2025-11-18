import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

part 'settings_provider.g.dart';

/// 訊息顯示模式
enum MessageDisplayMode {
  bubble,   // 氣泡模式（預設）- 適合短對話
  document, // 文檔模式 - 適合長文閱讀
}

/// 字體大小
enum FontSize {
  small,
  medium,
  large,
}

/// 應用設定模型
///
/// 合併了 SettingsProvider 和 AppPreferencesProvider 的功能
/// 統一管理所有使用者設定並持久化到 SharedPreferences
typedef AppSettings = ({
  String serverUrl,
  String? geminiApiKey,
  ThemeMode themeMode,
  String selectedModel,
  // 從 AppPreferencesProvider 合併的欄位
  MessageDisplayMode messageDisplayMode,
  FontSize fontSize,
  String locale,
});

/// 設定 Provider
///
/// 使用 AsyncNotifier 處理異步初始化
/// 因為需要從 SharedPreferences 載入設定
@riverpod
class Settings extends _$Settings {
  /// SharedPreferences 實例
  late SharedPreferences _prefs;

  /// build 方法：異步初始化
  ///
  /// AsyncNotifier 的 build 方法可以返回 Future
  /// Riverpod 會自動處理載入狀態
  @override
  Future<AppSettings> build() async {
    try {
      // 初始化 SharedPreferences
      _prefs = await SharedPreferences.getInstance();
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      debugPrint('Stack trace: $stackTrace');
      // 返回默認設定
      return _defaultSettings;
    }

    try {
      // 從本地儲存載入設定
      final serverUrl = _prefs.getString(AppConstants.keyServerUrl) ??
          AppConstants.defaultServerUrl;

      final geminiApiKey = _prefs.getString(AppConstants.keyGeminiApiKey);

      final themeModeString = _prefs.getString(AppConstants.keyThemeMode) ??
          'system';
      final themeMode = _themeModeFromString(themeModeString);

      final selectedModel = _prefs.getString(AppConstants.keySelectedModel) ??
          AppConstants.aiModels.first;

      // 讀取 AppPreferences 欄位
      final messageDisplayModeString =
          _prefs.getString('messageDisplayMode') ?? 'bubble';
      final messageDisplayMode = messageDisplayModeString == 'document'
          ? MessageDisplayMode.document
          : MessageDisplayMode.bubble;

      final fontSizeString = _prefs.getString('fontSize') ?? 'medium';
      final fontSize = FontSize.values.firstWhere(
        (e) => e.name == fontSizeString,
        orElse: () => FontSize.medium,
      );

      final locale = _prefs.getString('locale') ?? 'zh_TW';

      return (
        serverUrl: serverUrl,
        geminiApiKey: geminiApiKey,
        themeMode: themeMode,
        selectedModel: selectedModel,
        messageDisplayMode: messageDisplayMode,
        fontSize: fontSize,
        locale: locale,
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to read settings: $e');
      debugPrint('Stack trace: $stackTrace');
      // 返回默認設定
      return _defaultSettings;
    }
  }

  /// 默認設定
  AppSettings get _defaultSettings => (
        serverUrl: AppConstants.defaultServerUrl,
        geminiApiKey: null,
        themeMode: ThemeMode.system,
        selectedModel: AppConstants.aiModels.first,
        messageDisplayMode: MessageDisplayMode.bubble,
        fontSize: FontSize.medium,
        locale: 'zh_TW',
      );

  /// 安全地更新設定
  ///
  /// 使用 hasValue 避免在 loading/error 狀態時訪問 value
  Future<void> _updateSettings({
    String? serverUrl,
    String? geminiApiKey,
    bool removeApiKey = false,
    ThemeMode? themeMode,
    String? selectedModel,
    MessageDisplayMode? messageDisplayMode,
    FontSize? fontSize,
    String? locale,
  }) async {
    if (!state.hasValue) {
      debugPrint('Cannot update settings: current state is not data');
      return;
    }
    final currentValue = state.requireValue;

    // 更新狀態
    state = AsyncData((
      serverUrl: serverUrl ?? currentValue.serverUrl,
      geminiApiKey:
          removeApiKey ? null : (geminiApiKey ?? currentValue.geminiApiKey),
      themeMode: themeMode ?? currentValue.themeMode,
      selectedModel: selectedModel ?? currentValue.selectedModel,
      messageDisplayMode:
          messageDisplayMode ?? currentValue.messageDisplayMode,
      fontSize: fontSize ?? currentValue.fontSize,
      locale: locale ?? currentValue.locale,
    ));

    // 持久化到本地儲存
    try {
      if (serverUrl != null) {
        await _prefs.setString(AppConstants.keyServerUrl, serverUrl);
      }
      if (geminiApiKey != null) {
        await _prefs.setString(AppConstants.keyGeminiApiKey, geminiApiKey);
      }
      if (removeApiKey) {
        await _prefs.remove(AppConstants.keyGeminiApiKey);
      }
      if (themeMode != null) {
        await _prefs.setString(
          AppConstants.keyThemeMode,
          _themeModeToString(themeMode),
        );
      }
      if (selectedModel != null) {
        await _prefs.setString(AppConstants.keySelectedModel, selectedModel);
      }
      if (messageDisplayMode != null) {
        await _prefs.setString(
          'messageDisplayMode',
          messageDisplayMode.name,
        );
      }
      if (fontSize != null) {
        await _prefs.setString('fontSize', fontSize.name);
      }
      if (locale != null) {
        await _prefs.setString('locale', locale);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to persist settings: $e');
      debugPrint('Stack trace: $stackTrace');
      // 狀態已更新，但持久化失敗 - 下次啟動會恢復舊值
    }
  }

  /// 更新伺服器 URL
  Future<void> updateServerUrl(String url) async {
    await _updateSettings(serverUrl: url);
  }

  /// 更新 Gemini API Key
  Future<void> updateGeminiApiKey(String? apiKey) async {
    await _updateSettings(
      geminiApiKey: apiKey,
      removeApiKey: apiKey == null,
    );
  }

  /// 更新主題模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    await _updateSettings(themeMode: mode);
  }

  /// 更新選擇的模型
  Future<void> updateSelectedModel(String model) async {
    await _updateSettings(selectedModel: model);
  }

  /// 設定訊息顯示模式
  Future<void> updateMessageDisplayMode(MessageDisplayMode mode) async {
    await _updateSettings(messageDisplayMode: mode);
  }

  /// 切換訊息顯示模式
  Future<void> toggleMessageDisplayMode() async {
    if (!state.hasValue) return;
    final current = state.requireValue.messageDisplayMode;
    final newMode = current == MessageDisplayMode.bubble
        ? MessageDisplayMode.document
        : MessageDisplayMode.bubble;
    await updateMessageDisplayMode(newMode);
  }

  /// 設定字體大小
  Future<void> updateFontSize(FontSize size) async {
    await _updateSettings(fontSize: size);
  }

  /// 設定語言
  Future<void> updateLocale(String newLocale) async {
    await _updateSettings(locale: newLocale);
  }

  /// 重置所有設定
  Future<void> resetSettings() async {
    await _prefs.clear();

    // 重新初始化
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }

  /// 輔助方法：ThemeMode 轉字串
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// 輔助方法：字串轉 ThemeMode
  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// 當前主題模式 Provider
///
/// 從設定中提取主題模式，簡化 UI 訪問
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}

/// 當前選擇的模型 Provider
@riverpod
String currentSelectedModel(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.selectedModel,
    loading: () => AppConstants.aiModels.first,
    error: (_, __) => AppConstants.aiModels.first,
  );
}

/// 當前訊息顯示模式 Provider
@riverpod
MessageDisplayMode currentMessageDisplayMode(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.messageDisplayMode,
    loading: () => MessageDisplayMode.bubble,
    error: (_, __) => MessageDisplayMode.bubble,
  );
}

/// 當前字體大小 Provider
@riverpod
FontSize currentFontSize(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.fontSize,
    loading: () => FontSize.medium,
    error: (_, __) => FontSize.medium,
  );
}

/// 當前語言設定 Provider
@riverpod
String currentLocale(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.locale,
    loading: () => 'zh_TW',
    error: (_, __) => 'zh_TW',
  );
}

/// 伺服器連接狀態 Provider
///
/// 檢查是否能連接到 koopa-server
@riverpod
class ServerStatus extends _$ServerStatus {
  @override
  Future<bool> build() async {
    // TODO: 實際檢查伺服器連接
    // 現在先返回 true
    return true;
  }

  /// 檢查連接
  Future<void> checkConnection() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // TODO: 發送 ping 請求到伺服器
      await Future.delayed(const Duration(seconds: 1));
      return true;
    });
  }
}
