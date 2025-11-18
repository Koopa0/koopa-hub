import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

part 'app_preferences_provider.g.dart';

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

/// 應用偏好設定狀態
class AppPreferencesState {
  const AppPreferencesState({
    this.messageDisplayMode = MessageDisplayMode.bubble,
    this.fontSize = FontSize.medium,
    this.locale = const Locale('zh', 'TW'),
  });

  final MessageDisplayMode messageDisplayMode;
  final FontSize fontSize;
  final Locale locale;

  AppPreferencesState copyWith({
    MessageDisplayMode? messageDisplayMode,
    FontSize? fontSize,
    Locale? locale,
  }) {
    return AppPreferencesState(
      messageDisplayMode: messageDisplayMode ?? this.messageDisplayMode,
      fontSize: fontSize ?? this.fontSize,
      locale: locale ?? this.locale,
    );
  }
}

/// 應用偏好設定 Provider
@riverpod
class AppPreferences extends _$AppPreferences {
  @override
  AppPreferencesState build() {
    return const AppPreferencesState();
  }

  /// 設定訊息顯示模式
  void setMessageDisplayMode(MessageDisplayMode mode) {
    state = state.copyWith(messageDisplayMode: mode);
  }

  /// 設定字體大小
  void setFontSize(FontSize size) {
    state = state.copyWith(fontSize: size);
  }

  /// 設定語言
  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  /// 切換訊息顯示模式
  void toggleMessageDisplayMode() {
    final newMode = state.messageDisplayMode == MessageDisplayMode.bubble
        ? MessageDisplayMode.document
        : MessageDisplayMode.bubble;
    setMessageDisplayMode(newMode);
  }
}

/// 當前訊息顯示模式
@riverpod
MessageDisplayMode currentMessageDisplayMode(Ref ref) {
  return ref.watch(appPreferencesProvider).messageDisplayMode;
}

/// 當前字體大小
@riverpod
FontSize currentFontSize(Ref ref) {
  return ref.watch(appPreferencesProvider).fontSize;
}

/// 當前語言設定
@riverpod
Locale currentLocale(Ref ref) {
  return ref.watch(appPreferencesProvider).locale;
}
