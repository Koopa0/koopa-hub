import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

/// 應用程式入口點
///
/// Flutter 3.38 最佳實踐：
/// 1. 使用 async main() 處理異步初始化
/// 2. 在 runApp 之前完成所有必要的初始化
/// 3. 使用 ProviderScope 包裹整個應用（Riverpod 3.0）
/// 4. 處理錯誤和異常
Future<void> main() async {
  // 確保 Flutter 綁定已初始化
  // 這在呼叫任何 Flutter API 之前是必須的
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地資料庫（Hive）
  // Hive 是一個輕量級、快速的 NoSQL 資料庫，適合 Flutter
  await _initializeHive();

  // 桌面平台特定初始化
  if (_isDesktop) {
    await _initializeDesktop();
  }

  // 設定全域錯誤處理
  _setupErrorHandling();

  // 啟動應用
  // ProviderScope 是 Riverpod 的根 widget
  // 它儲存所有 provider 的狀態
  runApp(
    // Riverpod 3.0: ProviderScope 包裹整個應用
    const ProviderScope(
      child: KoopaAssistantApp(),
    ),
  );
}

/// 初始化 Hive 資料庫
///
/// Hive 用於：
/// - 儲存聊天會話歷史
/// - 快取知識庫文件列表
/// - 儲存使用者設定
Future<void> _initializeHive() async {
  // 初始化 Hive（Flutter 版本）
  await Hive.initFlutter();

  // TODO: 註冊 Hive 適配器（用於自訂類型）
  // Hive.registerAdapter(ChatSessionAdapter());
  // Hive.registerAdapter(MessageAdapter());
  // Hive.registerAdapter(KnowledgeDocumentAdapter());

  // 開啟資料盒子（類似於資料表）
  // await Hive.openBox('chat_sessions');
  // await Hive.openBox('knowledge_documents');
  // await Hive.openBox('settings');
}

/// 桌面平台初始化
///
/// 設定視窗大小、標題等
Future<void> _initializeDesktop() async {
  // 初始化視窗管理器
  await windowManager.ensureInitialized();

  // 視窗選項
  const windowOptions = WindowOptions(
    size: Size(1280, 800), // 預設視窗大小
    minimumSize: Size(800, 600), // 最小視窗大小
    center: true, // 置中顯示
    backgroundColor: Colors.transparent, // 透明背景
    skipTaskbar: false,
    title: 'Koopa Assistant', // 視窗標題
    titleBarStyle: TitleBarStyle.normal,
  );

  // 應用視窗選項
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// 設定全域錯誤處理
///
/// Flutter 3.38: 推薦的錯誤處理模式
void _setupErrorHandling() {
  // 捕獲 Flutter 框架錯誤
  FlutterError.onError = (FlutterErrorDetails details) {
    // 在開發模式下顯示詳細錯誤
    FlutterError.presentError(details);

    // TODO: 在生產環境中，將錯誤發送到日誌服務
    // 例如：Sentry, Firebase Crashlytics
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  // 捕獲非 Flutter 錯誤（如 async 錯誤）
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack Trace: $stack');
    return true; // 表示錯誤已處理
  };
}

/// 輔助方法：檢查是否為桌面平台
///
/// Dart 3.10: 使用 getter 而不是方法讓程式碼更簡潔
bool get _isDesktop {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
