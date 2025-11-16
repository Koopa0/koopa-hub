import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

part 'settings_provider.g.dart';

/// 應用設定模型
///
/// 使用 record type（Dart 3.0+ 特性）來定義設定
/// Record 是輕量級的不可變資料結構
typedef AppSettings = ({
  String serverUrl,
  String? geminiApiKey,
  ThemeMode themeMode,
  String selectedModel,
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

      return (
        serverUrl: serverUrl,
        geminiApiKey: geminiApiKey,
        themeMode: themeMode,
        selectedModel: selectedModel,
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
      );

  /// 安全地更新設定
  ///
  /// 使用 valueOrNull 避免在 loading/error 狀態時訪問 value
  Future<void> _updateSettings({
    String? serverUrl,
    String? geminiApiKey,
    bool removeApiKey = false,
    ThemeMode? themeMode,
    String? selectedModel,
  }) async {
    final currentValue = state.valueOrNull;
    if (currentValue == null) {
      debugPrint('Cannot update settings: current state is not data');
      return;
    }

    // 更新狀態
    state = AsyncData((
      serverUrl: serverUrl ?? currentValue.serverUrl,
      geminiApiKey:
          removeApiKey ? null : (geminiApiKey ?? currentValue.geminiApiKey),
      themeMode: themeMode ?? currentValue.themeMode,
      selectedModel: selectedModel ?? currentValue.selectedModel,
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
ThemeMode currentThemeMode(CurrentThemeModeRef ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}

/// 當前選擇的模型 Provider
@riverpod
String currentSelectedModel(CurrentSelectedModelRef ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.selectedModel,
    loading: () => AppConstants.aiModels.first,
    error: (_, __) => AppConstants.aiModels.first,
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
