import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canvas 模式頁面
///
/// 提供自由繪圖和筆記功能
/// 類似於 Miro、Figma 的無限畫布
class CanvasPage extends ConsumerStatefulWidget {
  const CanvasPage({super.key});

  @override
  ConsumerState<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends ConsumerState<CanvasPage> {
  final List<DrawingPoint> _points = [];
  DrawingMode _mode = DrawingMode.draw;
  Color _currentColor = Colors.black;
  double _strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // 工具欄
          _buildToolbar(theme),

          // 畫布區域
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                if (_mode == DrawingMode.erase) {
                  setState(() {
                    _points.add(DrawingPoint(
                      details.localPosition,
                      Colors.transparent,
                      _strokeWidth * 3,
                    ));
                  });
                } else {
                  setState(() {
                    _points.add(DrawingPoint(
                      details.localPosition,
                      _currentColor,
                      _strokeWidth,
                    ));
                  });
                }
              },
              onPanUpdate: (details) {
                setState(() {
                  if (_mode == DrawingMode.erase) {
                    _points.add(DrawingPoint(
                      details.localPosition,
                      Colors.transparent,
                      _strokeWidth * 3,
                    ));
                  } else {
                    _points.add(DrawingPoint(
                      details.localPosition,
                      _currentColor,
                      _strokeWidth,
                    ));
                  }
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _points.add(DrawingPoint.end());
                });
              },
              child: CustomPaint(
                painter: _CanvasPainter(_points),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 繪圖模式
          SegmentedButton<DrawingMode>(
            segments: const [
              ButtonSegment(
                value: DrawingMode.draw,
                icon: Icon(Icons.edit),
                label: Text('繪圖'),
              ),
              ButtonSegment(
                value: DrawingMode.text,
                icon: Icon(Icons.text_fields),
                label: Text('文字'),
              ),
              ButtonSegment(
                value: DrawingMode.erase,
                icon: Icon(Icons.auto_fix_high),
                label: Text('橡皮擦'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<DrawingMode> newSelection) {
              setState(() {
                _mode = newSelection.first;
              });
            },
          ),

          const SizedBox(width: 16),

          // 顏色選擇
          if (_mode == DrawingMode.draw) ...[
            const Text('顏色: '),
            const SizedBox(width: 8),
            ...[
              Colors.black,
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
            ].map((color) {
              return GestureDetector(
                onTap: () => setState(() => _currentColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentColor == color
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(width: 16),

            // 筆刷大小
            const Text('筆刷: '),
            SizedBox(
              width: 150,
              child: Slider(
                value: _strokeWidth,
                min: 1,
                max: 20,
                divisions: 19,
                label: _strokeWidth.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _strokeWidth = value;
                  });
                },
              ),
            ),
          ],

          const Spacer(),

          // 清除按鈕
          FilledButton.tonal(
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
            child: const Text('清除畫布'),
          ),
        ],
      ),
    );
  }
}

/// 繪圖模式
enum DrawingMode {
  draw,
  text,
  erase,
}

/// 繪圖點
class DrawingPoint {
  final Offset? offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint(this.offset, this.color, this.strokeWidth);

  DrawingPoint.end()
      : offset = null,
        color = Colors.transparent,
        strokeWidth = 0;
}

/// Canvas 畫家
class _CanvasPainter extends CustomPainter {
  final List<DrawingPoint> points;

  _CanvasPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].strokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = points[i].color == Colors.transparent
              ? BlendMode.clear
              : BlendMode.srcOver;

        canvas.drawLine(points[i].offset!, points[i + 1].offset!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
