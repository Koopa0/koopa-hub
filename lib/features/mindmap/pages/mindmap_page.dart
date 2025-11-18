import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mind Map 模式頁面
///
/// 提供思維導圖功能
/// 幫助用戶組織想法和知識結構
class MindMapPage extends ConsumerStatefulWidget {
  const MindMapPage({super.key});

  @override
  ConsumerState<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends ConsumerState<MindMapPage> {
  final List<MindMapNode> _nodes = [];
  MindMapNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    // 添加根節點
    _nodes.add(MindMapNode(
      id: '0',
      title: '中心主題',
      position: const Offset(400, 300),
      level: 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          // Mind Map 畫布
          GestureDetector(
            onTapDown: (details) {
              // 檢查是否點擊了節點
              final clickedNode = _findNodeAtPosition(details.localPosition);
              setState(() {
                _selectedNode = clickedNode;
              });
            },
            child: CustomPaint(
              painter: _MindMapPainter(_nodes, _selectedNode),
              child: Container(),
            ),
          ),

          // 工具欄
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildToolbar(theme),
          ),

          // 節點屬性面板
          if (_selectedNode != null)
            Positioned(
              top: 80,
              right: 16,
              child: _buildNodeProperties(theme),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: _selectedNode != null ? _addChildNode : null,
            icon: const Icon(Icons.add),
            label: const Text('添加子節點'),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: _selectedNode != null ? _deleteNode : null,
            icon: const Icon(Icons.delete_outline),
            label: const Text('刪除節點'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _nodes.clear();
                _nodes.add(MindMapNode(
                  id: '0',
                  title: '中心主題',
                  position: const Offset(400, 300),
                  level: 0,
                ));
                _selectedNode = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeProperties(ThemeData theme) {
    if (_selectedNode == null) return const SizedBox.shrink();

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '節點屬性',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: '標題',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: _selectedNode!.title),
            onChanged: (value) {
              setState(() {
                _selectedNode = _selectedNode!.copyWith(title: value);
                final index = _nodes.indexWhere((n) => n.id == _selectedNode!.id);
                if (index != -1) {
                  _nodes[index] = _selectedNode!;
                }
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('顏色'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Colors.blue,
              Colors.green,
              Colors.red,
              Colors.orange,
              Colors.purple,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNode = _selectedNode!.copyWith(color: color);
                    final index =
                        _nodes.indexWhere((n) => n.id == _selectedNode!.id);
                    if (index != -1) {
                      _nodes[index] = _selectedNode!;
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedNode!.color == color
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addChildNode() {
    if (_selectedNode == null) return;

    final newNode = MindMapNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新節點',
      parentId: _selectedNode!.id,
      position: Offset(
        _selectedNode!.position.dx + 150,
        _selectedNode!.position.dy + 80,
      ),
      level: _selectedNode!.level + 1,
    );

    setState(() {
      _nodes.add(newNode);
    });
  }

  void _deleteNode() {
    if (_selectedNode == null || _selectedNode!.id == '0') return;

    setState(() {
      // 刪除所有子節點
      _nodes.removeWhere((node) => _isDescendant(node, _selectedNode!));
      // 刪除選中節點
      _nodes.removeWhere((node) => node.id == _selectedNode!.id);
      _selectedNode = null;
    });
  }

  bool _isDescendant(MindMapNode node, MindMapNode ancestor) {
    if (node.parentId == ancestor.id) return true;
    final parent = _nodes.where((n) => n.id == node.parentId).firstOrNull;
    if (parent == null) return false;
    return _isDescendant(parent, ancestor);
  }

  MindMapNode? _findNodeAtPosition(Offset position) {
    for (final node in _nodes.reversed) {
      final distance = (node.position - position).distance;
      if (distance < 50) return node;
    }
    return null;
  }
}

/// Mind Map 節點模型
class MindMapNode {
  final String id;
  final String title;
  final String? parentId;
  final Offset position;
  final int level;
  final Color color;

  MindMapNode({
    required this.id,
    required this.title,
    this.parentId,
    required this.position,
    required this.level,
    this.color = Colors.blue,
  });

  MindMapNode copyWith({
    String? title,
    Offset? position,
    Color? color,
  }) {
    return MindMapNode(
      id: id,
      title: title ?? this.title,
      parentId: parentId,
      position: position ?? this.position,
      level: level,
      color: color ?? this.color,
    );
  }
}

/// Mind Map 畫家
class _MindMapPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final MindMapNode? selectedNode;

  _MindMapPainter(this.nodes, this.selectedNode);

  @override
  void paint(Canvas canvas, Size size) {
    // 繪製連接線
    for (final node in nodes) {
      if (node.parentId != null) {
        final parent = nodes.where((n) => n.id == node.parentId).firstOrNull;
        if (parent != null) {
          final paint = Paint()
            ..color = Colors.grey.withOpacity(0.5)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

          canvas.drawLine(parent.position, node.position, paint);
        }
      }
    }

    // 繪製節點
    for (final node in nodes) {
      final isSelected = node.id == selectedNode?.id;

      // 節點圓形
      final paint = Paint()
        ..color = node.color.withOpacity(isSelected ? 1.0 : 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(node.position, 50, paint);

      // 選中邊框
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(node.position, 50, borderPaint);
      }

      // 文字
      final textSpan = TextSpan(
        text: node.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 90);

      textPainter.paint(
        canvas,
        node.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
