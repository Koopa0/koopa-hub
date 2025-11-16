import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/chat_session.dart';
import '../providers/chat_provider.dart';
import '../../../core/constants/app_constants.dart';

/// 會話列表側邊欄
///
/// 顯示所有聊天會話，支援：
/// - 建立新會話
/// - 切換會話
/// - 刪除會話
/// - 置頂會話
class SessionSidebar extends ConsumerWidget {
  const SessionSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);
    final currentSessionId = ref.watch(currentSessionIdProvider);

    return Container(
      width: AppConstants.sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 頂部工具欄
          _buildHeader(context, ref),

          const Divider(height: 1),

          // 會話列表
          Expanded(
            child: sessions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isSelected = session.id == currentSessionId;

                      return _SessionTile(
                        session: session,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(currentSessionIdProvider.notifier)
                              .setSessionId(session.id);
                        },
                        onDelete: () {
                          ref
                              .read(chatSessionsProvider.notifier)
                              .deleteSession(session.id);
                        },
                        onTogglePin: () {
                          ref
                              .read(chatSessionsProvider.notifier)
                              .toggleSessionPin(session.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            ref.read(chatSessionsProvider.notifier).createSession();
          },
          icon: const Icon(Icons.add),
          label: const Text('新對話'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '還沒有任何對話\n點擊上方按鈕開始',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

/// 會話列表項
///
/// 使用 StatelessWidget 避免不必要的重建
class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
  });

  final ChatSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? colorScheme.secondaryContainer.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題行
                Row(
                  children: [
                    // 置頂圖示
                    if (session.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],

                    // 標題
                    Expanded(
                      child: Text(
                        session.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 更多選單
                    _buildPopupMenu(context),
                  ],
                ),

                const SizedBox(height: 4),

                // 最後訊息預覽
                Text(
                  session.lastMessagePreview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // 時間和訊息數量
                Row(
                  children: [
                    Text(
                      _formatTime(session.updatedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (session.messageCount > 0)
                      Text(
                        '${session.messageCount} 則訊息',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(session.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              const SizedBox(width: 12),
              Text(session.isPinned ? '取消置頂' : '置頂'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 12),
              Text('刪除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onTogglePin();
            break;
          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除對話'),
        content: const Text('確定要刪除這個對話嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  /// 格式化時間顯示
  ///
  /// - 今天：顯示時間 (例如：14:30)
  /// - 昨天：顯示「昨天」
  /// - 其他：顯示日期 (例如：1/15)
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (date == yesterday) {
      return '昨天';
    } else {
      return DateFormat('M/d').format(dateTime);
    }
  }
}
