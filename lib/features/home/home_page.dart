import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../chat/pages/chat_page.dart';
import '../knowledge/pages/knowledge_page.dart';
import '../settings/pages/settings_page.dart';

part 'home_page.g.dart';

/// 首頁選擇的索引 Provider
///
/// 使用 Riverpod 3.0 code generation 管理簡單的狀態
/// 當前選擇的頁面索引：0=聊天, 1=知識庫, 2=設定
@riverpod
class HomePageIndex extends _$HomePageIndex {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

/// 應用首頁
///
/// Flutter 3.38 + Material 3 設計:
/// - 響應式佈局（桌面端使用 NavigationRail，移動端可能使用 NavigationBar）
/// - 平滑的頁面切換動畫
/// - 符合 Material 3 設計規範
///
/// 架構設計:
/// - 左側：導航欄（NavigationRail）
/// - 右側：主要內容區域（PageView 或 IndexedStack）
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 監聽當前選擇的頁面索引
    final selectedIndex = ref.watch(homePageIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          // 左側：導航欄
          _NavigationRailWidget(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              // 更新選擇的頁面
              ref.read(homePageIndexProvider.notifier).setIndex(index);
            },
          ),

          // 分隔線
          const VerticalDivider(thickness: 1, width: 1),

          // 右側：主要內容區域
          Expanded(
            child: _ContentArea(selectedIndex: selectedIndex),
          ),
        ],
      ),
    );
  }
}

/// 導航欄 Widget
///
/// Material 3 NavigationRail:
/// - 用於桌面和平板的側邊導航
/// - 支援圖示和標籤
/// - 支援展開/收合
class _NavigationRailWidget extends StatelessWidget {
  const _NavigationRailWidget({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // 獲取主題顏色
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationRail(
      // 選擇的目的地索引
      selectedIndex: selectedIndex,

      // 點擊事件
      onDestinationSelected: onDestinationSelected,

      // 標籤類型
      // Flutter 3.38: NavigationRail 改進的標籤顯示
      // - all: 總是顯示標籤
      // - selected: 只顯示選中項的標籤
      // - none: 不顯示標籤
      labelType: NavigationRailLabelType.selected,

      // 是否可以展開
      // 當為 true 時，可以點擊頂部按鈕展開導航欄
      extended: false,

      // 前導 Widget（顯示在導航項上方）
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // 應用 Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 28,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            // 應用名稱
            Text(
              'Koopa',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),

      // 導航目的地列表
      destinations: const [
        // 聊天頁面
        NavigationRailDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: Text('聊天'),
        ),

        // 知識庫頁面
        NavigationRailDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: Text('知識庫'),
        ),

        // 設定頁面
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('設定'),
        ),
      ],

      // 尾隨 Widget（顯示在導航項下方）
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // TODO: 顯示說明文檔
                debugPrint('Show help');
              },
              tooltip: '說明',
            ),
          ),
        ),
      ),
    );
  }
}

/// 內容區域 Widget
///
/// 使用 IndexedStack 而不是 PageView:
/// - IndexedStack 保持每個頁面的狀態
/// - 切換頁面時不會重新建構 widget
/// - 適合需要保持狀態的場景
///
/// 如果需要滑動切換，可以改用 PageView
class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    // 使用 AnimatedSwitcher 提供平滑的切換動畫
    //
    // Flutter 3.38: 改進的動畫性能
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),

      // 使用 FadeTransition + SlideTransition 組合
      // 創造更流暢的轉場效果
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubicEmphasized,
            )),
            child: child,
          ),
        );
      },

      // 根據索引顯示不同頁面
      // 使用 ValueKey 確保 AnimatedSwitcher 能正確識別不同頁面
      child: _getPage(selectedIndex),
    );
  }

  /// 根據索引返回對應的頁面 Widget
  Widget _getPage(int index) {
    return switch (index) {
      0 => const ChatPage(key: ValueKey('chat')),
      1 => const KnowledgePage(key: ValueKey('knowledge')),
      2 => const SettingsPage(key: ValueKey('settings')),
      _ => const ChatPage(key: ValueKey('chat')),
    };
  }
}
