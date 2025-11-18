import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/session_sidebar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_selector.dart';
import '../widgets/artifact_viewer.dart';

/// Chat Page - Main conversation interface
///
/// **Architecture:**
/// This page has been redesigned to work with the new Gemini-style layout.
/// Instead of managing its own sidebar, it receives context from HomePage's
/// collapsible sidebar system.
///
/// **Flutter 3.38 Best Practices:**
/// - Uses ConsumerWidget for reactive state management
/// - Implements Material 3 design language
/// - Follows composition over inheritance pattern
///
/// **Layout Structure:**
/// ```
/// ┌─────────────────────────────────┐
/// │  [Empty State or Chat Area]     │
/// │                                 │
/// │  • Empty: Welcome message       │
/// │  • Active: TopBar + Messages    │
/// │           + Input               │
/// └─────────────────────────────────┘
/// ```
class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current session from provider
    // This creates a reactive dependency - when session changes,
    // this widget automatically rebuilds
    final currentSession = ref.watch(currentSessionProvider);

    return Scaffold(
      // Material 3: Use colorScheme.surface for background
      // This ensures proper theming in both light/dark modes
      backgroundColor: Theme.of(context).colorScheme.surface,

      // Note: No longer includes SessionSidebar here
      // Sidebar is now managed by HomePage for consistent UX
      body: currentSession == null
          ? const _EmptyState()
          : const _ChatArea(),
    );
  }
}

/// Empty State - Shown when no chat session is selected
///
/// **Design Philosophy:**
/// - Centered content for focus
/// - Clear call-to-action messaging
/// - Uses theme colors for consistency
///
/// **Material 3 Features:**
/// - ColorScheme-based colors (outlineVariant)
/// - Typography system (headlineSmall, bodyMedium)
/// - Semantic spacing
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Material 3 color token
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            // outlineVariant: Perfect for decorative elements
            color: theme.colorScheme.outlineVariant,
          ),

          const SizedBox(height: 24),

          // Headline text
          Text(
            'Start New Conversation',
            style: theme.textTheme.headlineSmall?.copyWith(
              // onSurfaceVariant: Lower emphasis text
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // Body text with instructions
          Text(
            'Select or create a session to start chatting',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat Area - Active conversation view with optional Artifact sidebar
///
/// **Component Composition:**
/// This widget demonstrates Flutter's composition pattern:
/// - Left: Chat area (TopBar, MessageList, ChatInput)
/// - Right: Artifact sidebar (collapsible)
///
/// **Layout:**
/// ```
/// ┌───────────────────┬─────────────┐
/// │   Chat Area       │  Artifact   │
/// │   (70%)           │  Sidebar    │
/// │                   │  (30%)      │
/// └───────────────────┴─────────────┘
/// ```
class _ChatArea extends ConsumerWidget {
  const _ChatArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artifact = ref.watch(artifactSidebarProvider);
    final showSidebar = artifact != null;

    return Row(
      children: [
        // 左側：聊天區域
        Expanded(
          flex: showSidebar ? 7 : 10, // 70% when sidebar shown, 100% otherwise
          child: Column(
            children: [
              // Top bar with session title and controls
              const _TopBar(),

              // Material 3: Use Divider for visual separation
              const Divider(height: 1),

              // Message list takes remaining space
              const Expanded(
                child: MessageList(),
              ),

              const Divider(height: 1),

              // Input field at bottom (fixed position)
              const ChatInput(),
            ],
          ),
        ),

        // 右側：Artifact 側邊欄（可隱藏）
        if (showSidebar) ...[
          // 分隔線
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          // Artifact 側邊欄
          Expanded(
            flex: 3, // 30%
            child: _ArtifactSidebar(artifact: artifact),
          ),
        ],
      ],
    );
  }
}

/// Artifact Sidebar - Displays AI-generated artifacts
///
/// **Features:**
/// - Always visible while artifact is selected
/// - Close button to hide sidebar
/// - Full artifact viewer integrated
class _ArtifactSidebar extends ConsumerWidget {
  const _ArtifactSidebar({required this.artifact});

  final Artifact artifact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          // 側邊欄標題列
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Artifact',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    ref.read(artifactSidebarProvider.notifier).hide();
                  },
                  tooltip: '關閉側邊欄',
                ),
              ],
            ),
          ),

          // Artifact 檢視器
          Expanded(
            child: ArtifactViewer(
              artifact: artifact,
              onClose: null, // 不需要關閉按鈕（已在標題列）
            ),
          ),
        ],
      ),
    );
  }
}

/// Top Bar - Session controls and model selector
///
/// **Functionality:**
/// - Displays current session title
/// - Shows AI model selector
/// - Provides clear chat action
///
/// **Flutter 3.38 Best Practice:**
/// - Uses ConsumerWidget for granular reactivity
/// - Implements proper tooltip accessibility
/// - Follows Material 3 spacing guidelines
class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read session once for this build
    final session = ref.watch(currentSessionProvider);
    final theme = Theme.of(context);

    return Container(
      // Material 3: Consistent padding
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      child: Row(
        children: [
          // Session title - takes available space
          Expanded(
            child: Text(
              session?.title ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                // Material 3: Use fontWeight for emphasis
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              // Prevent overflow with ellipsis
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // AI model selector dropdown
          const ModelSelector(),

          const SizedBox(width: 8),

          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Dart 3.0: Pattern matching could be used here
              // but simple null check is more readable
              if (session != null) {
                ref
                    .read(chatSessionsProvider.notifier)
                    .clearSessionMessages(session.id);
              }
            },
            // Material 3: Always provide tooltips for accessibility
            tooltip: 'Clear conversation',
          ),
        ],
      ),
    );
  }
}
