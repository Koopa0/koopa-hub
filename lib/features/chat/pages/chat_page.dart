import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/session_sidebar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_selector.dart';

/// 聊天頁面
///
/// 主要組件：
/// - 左側：會話列表側邊欄
/// - 中間：訊息顯示區域
/// - 底部：輸入框
/// - 頂部：AI 模型選擇器
class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(currentSessionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          // 會話列表側邊欄
          const SessionSidebar(),

          const VerticalDivider(thickness: 1, width: 1),

          // 主要聊天區域
          Expanded(
            child: currentSession == null
                ? const _EmptyState()
                : const _ChatArea(),
          ),
        ],
      ),
    );
  }
}

/// 空狀態（沒有選擇會話時顯示）
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          Text(
            '開始新對話',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '選擇或建立一個會話開始聊天',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 聊天區域（包含訊息列表和輸入框）
class _ChatArea extends StatelessWidget {
  const _ChatArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 頂部工具欄（包含 AI 模型選擇器）
        const _TopBar(),

        const Divider(height: 1),

        // 訊息列表
        const Expanded(
          child: MessageList(),
        ),

        const Divider(height: 1),

        // 輸入框
        const ChatInput(),
      ],
    );
  }
}

/// 頂部工具欄
class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 會話標題
          Expanded(
            child: Text(
              session?.title ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // AI 模型選擇器
          const ModelSelector(),

          const SizedBox(width: 8),

          // 清除對話按鈕
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (session != null) {
                ref
                    .read(chatSessionsProvider.notifier)
                    .clearSessionMessages(session.id);
              }
            },
            tooltip: '清除對話',
          ),
        ],
      ),
    );
  }
}
