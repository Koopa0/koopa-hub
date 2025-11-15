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
    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();

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
  }

  /// 更新伺服器 URL
  Future<void> updateServerUrl(String url) async {
    // 先更新 UI 狀態
    state = AsyncData((
      serverUrl: url,
      geminiApiKey: state.value?.geminiApiKey,
      themeMode: state.value?.themeMode ?? ThemeMode.system,
      selectedModel: state.value?.selectedModel ?? AppConstants.aiModels.first,
    ));

    // 然後持久化到本地儲存
    await _prefs.setString(AppConstants.keyServerUrl, url);
  }

  /// 更新 Gemini API Key
  Future<void> updateGeminiApiKey(String? apiKey) async {
    state = AsyncData((
      serverUrl: state.value?.serverUrl ?? AppConstants.defaultServerUrl,
      geminiApiKey: apiKey,
      themeMode: state.value?.themeMode ?? ThemeMode.system,
      selectedModel: state.value?.selectedModel ?? AppConstants.aiModels.first,
    ));

    if (apiKey != null) {
      await _prefs.setString(AppConstants.keyGeminiApiKey, apiKey);
    } else {
      await _prefs.remove(AppConstants.keyGeminiApiKey);
    }
  }

  /// 更新主題模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    state = AsyncData((
      serverUrl: state.value?.serverUrl ?? AppConstants.defaultServerUrl,
      geminiApiKey: state.value?.geminiApiKey,
      themeMode: mode,
      selectedModel: state.value?.selectedModel ?? AppConstants.aiModels.first,
    ));

    await _prefs.setString(
      AppConstants.keyThemeMode,
      _themeModeToString(mode),
    );
  }

  /// 更新選擇的模型
  Future<void> updateSelectedModel(String model) async {
    state = AsyncData((
      serverUrl: state.value?.serverUrl ?? AppConstants.defaultServerUrl,
      geminiApiKey: state.value?.geminiApiKey,
      themeMode: state.value?.themeMode ?? ThemeMode.system,
      selectedModel: model,
    ));

    await _prefs.setString(AppConstants.keySelectedModel, model);
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
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

/// 當前選擇的模型 Provider
final currentSelectedModelProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (data) => data.selectedModel,
    loading: () => AppConstants.aiModels.first,
    error: (_, __) => AppConstants.aiModels.first,
  );
});

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
