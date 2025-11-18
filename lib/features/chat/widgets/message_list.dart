import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart' show githubTheme;
import 'package:flutter_highlighter/themes/dark.dart' show darkTheme;
import 'package:markdown/markdown.dart' as md;

import '../../../core/constants/design_tokens.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import 'message_action_bar.dart';
import 'source_citation.dart';
import 'thinking_steps.dart';
import 'tool_calling.dart';
import 'source_card.dart';
import 'artifact_viewer.dart';

/// Message List - Scrollable conversation display
///
/// **Purpose:**
/// Displays all messages in the current chat session with support for:
/// - Rich Markdown rendering (bold, italic, links, lists, etc.)
/// - Syntax-highlighted code blocks
/// - Auto-scroll to latest message
/// - Animated streaming indicators for real-time AI responses
/// - Source citations for RAG-based answers
///
/// **Flutter 3.38 Features Used:**
/// - Material 3 ColorScheme tokens (primaryContainer, surfaceContainerHighest)
/// - Updated ScrollController with better physics
/// - Improved ListView.builder performance
///
/// **Dart 3.10 Best Practices:**
/// - ConsumerStatefulWidget for state + reactive data
/// - Proper resource disposal pattern
/// - Const constructors where possible
///
/// **Third-Party Packages:**
/// - flutter_markdown: Renders markdown content
/// - flutter_highlighter: Syntax highlighting for code
/// - markdown: Core markdown parsing
///
/// **Performance Optimizations:**
/// - ListView.builder: Only builds visible items
/// - Flexible widgets prevent layout overflow
/// - Const constructors reduce rebuilds
class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  /// Scroll controller for message list
  ///
  /// **Why we need this:**
  /// - Auto-scroll to bottom when new messages arrive
  /// - Allows programmatic scroll control
  /// - Monitors scroll position for features like "scroll to top" button
  ///
  /// **Important:** Must be disposed to prevent memory leaks
  /// ScrollController holds native platform resources
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    /// Critical: Clean up scroll controller
    ///
    /// **What happens if we don't dispose:**
    /// - Memory leak (controller holds references)
    /// - Native resource leak (platform scroll view)
    /// - Potential crashes on hot reload
    ///
    /// **Flutter Best Practice:**
    /// Always dispose controllers in reverse order of creation
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch messages - rebuilds when message list changes
    final messages = ref.watch(currentMessagesProvider);

    /// Auto-scroll to bottom when messages change
    ///
    /// **Riverpod Pattern - ref.listen:**
    /// Only executes callback when the provider value actually changes.
    /// More efficient than addPostFrameCallback in every build.
    ///
    /// **Why This Pattern:**
    /// - Only scrolls when messages list changes (not on every rebuild)
    /// - Prevents unnecessary callback registrations
    /// - Better performance for complex UIs
    ///
    /// **Flutter 3.38:**
    /// Frame callbacks are now more efficient with improved scheduling
    ///
    /// **Performance Benefit:**
    /// Previous pattern called addPostFrameCallback on every build.
    /// This pattern only triggers when messages actually change.
    ref.listen(currentMessagesProvider, (previous, next) {
      // Only scroll if message count changed (new message added)
      if (previous?.length != next.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check if controller is attached to a scroll view
          // Prevents crashes during widget disposal or initial build
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              // maxScrollExtent: Bottom of scrollable area
              _scrollController.position.maxScrollExtent,

              // Smooth animation duration
              duration: const Duration(milliseconds: 300),

              // easeOut: Fast start, slow end (feels natural)
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    // Empty state when no messages
    if (messages.isEmpty) {
      return _buildEmptyState(context);
    }

    /// ListView.builder for efficient scrolling
    ///
    /// **Performance Benefits:**
    /// - Only builds visible + nearby items (viewport optimization)
    /// - Reuses widgets as user scrolls (widget recycling)
    /// - Efficient for lists of any size (even thousands of messages)
    ///
    /// **Flutter 3.38 Improvements:**
    /// - Better scroll physics matching Material 3
    /// - Improved over-scroll effects
    /// - Faster item builder callbacks
    return ListView.builder(
      controller: _scrollController,

      // Padding around entire list
      // Creates breathing room from screen edges
      padding: const EdgeInsets.all(16),

      itemCount: messages.length,

      /// Item Builder
      ///
      /// **Called for each visible item:**
      /// - index: Position in list (0 to itemCount-1)
      /// - context: Build context for this item
      ///
      /// **Best Practice:**
      /// Extract complex items into separate widgets (_MessageBubble)
      /// This improves readability and enables widget reuse
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(
          key: ValueKey(message.id), // 添加 key 以提升性能和穩定性
          message: message,
        );
      },
    );
  }

  /// Build empty state view
  ///
  /// **UX Pattern:**
  /// Empty states should:
  /// - Explain why it's empty
  /// - Guide user to first action
  /// - Use friendly, encouraging tone
  ///
  /// **Material 3 Design:**
  /// - Centered content for focus
  /// - Icon + headline + body text hierarchy
  /// - De-emphasized colors (onSurfaceVariant)
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large icon as visual anchor
          Icon(
            Icons.chat,
            size: 64,
            // outlineVariant: Subtle, decorative color
            color: theme.colorScheme.outlineVariant,
          ),

          const SizedBox(height: 16),

          // Headline text
          Text(
            'Start Chatting',
            style: theme.textTheme.titleMedium?.copyWith(
              // onSurfaceVariant: Lower emphasis than primary text
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // Instructional body text
          Text(
            'Type a message below to begin the conversation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Message Bubble - Individual message display
///
/// **Design Patterns:**
/// Different styling based on message type:
/// - User messages: Right-aligned, primary color, user avatar
/// - AI messages: Left-aligned, surface color, AI avatar
/// - System messages: Center-aligned (not implemented yet)
///
/// **Material 3 Features:**
/// - primaryContainer for user messages (accessible contrast)
/// - surfaceContainerHighest for AI messages (elevated surface)
/// - tertiaryContainer for AI avatar (semantic color)
///
/// **Flutter Best Practice:**
/// StatefulWidget to manage hover state for action buttons.
/// Uses local state for UI interactions while parent manages data.
class _MessageBubble extends StatefulWidget {
  const _MessageBubble({super.key, required this.message});

  final Message message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isHovered = false;

  void _handleAction(MessageAction action) {
    switch (action) {
      case MessageAction.copy:
        // 複製功能已在 MessageActionBar 中處理
        break;

      case MessageAction.edit:
        _handleEdit();
        break;

      case MessageAction.regenerate:
        _handleRegenerate();
        break;

      case MessageAction.delete:
        _handleDelete();
        break;
    }
  }

  /// 處理編輯訊息
  void _handleEdit() {
    if (widget.message.type != MessageType.user) return;

    // 顯示編輯對話框
    showDialog(
      context: context,
      builder: (context) => _EditMessageDialog(
        initialContent: widget.message.content,
        onSave: (newContent) {
          // 更新訊息內容
          final updatedMessage = widget.message.copyWith(content: newContent);
          _updateMessageInSession(updatedMessage);
        },
      ),
    );
  }

  /// 處理重新生成
  void _handleRegenerate() async {
    if (widget.message.type != MessageType.assistant) return;

    final ref = ProviderScope.containerOf(context).read;
    final sessionId = ref(currentSessionIdProvider);
    if (sessionId == null) return;

    final session = ref(chatSessionsProvider.notifier).getSession(sessionId);
    if (session == null) return;

    // 找到這條 AI 訊息之前的使用者訊息
    final messageIndex = session.messages.indexOf(widget.message);
    if (messageIndex <= 0) return;

    String? userMessageContent;
    for (int i = messageIndex - 1; i >= 0; i--) {
      if (session.messages[i].type == MessageType.user) {
        userMessageContent = session.messages[i].content;
        break;
      }
    }

    if (userMessageContent == null) return;

    // 刪除當前 AI 訊息
    final updatedMessages = session.messages
        .where((m) => m.id != widget.message.id)
        .toList();
    ref(chatSessionsProvider.notifier).updateSession(
      session.copyWith(messages: updatedMessages),
    );

    // 重新發送請求
    await ref(chatServiceProvider.notifier).sendMessage(userMessageContent);
  }

  /// 處理刪除訊息
  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除訊息'),
        content: const Text('確定要刪除這條訊息嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessageFromSession();
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  /// 更新會話中的訊息
  void _updateMessageInSession(Message updatedMessage) {
    final ref = ProviderScope.containerOf(context).read;
    final sessionId = ref(currentSessionIdProvider);
    if (sessionId == null) return;

    final session = ref(chatSessionsProvider.notifier).getSession(sessionId);
    if (session == null) return;

    final updatedMessages = session.messages.map((m) {
      return m.id == updatedMessage.id ? updatedMessage : m;
    }).toList();

    ref(chatSessionsProvider.notifier).updateSession(
      session.copyWith(messages: updatedMessages),
    );
  }

  /// 從會話中刪除訊息
  void _deleteMessageFromSession() {
    final ref = ProviderScope.containerOf(context).read;
    final sessionId = ref(currentSessionIdProvider);
    if (sessionId == null) return;

    final session = ref(chatSessionsProvider.notifier).getSession(sessionId);
    if (session == null) return;

    final updatedMessages = session.messages
        .where((m) => m.id != widget.message.id)
        .toList();

    ref(chatSessionsProvider.notifier).updateSession(
      session.copyWith(messages: updatedMessages),
    );
  }

  /// 顯示 Artifact 檢視器
  ///
  /// 使用側邊欄顯示 Artifact（類似 Claude Web）
  /// 而非 Dialog 彈窗
  void _showArtifactViewer(BuildContext context) {
    if (widget.message.artifact == null) return;

    // 使用 provider 在側邊欄顯示 Artifact
    ref.read(artifactSidebarProvider.notifier).showArtifact(
          widget.message.artifact!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.type == MessageType.user;

    return Padding(
      // Bottom padding creates spacing between messages
      padding: const EdgeInsets.only(bottom: 16),

      /// Row Layout
      ///
      /// **Alignment:**
      /// - User: Right-aligned (MainAxisAlignment.end)
      /// - AI: Left-aligned (MainAxisAlignment.start)
      ///
      /// **CrossAxisAlignment.start:**
      /// Aligns avatar to top of message bubble
      /// Important for multi-line messages
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// AI Avatar (Left Side)
          ///
          /// **Dart 3.0 Spread Operator:**
          /// Using ...[] to conditionally add multiple widgets
          /// Cleaner than if/else with separate Row children
          if (!isUser) ...[
            _buildAvatar(context, isUser),
            const SizedBox(width: 12), // Spacing between avatar and bubble
          ],

          /// Message Content Bubble
          ///
          /// **Flexible vs Expanded:**
          /// - Flexible: Takes needed space, up to maximum
          /// - Expanded: Always takes all available space
          ///
          /// We use Flexible so messages don't stretch unnecessarily
          Flexible(
            child: Container(
              /// Max width constraint
              ///
              /// **Why 600px:**
              /// - Improves readability (optimal line length: 50-75 chars)
              /// - Prevents messages from spanning entire screen on desktop
              /// - Matches design patterns from Gemini, ChatGPT, etc.
              constraints: const BoxConstraints(maxWidth: 600),

              // Internal padding
              padding: const EdgeInsets.all(16),

              /// Material 3: Container Background Colors
              ///
              /// **User Messages (primaryContainer):**
              /// - Filled background with primary color
              /// - High contrast for text (onPrimaryContainer)
              /// - Visually distinct as "my" messages
              ///
              /// **AI Messages (surfaceContainerHighest):**
              /// - Elevated surface appearance
              /// - Subtle differentiation from main background
              /// - Neutral, professional look
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,

                // Rounded corners for friendly appearance
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Thinking Steps (AI reasoning process)
                  ///
                  /// **When shown:**
                  /// For AI messages with thinking steps (Claude-style)
                  ///
                  /// **UX Benefit:**
                  /// Shows AI's reasoning process, builds trust
                  if (!isUser && widget.message.thinkingSteps != null && widget.message.thinkingSteps!.isNotEmpty) ...[
                    ThinkingStepsWidget(
                      steps: widget.message.thinkingSteps!,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                  ],

                  /// Tool Calling (function invocations)
                  ///
                  /// **When shown:**
                  /// When AI uses tools (calculator, web search, etc.)
                  ///
                  /// **UX Benefit:**
                  /// Shows what tools AI is using and their results
                  if (!isUser && widget.message.toolCalls != null && widget.message.toolCalls!.isNotEmpty) ...[
                    ToolCallsList(toolCalls: widget.message.toolCalls!),
                    const SizedBox(height: 12),
                  ],

                  /// Web Search Sources
                  ///
                  /// **When shown:**
                  /// For responses with web search citations (Perplexity-style)
                  ///
                  /// **UX Benefit:**
                  /// Shows source URLs with previews, builds credibility
                  if (!isUser && widget.message.sources != null && widget.message.sources!.isNotEmpty) ...[
                    SourcesGrid(sources: widget.message.sources!, compact: false),
                    const SizedBox(height: 12),
                  ],

                  // Markdown content (main message text)
                  _buildMessageContent(context, isUser),

                  /// Citations (Old source references - kept for backward compatibility)
                  ///
                  /// **When shown:**
                  /// Only for RAG-based responses with source documents
                  ///
                  /// **Why important:**
                  /// - Builds trust in AI responses
                  /// - Allows users to verify information
                  /// - Meets transparency requirements
                  if (widget.message.citations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCitations(context),
                  ],

                  /// Artifact Card (AI-generated content)
                  ///
                  /// **When shown:**
                  /// When AI generates code, diagrams, or documents
                  ///
                  /// **UX Benefit:**
                  /// Click to open full artifact viewer
                  if (!isUser && widget.message.artifact != null) ...[
                    const SizedBox(height: 12),
                    ArtifactCard(
                      artifact: widget.message.artifact!,
                      onTap: () => _showArtifactViewer(context),
                    ),
                  ],

                  /// Streaming Indicator
                  ///
                  /// **When shown:**
                  /// While AI is actively generating response
                  ///
                  /// **UX Benefit:**
                  /// Shows system is working, not frozen
                  /// Manages user expectations for response time
                  if (widget.message.isStreaming) ...[
                    const SizedBox(height: 8),
                    _buildStreamingIndicator(context),
                  ],
                ],
              ),
            ),
          ),

          /// User Avatar (Right Side)
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, isUser),
          ],
        ],
      ),
    );
  }

  /// Build avatar circle
  ///
  /// **Material 3 Design:**
  /// - Circular shape (18px radius = 36px diameter)
  /// - Color-coded by type (primary for user, tertiary for AI)
  /// - Icon-based (simple, recognizable)
  ///
  /// **Accessibility:**
  /// - Icons provide visual distinction
  /// - Colors meet WCAG contrast requirements
  /// - Size is touch-friendly (if made interactive)
  Widget _buildAvatar(BuildContext context, bool isUser) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,

      /// Avatar Colors
      ///
      /// **User (primary):**
      /// - Matches user message bubble color theme
      /// - Creates visual connection
      ///
      /// **AI (tertiaryContainer):**
      /// - Distinct from primary and secondary
      /// - Semantic color for "system/assistant"
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.tertiaryContainer,

        // Perfectly circular
        borderRadius: BorderRadius.circular(18),
      ),

      /// Icons
      ///
      /// **person:** Represents user/human
      /// **psychology:** Represents AI/thinking
      ///
      /// **Color contrast:**
      /// Using "on" colors ensures proper contrast:
      /// - onPrimary for text/icons on primary background
      /// - onTertiaryContainer for text/icons on tertiaryContainer
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        size: 20,
        color: isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onTertiaryContainer,
      ),
    );
  }

  /// Build message content with Markdown rendering
  ///
  /// **flutter_markdown Package:**
  /// Renders markdown text with full support for:
  /// - Headers (# ## ###)
  /// - Bold/italic (**bold** *italic*)
  /// - Links [text](url)
  /// - Lists (- item, 1. item)
  /// - Code blocks (```language code```)
  /// - Inline code (`code`)
  ///
  /// **Why Markdown:**
  /// - AI models naturally output markdown
  /// - Rich formatting without complex parsing
  /// - Widely understood format
  Widget _buildMessageContent(BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final codeBlockBg = theme.colorScheme.surfaceContainerHighest;
    final codeHeaderBg = theme.colorScheme.surfaceContainer;

    return MarkdownBody(
      // Message text content
      data: widget.message.content,

      /// Selectable Text
      ///
      /// **Flutter 3.38:**
      /// Improved text selection with better handle graphics
      /// and proper Material 3 selection colors
      ///
      /// **UX Benefit:**
      /// Users can copy AI responses, code snippets, etc.
      selectable: true,

      /// Custom Styling
      ///
      /// **MarkdownStyleSheet:**
      /// Overrides default markdown styles to match our theme
      ///
      /// **Material 3 Integration:**
      /// Uses theme colors for proper light/dark mode support
      styleSheet: MarkdownStyleSheet(
        // Paragraph text style
        p: theme.textTheme.bodyMedium?.copyWith(
          // Adapt text color to background
          color: isUser
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
        ),

        /// Inline code style
        ///
        /// **Background:**
        /// Subtle background distinguishes code from regular text
        /// Colors adapt to theme brightness
        code: TextStyle(
          backgroundColor: codeBlockBg,
          fontFamily: 'monospace',
        ),

        /// Code block decoration
        ///
        /// **Design:**
        /// Rounded background container for code blocks
        /// (Full rendering handled by custom builder below)
        codeblockDecoration: BoxDecoration(
          color: codeBlockBg,
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      /// Custom Element Builders
      ///
      /// **Purpose:**
      /// Override default rendering for specific elements
      /// Here we replace code blocks with syntax-highlighted version
      ///
      /// **Pattern:**
      /// Map element type ('code') to custom builder
      builders: {
        'code': _CodeBlockBuilder(
          isDark: isDark,
          codeBlockBg: codeBlockBg,
          codeHeaderBg: codeHeaderBg,
        ),
      },
    );
  }

  /// Build citations (source references)
  ///
  /// **Use Case:**
  /// RAG (Retrieval Augmented Generation) responses cite source documents
  /// Shows users where information came from
  ///
  /// **Material 3 Design:**
  /// - Divider for visual separation
  /// - Link icon + colored text for clickable appearance
  /// - Ellipsis for long URLs
  Widget _buildCitations(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual separator from main content
        const Divider(),

        // "Sources:" label
        Text(
          'Sources:',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        /// Citation List
        ///
        /// **Dart 3.0 Spread Operator:**
        /// ...list.map() flattens the mapped widgets into parent children
        ///
        /// **Pattern:**
        /// Each citation becomes a Row with icon + text
        ...widget.message.citations.map(
          (citation) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                // Link icon
                Icon(
                  Icons.link,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(width: 4),

                // Citation text (URL or document name)
                Expanded(
                  child: Text(
                    citation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      // Primary color indicates interactivity
                      color: theme.colorScheme.primary,

                      // Underline for link appearance
                      decoration: TextDecoration.underline,
                    ),

                    // Truncate long URLs
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build streaming indicator
  ///
  /// **Purpose:**
  /// Shows animated spinner while AI is generating response
  ///
  /// **UX Pattern:**
  /// - Small spinner (not overwhelming)
  /// - Text explains what's happening
  /// - Only shown during active generation
  ///
  /// **Flutter 3.38:**
  /// CircularProgressIndicator now uses Material 3 animation timing
  /// 添加漸入動畫效果
  Widget _buildStreamingIndicator(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        // Don't expand to full width
        mainAxisSize: MainAxisSize.min,

        children: [
          // 脈衝動畫效果
          _PulsingDot(color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          _PulsingDot(
            color: Theme.of(context).colorScheme.primary,
            delay: 150,
          ),
          const SizedBox(width: 4),
          _PulsingDot(
            color: Theme.of(context).colorScheme.primary,
            delay: 300,
          ),

          const SizedBox(width: 8),

          // Status text with fade-in animation
          Text(
            'AI 正在思考...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// 脈衝動畫圓點
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    this.delay = 0,
  });

  final Color color;
  final int delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 延遲啟動動畫
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Custom Code Block Builder - Syntax highlighting
///
/// **Purpose:**
/// Replaces default markdown code rendering with syntax-highlighted version
///
/// **flutter_highlighter Package:**
/// Provides syntax highlighting for 100+ languages
/// Uses highlight.js themes (GitHub, VS Code, etc.)
///
/// **Features:**
/// - Language detection from markdown
/// - Theme adapts to light/dark mode
/// - Horizontal scrolling for long lines
/// - Language label at top
///
/// **Material 3 Design:**
/// - Rounded corners
/// - Subtle background colors
/// - Monospace font for code
class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder({
    required this.isDark,
    required this.codeBlockBg,
    required this.codeHeaderBg,
  });

  final bool isDark;
  final Color codeBlockBg;
  final Color codeHeaderBg;

  /// Visit Element After Parsing
  ///
  /// **Called when:**
  /// Markdown parser encounters a code block (```language code```)
  ///
  /// **Parameters:**
  /// - element: Parsed markdown element with content and metadata
  /// - preferredStyle: Default text style (we override this)
  ///
  /// **Returns:**
  /// Custom widget to replace default code block rendering
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Extract code content
    final code = element.textContent;

    /// Extract language from markdown
    ///
    /// **Pattern:**
    /// ```python  ← class="language-python"
    /// code here
    /// ```
    ///
    /// **Fallback:**
    /// If no language specified, use 'plaintext' (no highlighting)
    final language = element.attributes['class']?.replaceAll('language-', '') ??
        'plaintext';

    return Container(
      // Vertical spacing around code block
      margin: const EdgeInsets.symmetric(vertical: 8),

      // Background and shape
      decoration: BoxDecoration(
        color: codeBlockBg,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Language Label Header
          ///
          /// **Design:**
          /// Darker background separates label from code
          /// Shows language for context (python, javascript, etc.)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            // Slightly darker than code background
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.black26,

              // Only round top corners
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

          /// Code Content with Syntax Highlighting
          ///
          /// **Horizontal Scrolling:**
          /// Long lines don't wrap - user can scroll
          /// Preserves code formatting exactly
          ///
          /// **flutter_highlighter:**
          /// HighlightView widget renders code with syntax colors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),

            /// HighlightView
            ///
            /// **Parameters:**
            /// - code: The source code string
            /// - language: Programming language for highlighting
            /// - theme: Color scheme (github or githubDark)
            /// - textStyle: Font settings
            ///
            /// **Themes:**
            /// - githubTheme: Light mode (from package)
            /// - darkTheme: Dark mode (from package)
            child: HighlightView(
              code,
              language: language,

              // Adapt theme to app brightness
              theme: isDark ? darkTheme : githubTheme,

              // No extra padding (handled by parent)
              padding: EdgeInsets.zero,

              // Monospace font for code
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

/// 編輯訊息對話框
///
/// 允許用戶編輯已發送的訊息
class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({
    required this.initialContent,
    required this.onSave,
  });

  final String initialContent;
  final void Function(String) onSave;

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('編輯訊息'),
      content: SizedBox(
        width: 500,
        child: TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '輸入訊息內容...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final newContent = _controller.text.trim();
            if (newContent.isNotEmpty) {
              widget.onSave(newContent);
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
