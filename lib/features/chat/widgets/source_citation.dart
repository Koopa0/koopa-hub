import 'package:flutter/material.dart';

/// 來源引用數據
class CitationSource {
  const CitationSource({
    required this.title,
    required this.snippet,
    this.icon,
    this.url,
  });

  final String title;
  final String snippet;
  final IconData? icon;
  final String? url;
}

/// 來源引用元件
///
/// 顯示 AI 回應的參考來源，支援懸停預覽
class SourceCitation extends StatelessWidget {
  const SourceCitation({
    required this.sources,
    super.key,
  });

  /// 來源列表
  final List<CitationSource> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Row(
            children: [
              Icon(
                Icons.source_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '參考來源',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 來源列表
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sources.asMap().entries.map((entry) {
              final index = entry.key;
              final source = entry.value;

              return _SourceChip(
                number: index + 1,
                source: source,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 來源標籤
class _SourceChip extends StatefulWidget {
  const _SourceChip({
    required this.number,
    required this.source,
  });

  final int number;
  final CitationSource source;

  @override
  State<_SourceChip> createState() => _SourceChipState();
}

class _SourceChipState extends State<_SourceChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: widget.source.snippet,
      preferBelow: false,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 圖標
              Icon(
                widget.source.icon ?? Icons.description,
                size: 14,
                color: _isHovered
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),

              // 編號
              Text(
                '${widget.number}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isHovered
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),

              // 標題
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  widget.source.title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _isHovered
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
