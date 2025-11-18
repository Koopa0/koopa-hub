import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 鍵盤快捷鍵定義
class AppShortcuts {
  const AppShortcuts._();

  /// Cmd/Ctrl + Enter - 發送訊息
  static const sendMessage = SingleActivator(
    LogicalKeyboardKey.enter,
    meta: true, // macOS Command
    control: true, // Windows/Linux Ctrl
  );

  /// Cmd/Ctrl + N - 新建對話
  static const newChat = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: true,
    control: true,
  );

  /// Cmd/Ctrl + K - 快速搜尋
  static const search = SingleActivator(
    LogicalKeyboardKey.keyK,
    meta: true,
    control: true,
  );

  /// Cmd/Ctrl + , - 開啟設定
  static const settings = SingleActivator(
    LogicalKeyboardKey.comma,
    meta: true,
    control: true,
  );

  /// Cmd/Ctrl + / - 快捷鍵說明
  static const help = SingleActivator(
    LogicalKeyboardKey.slash,
    meta: true,
    control: true,
  );

  /// Cmd/Ctrl + 1-3 - 切換頁面
  static const page1 = SingleActivator(
    LogicalKeyboardKey.digit1,
    meta: true,
    control: true,
  );

  static const page2 = SingleActivator(
    LogicalKeyboardKey.digit2,
    meta: true,
    control: true,
  );

  static const page3 = SingleActivator(
    LogicalKeyboardKey.digit3,
    meta: true,
    control: true,
  );

  /// Esc - 關閉對話框/取消
  static const escape = SingleActivator(LogicalKeyboardKey.escape);
}

/// 快捷鍵說明對話框
class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    final modifier = isMac ? '⌘' : 'Ctrl';

    return AlertDialog(
      title: const Text('鍵盤快捷鍵'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShortcutItem(
              keys: '$modifier + Enter',
              description: '發送訊息',
            ),
            _ShortcutItem(
              keys: '$modifier + N',
              description: '新建對話',
            ),
            _ShortcutItem(
              keys: '$modifier + K',
              description: '快速搜尋',
            ),
            _ShortcutItem(
              keys: '$modifier + ,',
              description: '開啟設定',
            ),
            _ShortcutItem(
              keys: '$modifier + /',
              description: '顯示此說明',
            ),
            _ShortcutItem(
              keys: '$modifier + 1-3',
              description: '切換頁面',
            ),
            _ShortcutItem(
              keys: 'Esc',
              description: '關閉對話框',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('關閉'),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ShortcutsHelpDialog(),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.keys,
    required this.description,
  });

  final String keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              keys,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
