import 'package:flutter/material.dart';

/// Thinking step data model
class ThinkingStep {
  final String title;
  final String? description;
  final ThinkingStepStatus status;
  final DateTime timestamp;

  const ThinkingStep({
    required this.title,
    this.description,
    required this.status,
    required this.timestamp,
  });

  ThinkingStep copyWith({
    String? title,
    String? description,
    ThinkingStepStatus? status,
    DateTime? timestamp,
  }) {
    return ThinkingStep(
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

enum ThinkingStepStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Widget to display AI thinking process
/// Inspired by Claude and Perplexity's thinking indicators
class ThinkingStepsWidget extends StatelessWidget {
  const ThinkingStepsWidget({
    super.key,
    required this.steps,
    this.isExpanded = true,
  });

  final List<ThinkingStep> steps;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (steps.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thinking',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // Active indicator
                if (_hasActiveStep)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1),
            // Steps list
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((step) => _buildStep(context, step)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActiveStep =>
      steps.any((s) => s.status == ThinkingStepStatus.inProgress);

  Widget _buildStep(BuildContext context, ThinkingStep step) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          _buildStatusIcon(theme, step.status),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(theme, step.status),
                  ),
                ),
                if (step.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme, ThinkingStepStatus status) {
    return switch (status) {
      ThinkingStepStatus.pending => Icon(
          Icons.radio_button_unchecked,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ThinkingStepStatus.inProgress => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ThinkingStepStatus.completed => Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green.shade600,
        ),
      ThinkingStepStatus.failed => Icon(
          Icons.error,
          size: 16,
          color: Colors.red.shade600,
        ),
    };
  }

  Color _getTextColor(ThemeData theme, ThinkingStepStatus status) {
    return switch (status) {
      ThinkingStepStatus.pending =>
        theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
      ThinkingStepStatus.inProgress => theme.colorScheme.primary,
      ThinkingStepStatus.completed => theme.colorScheme.onSurface,
      ThinkingStepStatus.failed => Colors.red.shade600,
    };
  }
}
