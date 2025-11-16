import 'package:flutter/material.dart';

/// 確認對話框元件
///
/// 統一的確認對話框樣式，支援自訂圖標、顏色和操作
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.confirmText = '確認',
    this.cancelText = '取消',
    this.isDestructive = false,
    super.key,
  });

  /// 標題
  final String title;

  /// 訊息內容
  final String message;

  /// 圖標（可選）
  final IconData? icon;

  /// 圖標顏色（可選）
  final Color? iconColor;

  /// 確認按鈕文字
  final String confirmText;

  /// 取消按鈕文字
  final String cancelText;

  /// 是否為危險操作（刪除等）
  final bool isDestructive;

  /// 顯示對話框的靜態方法
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String confirmText = '確認',
    String cancelText = '取消',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              color: iconColor ??
                  (isDestructive ? colorScheme.error : colorScheme.primary),
              size: 32,
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        // 取消按鈕
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),

        // 確認按鈕
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
