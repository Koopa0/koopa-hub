import 'package:flutter/material.dart';

/// 帶縮放動畫的按鈕包裝器
///
/// 提供按壓時的縮放反饋，提升互動體驗
class AnimatedScaleButton extends StatefulWidget {
  const AnimatedScaleButton({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    super.key,
  });

  /// 子 Widget
  final Widget child;

  /// 點擊回調
  final VoidCallback? onTap;

  /// 長按回調
  final VoidCallback? onLongPress;

  /// 縮放比例（0.0 - 1.0）
  final double scale;

  /// 動畫持續時間
  final Duration duration;

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
