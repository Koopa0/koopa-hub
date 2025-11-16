import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 訊息操作類型
enum MessageAction {
  copy,       // 複製
  edit,       // 編輯
  regenerate, // 重新生成
  delete,     // 刪除
}

/// 訊息操作工具列
///
/// 顯示在訊息上，提供快速操作按鈕
class MessageActionBar extends StatelessWidget {
  const MessageActionBar({
    required this.isUser,
    required this.message,
    this.onAction,
    super.key,
  });

  /// 是否為使用者訊息
  final bool isUser;

  /// 訊息內容
  final String message;

  /// 操作回調
  final void Function(MessageAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 複製按鈕
          _ActionButton(
            icon: Icons.content_copy,
            tooltip: '複製',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已複製到剪貼簿'),
                  duration: Duration(seconds: 1),
                ),
              );
              onAction?.call(MessageAction.copy);
            },
          ),

          // 使用者訊息：編輯按鈕
          if (isUser) ...[
            const SizedBox(width: 4),
            _ActionButton(
              icon: Icons.edit_outlined,
              tooltip: '編輯',
              onPressed: () => onAction?.call(MessageAction.edit),
            ),
          ],

          // AI 訊息：重新生成按鈕
          if (!isUser) ...[
            const SizedBox(width: 4),
            _ActionButton(
              icon: Icons.refresh,
              tooltip: '重新生成',
              onPressed: () => onAction?.call(MessageAction.regenerate),
            ),
          ],

          // 刪除按鈕
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.delete_outline,
            tooltip: '刪除',
            iconColor: colorScheme.error,
            onPressed: () => onAction?.call(MessageAction.delete),
          ),
        ],
      ),
    );
  }
}

/// 操作按鈕
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
