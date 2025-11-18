import 'package:flutter/material.dart';

/// 載入指示器類型
enum LoadingIndicatorType {
  circular,  // 圓形 Spinner
  linear,    // 線性進度條
  shimmer,   // 骨架屏效果
}

/// 載入指示器元件
///
/// 提供多種載入樣式，適用於不同場景
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.type = LoadingIndicatorType.circular,
    this.message,
    this.progress,
    super.key,
  });

  /// 載入類型
  final LoadingIndicatorType type;

  /// 載入訊息
  final String? message;

  /// 進度（0.0 - 1.0），null 為不確定進度
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 載入指示器
          _buildIndicator(colorScheme),

          // 載入訊息
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // 進度文字
          if (progress != null) ...[
            const SizedBox(height: 8),
            Text(
              '${(progress! * 100).toInt()}%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(ColorScheme colorScheme) {
    switch (type) {
      case LoadingIndicatorType.circular:
        return SizedBox(
          width: 48,
          height: 48,
          child: progress != null
              ? CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                )
              : const CircularProgressIndicator(
                  strokeWidth: 4,
                ),
        );

      case LoadingIndicatorType.linear:
        return SizedBox(
          width: 240,
          child: progress != null
              ? LinearProgressIndicator(value: progress)
              : const LinearProgressIndicator(),
        );

      case LoadingIndicatorType.shimmer:
        return const _ShimmerLoading();
    }
  }
}

/// 骨架屏載入效果
class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading();

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.surfaceContainerHighest,
                colorScheme.surfaceContainerHigh,
                colorScheme.surfaceContainerHighest,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
