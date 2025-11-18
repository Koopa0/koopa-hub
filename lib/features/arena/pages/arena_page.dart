import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/message.dart';
import '../../chat/models/chat_session.dart';

/// Arena 模式頁面
///
/// 多模型並排對比功能
/// 同時向多個 AI 模型發送相同問題，對比回答
class ArenaPage extends ConsumerStatefulWidget {
  const ArenaPage({super.key});

  @override
  ConsumerState<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends ConsumerState<ArenaPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<AIModel> _selectedModels = [
    AIModel.localRag,
    AIModel.gemini,
  ];
  final Map<AIModel, List<Message>> _modelResponses = {};
  bool _isGenerating = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // 模型選擇欄
          _buildModelSelector(theme),

          // 對比視圖
          Expanded(
            child: _buildComparisonView(theme),
          ),

          // 輸入欄
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildModelSelector(ThemeData theme) {
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
          const Icon(Icons.compare_arrows),
          const SizedBox(width: 12),
          Text(
            '對比模型',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: AIModel.values.map((model) {
                final isSelected = _selectedModels.contains(model);
                return FilterChip(
                  label: Text(model.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedModels.length < 3) {
                          _selectedModels.add(model);
                        }
                      } else {
                        if (_selectedModels.length > 1) {
                          _selectedModels.remove(model);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(ThemeData theme) {
    if (_selectedModels.isEmpty) {
      return Center(
        child: Text(
          '請選擇至少一個模型',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Row(
      children: _selectedModels.map((model) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 模型標題
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        model.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 訊息列表
                Expanded(
                  child: _buildModelMessages(model, theme),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModelMessages(AIModel model, ThemeData theme) {
    final messages = _modelResponses[model] ?? [];

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '尚無對話',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.type == MessageType.user;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (message.isStreaming) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '生成中...',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: '輸入訊息，同時向 ${_selectedModels.length} 個模型發送...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              enabled: !_isGenerating,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isGenerating ? null : _sendMessage,
            child: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isGenerating) return;

    setState(() {
      _isGenerating = true;
      _inputController.clear();

      // 為每個模型添加用戶訊息
      for (final model in _selectedModels) {
        _modelResponses.putIfAbsent(model, () => []);
        _modelResponses[model]!.add(Message.user(content));
      }
    });

    // 並行生成回應
    await Future.wait(
      _selectedModels.map((model) => _generateResponse(model, content)),
    );

    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _generateResponse(AIModel model, String userMessage) async {
    // 添加一個空的 AI 訊息
    final aiMessage = Message.assistant('', isStreaming: true);
    setState(() {
      _modelResponses[model]!.add(aiMessage);
    });

    // 模擬流式響應
    final responses = {
      AIModel.localRag:
          '【本地 RAG】根據你的知識庫，$userMessage 的答案是：這是一個基於向量檢索的回答，從本地文件中提取相關信息。',
      AIModel.webSearch:
          '【網路搜索】根據最新網路資訊，$userMessage 的答案是：這是基於實時網路搜索的結果，包含最新信息。',
      AIModel.gemini:
          '【Gemini】$userMessage 是一個很好的問題。作為 Google Gemini 模型，我可以提供詳細的分析和解答。',
    };

    final fullResponse = responses[model] ?? '這是 $model 的回應';
    final words = fullResponse.split(' ');

    String accumulated = '';
    for (final word in words) {
      accumulated += (accumulated.isEmpty ? '' : ' ') + word;

      setState(() {
        final index = _modelResponses[model]!
            .indexWhere((m) => m.id == aiMessage.id);
        if (index != -1) {
          _modelResponses[model]![index] = aiMessage.copyWith(
            content: accumulated,
            isStreaming: true,
          );
        }
      });

      await Future.delayed(const Duration(milliseconds: 50));
    }

    // 完成
    setState(() {
      final index =
          _modelResponses[model]!.indexWhere((m) => m.id == aiMessage.id);
      if (index != -1) {
        _modelResponses[model]![index] = aiMessage.copyWith(
          content: fullResponse,
          isStreaming: false,
        );
      }
    });
  }
}
