import 'package:flutter/material.dart';

/// AI 思考進度狀態
enum ThinkingStatus {
  searching,   // 搜尋中
  analyzing,   // 分析中
  generating,  // 生成中
  completed,   // 完成
}

/// AI 思考步驟
class ThinkingStep {
  const ThinkingStep({
    required this.title,
    required this.status,
    this.description,
  });

  final String title;
  final ThinkingStatus status;
  final String? description;
}

/// AI 思考進度指示器
///
/// 顯示 AI 當前執行的步驟，參考 Perplexity 設計
class ThinkingIndicator extends StatelessWidget {
  const ThinkingIndicator({
    required this.steps,
    this.currentStep = 0,
    super.key,
  });

  /// 思考步驟列表
  final List<ThinkingStep> steps;

  /// 當前步驟索引
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 標題
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '思考中...',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 步驟列表
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StepItem(
                step: step,
                isActive: isActive,
                isCompleted: isCompleted,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 步驟項目
class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.step,
    required this.isActive,
    required this.isCompleted,
  });

  final ThinkingStep step;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getColor() {
      if (isCompleted) return colorScheme.primary;
      if (isActive) return colorScheme.secondary;
      return colorScheme.onSurfaceVariant.withOpacity(0.5);
    }

    IconData getIcon() {
      if (isCompleted) return Icons.check_circle;
      if (isActive) return Icons.radio_button_checked;
      return Icons.radio_button_unchecked;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 狀態圖標
        Icon(
          getIcon(),
          size: 16,
          color: getColor(),
        ),
        const SizedBox(width: 8),

        // 步驟內容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: getColor(),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (step.description != null && isActive) ...[
                const SizedBox(height: 2),
                Text(
                  step.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
