import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_highlighter/theme_map.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/constants/design_tokens.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import 'message_action_bar.dart';
import 'source_citation.dart';

/// 訊息列表
///
/// 顯示當前會話的所有訊息
/// 支援：
/// - Markdown 渲染
/// - 程式碼高亮
/// - 自動滾動到最新訊息
/// - 串流訊息的動畫顯示
class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final ScrollController _scrollController = ScrollController();
  List<Message> _previousMessages = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 只在訊息數量變化時滾動 - 避免在每次 build 時都添加 callback
    final messages = ref.read(currentMessagesProvider);
    if (messages.length != _previousMessages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      _previousMessages = List.from(messages);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(currentMessagesProvider);

    // build 方法應該保持純粹 - 不應有副作用

    if (messages.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: DesignTokens.paddingAll16,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(
          key: ValueKey(message.id), // 添加 key 以提升性能和穩定性
          message: message,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: DesignTokens.iconSize3xl,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: DesignTokens.space16),
          Text(
            l10n.chatEmptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            l10n.chatEmptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 訊息氣泡
///
/// 根據訊息類型顯示不同樣式：
/// - 使用者訊息：右側對齊，使用主題色
/// - AI 訊息：左側對齊，使用表面色
/// - 系統訊息：居中顯示
class _MessageBubble extends StatefulWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isHovered = false;

  void _handleAction(MessageAction action) {
    final l10n = AppLocalizations.of(context)!;

    // TODO: 實作各個操作
    switch (action) {
      case MessageAction.copy:
        // 複製功能已在 MessageActionBar 中處理
        break;
      case MessageAction.edit:
        // TODO: 實作編輯功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.chatEditInDevelopment),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
      case MessageAction.regenerate:
        // TODO: 實作重新生成功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.chatRegenerateInDevelopment),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
      case MessageAction.delete:
        // TODO: 實作刪除功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.chatDeleteInDevelopment),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.type == MessageType.user;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.space16),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // AI 頭像（左側）
          if (!isUser) ...[
            _buildAvatar(context, isUser),
            const SizedBox(width: 12),
          ],

          // 訊息內容
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 操作工具列（懸停時顯示在訊息上方）
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _isHovered
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: MessageActionBar(
                            isUser: isUser,
                            message: widget.message.content,
                            onAction: _handleAction,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // 訊息氣泡
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Markdown 內容
                          _buildMessageContent(context, isUser),

                          // 引用來源（如果有）- 使用新的 SourceCitation 元件
                          if (widget.message.citations.isNotEmpty) ...[
                            SourceCitation(
                              sources: widget.message.citations
                                  .asMap()
                                  .entries
                                  .map((entry) => CitationSource(
                                        title: widget.message.citations[entry.key],
                                        snippet: l10n.chatCitationFrom(
                                            widget.message.citations[entry.key]),
                                        icon: Icons.description,
                                      ))
                                  .toList(),
                            ),
                          ],

                          // 串流指示器
                          if (widget.message.isStreaming) ...[
                            const SizedBox(height: 8),
                            _buildStreamingIndicator(context),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 使用者頭像（右側）
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, isUser),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        size: 20,
        color: isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onTertiaryContainer,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MarkdownBody(
      data: widget.message.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: isUser
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
        ),
        code: TextStyle(
          backgroundColor: isDark ? Colors.black26 : Colors.black12,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // 自訂程式碼塊渲染
      builders: {
        'code': _CodeBlockBuilder(isDark: isDark),
      },
    );
  }

  Widget _buildStreamingIndicator(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.chatGenerating,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// 自訂程式碼塊建構器
///
/// 使用 flutter_highlighter 提供語法高亮
class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder({required this.isDark});

  final bool isDark;

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final language = element.attributes['class']?.replaceAll('language-', '') ?? 'plaintext';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 語言標籤
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.black26,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              language,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // 程式碼內容
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              code,
              language: language,
              theme: isDark
                  ? (themeMap['github-dark-dimmed'] ?? themeMap['atom-one-dark'] ?? githubTheme)
                  : githubTheme,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
