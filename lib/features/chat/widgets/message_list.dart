import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_highlighter/theme_map.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../core/constants/design_tokens.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import 'message_action_bar.dart';
import 'source_citation.dart';

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
  List<Message> _previousMessages = [];

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
  const _MessageBubble({required this.message});

  final Message message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isHovered = false;

  void _handleAction(MessageAction action) {
    // TODO: 實作各個操作
    switch (action) {
      case MessageAction.copy:
        // 複製功能已在 MessageActionBar 中處理
        break;
      case MessageAction.edit:
        // TODO: 實作編輯功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('編輯功能開發中'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case MessageAction.regenerate:
        // TODO: 實作重新生成功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('重新生成功能開發中'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case MessageAction.delete:
        // TODO: 實作刪除功能
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('刪除功能開發中'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.type == MessageType.user;

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
                  // Markdown content (main message text)
                  _buildMessageContent(context, isUser),

                  /// Citations (Source References)
                  ///
                  /// **When shown:**
                  /// Only for RAG-based responses with source documents
                  ///
                  /// **Why important:**
                  /// - Builds trust in AI responses
                  /// - Allows users to verify information
                  /// - Meets transparency requirements
                  if (message.citations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCitations(context),
                  ],

                  /// Streaming Indicator
                  ///
                  /// **When shown:**
                  /// While AI is actively generating response
                  ///
                  /// **UX Benefit:**
                  /// Shows system is working, not frozen
                  /// Manages user expectations for response time
                  if (message.isStreaming) ...[
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
      data: message.content,

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
        'code': _CodeBlockBuilder(isDark: isDark),
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
        ...message.citations.map(
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
  Widget _buildStreamingIndicator(BuildContext context) {
    return Row(
      // Don't expand to full width
      mainAxisSize: MainAxisSize.min,

      children: [
        // Small spinner
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(width: 8),

        // Status text
        Text(
          'Generating...',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
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
            /// - githubDarkTheme: Dark mode (from package)
            child: HighlightView(
              code,
              language: language,

              // Adapt theme to app brightness
              theme: isDark ? githubDarkTheme : githubTheme,

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
