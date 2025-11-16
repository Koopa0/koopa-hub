import 'package:flutter/material.dart';

/// 錯誤顯示元件
///
/// 用於統一顯示錯誤訊息，支援重試操作
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.title = '發生錯誤',
    this.onRetry,
    this.retryLabel = '重試',
    super.key,
  });

  /// 錯誤標題
  final String title;

  /// 錯誤訊息
  final String message;

  /// 重試回調
  final VoidCallback? onRetry;

  /// 重試按鈕文字
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 錯誤圖標
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // 錯誤標題
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 錯誤訊息
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 5,
            ),

            // 重試按鈕
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
