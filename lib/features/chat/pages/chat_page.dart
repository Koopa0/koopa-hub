import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/session_sidebar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_selector.dart';

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

/// Chat Area - Active conversation view
///
/// **Component Composition:**
/// This widget demonstrates Flutter's composition pattern:
/// - TopBar: Session info and controls
/// - MessageList: Scrollable conversation history
/// - ChatInput: User message entry
///
/// **Dart 3.10 Pattern:**
/// Uses const constructors throughout for performance
class _ChatArea extends StatelessWidget {
  const _ChatArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar with session title and controls
        const _TopBar(),

        // Material 3: Use Divider for visual separation
        // height: 1 for minimal thickness
        const Divider(height: 1),

        // Message list takes remaining space
        // Expanded: Flexes to fill available vertical space
        const Expanded(
          child: MessageList(),
        ),

        const Divider(height: 1),

        // Input field at bottom (fixed position)
        const ChatInput(),
      ],
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
