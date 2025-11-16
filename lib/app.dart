import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/home/home_page.dart';

/// Koopa Hub 主應用
///
/// Flutter 3.38 最佳實踐：
/// 1. 使用 ConsumerWidget 代替 StatelessWidget（Riverpod 3.0）
/// 2. 全面採用 Material 3
/// 3. 支援深色模式和動態主題
/// 4. 使用 MaterialApp 的最新功能
class KoopaHubApp extends ConsumerWidget {
  const KoopaHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 監聽主題模式設定
    // 當使用者更改主題時，UI 會自動重建
    //
    // Riverpod 3.0: 使用 ref.watch() 監聽 provider
    // 當 provider 的值改變時，build 方法會自動重新執行
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp(
      // 應用標題（顯示在任務管理器等地方）
      title: AppConstants.appName,

      // 除錯橫幅（生產環境會自動隱藏）
      debugShowCheckedModeBanner: false,

      // 國際化支援
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),    // English
        Locale('zh', ''),    // Traditional Chinese (Taiwan)
        Locale('zh', 'TW'),  // Traditional Chinese (Taiwan)
      ],

      // Material 3 主題配置
      //
      // Material 3 是 Google 最新的設計語言
      // 特點：
      // - 更圓潤的邊角
      // - 更豐富的顏色系統
      // - 更好的無障礙支援
      // - 動態顏色（可根據系統主題調整）
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // 主題模式
      // system: 跟隨系統設定
      // light: 強制淺色
      // dark: 強制深色
      themeMode: themeMode,

      // 首頁
      home: const HomePage(),

      // Material 3 動畫設定
      //
      // Flutter 3.38: 改進的頁面轉場動畫
      themeAnimationDuration: AppConstants.mediumDuration,
      themeAnimationCurve: Curves.easeInOutCubicEmphasized,

      // 建構器：在每個頁面外包裹額外的 widget
      //
      // 這裡我們可以：
      // - 添加全域 Snackbar
      // - 處理鍵盤事件
      // - 添加全域手勢
      builder: (context, child) {
        return _AppBuilder(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// 應用建構器
///
/// 包裹整個應用的輔助 widget
/// 用於處理：
/// - 全域手勢和快捷鍵
/// - 響應式佈局
/// - 無障礙功能
class _AppBuilder extends StatelessWidget {
  const _AppBuilder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // 確保文字縮放不會破壞佈局
      //
      // Flutter 3.38: 改進的文字縮放處理
      // clampDouble 確保文字縮放在合理範圍內
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.5,
            ),
      ),
      child: child,
    );
  }
}

/// 應用生命週期管理
///
/// 可選的 widget，用於處理應用的生命週期事件
/// 例如：應用進入背景、恢復前景等
///
/// 使用方式：在 MaterialApp 的 home 外包裹此 widget
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 註冊生命週期觀察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除觀察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 處理不同的生命週期狀態
    switch (state) {
      case AppLifecycleState.resumed:
        // 應用恢復前景
        debugPrint('App Resumed');
        // TODO: 重新連接伺服器、刷新資料等
        break;

      case AppLifecycleState.inactive:
        // 應用變為非活躍狀態（例如來電）
        debugPrint('App Inactive');
        break;

      case AppLifecycleState.paused:
        // 應用進入背景
        debugPrint('App Paused');
        // TODO: 儲存狀態、斷開連接等
        break;

      case AppLifecycleState.detached:
        // 應用即將終止
        debugPrint('App Detached');
        break;

      case AppLifecycleState.hidden:
        // 應用被隱藏
        debugPrint('App Hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
