import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/chat_session.dart';
import '../providers/chat_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/confirmation_dialog.dart';

/// Session List Sidebar - Conversation history navigation
///
/// **Purpose:**
/// Displays all chat sessions with support for:
/// - Creating new conversations
/// - Switching between sessions
/// - Deleting sessions (with confirmation)
/// - Pinning important sessions to top
///
/// **Flutter 3.38 Features Used:**
/// - Material 3 surface colors (surfaceContainerLowest)
/// - FilledButton for primary actions
/// - Updated ColorScheme tokens
/// - Improved InkWell ripple effects
///
/// **Dart 3.10 Best Practices:**
/// - ConsumerWidget for reactive state
/// - Const constructors for performance
/// - Proper null safety patterns
///
/// **Material 3 Design:**
/// - Surface elevation system for depth
/// - Proper touch targets (48dp minimum)
/// - ColorScheme-based theming throughout
/// - Consistent padding and spacing
///
/// **Performance:**
/// - ListView.builder for efficient scrolling
/// - Const widgets where possible
/// - Minimal rebuilds with granular providers
class SessionSidebar extends ConsumerWidget {
  const SessionSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch sessions list - rebuilds when sessions change
    final sessions = ref.watch(chatSessionsProvider);

    // Watch current session ID - rebuilds when selection changes
    final currentSessionId = ref.watch(currentSessionIdProvider);

    return Container(
      // Fixed width sidebar
      // Note: This is deprecated in favor of collapsible sidebar in HomePage
      // but kept here for backwards compatibility
      width: AppConstants.sidebarWidthExpanded,

      /// Material 3: Surface Container System
      ///
      /// **Surface Hierarchy (lowest to highest elevation):**
      /// 1. surfaceContainerLowest ← We use this for sidebar
      /// 2. surfaceContainerLow
      /// 3. surfaceContainer
      /// 4. surfaceContainerHigh
      /// 5. surfaceContainerHighest
      ///
      /// **Why surfaceContainerLowest:**
      /// Sidebar is at the lowest visual layer, providing
      /// a subtle background that doesn't compete with content
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,

        /// Material 3: Divider styling
        ///
        /// **outlineVariant vs outline:**
        /// - outlineVariant: Subtle separation (12% opacity)
        /// - outline: More prominent borders (16% opacity)
        ///
        /// We use outlineVariant for gentle visual separation
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),

      child: Column(
        children: [
          // Header with "New Chat" button
          _buildHeader(context, ref),

          // Visual separator (1px, uses theme color)
          const Divider(height: 1),

          /// Session List
          ///
          /// **Performance Pattern:**
          /// - Expanded: Takes all available vertical space
          /// - ListView.builder: Only builds visible items
          /// - Efficient for large session lists
          ///
          /// **Conditional Rendering:**
          /// Shows empty state when no sessions exist
          Expanded(
            child: sessions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    // Padding around list (not inside items)
                    // This prevents first/last items from touching edges
                    padding: const EdgeInsets.symmetric(vertical: 8),

                    itemCount: sessions.length,

                    /// Item Builder
                    ///
                    /// **Flutter Best Practice:**
                    /// Create widgets in builder, don't pre-create
                    /// This allows Flutter to optimize rebuilds
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isSelected = session.id == currentSessionId;

                      return _SessionTile(
                        session: session,
                        isSelected: isSelected,

                        /// Switch to this session
                        ///
                        /// **Riverpod Pattern:**
                        /// - ref.watch: Subscribe to changes (in build)
                        /// - ref.read: One-time read (in callbacks)
                        ///
                        /// Using .notifier.state for StateProvider updates
                        onTap: () {
                          ref.read(currentSessionIdProvider.notifier)
                              .setSessionId(session.id);
                        },

                        // Delete session callback
                        onDelete: () {
                          ref
                              .read(chatSessionsProvider.notifier)
                              .deleteSession(session.id);
                        },

                        // Toggle pin status callback
                        onTogglePin: () {
                          ref
                              .read(chatSessionsProvider.notifier)
                              .toggleSessionPin(session.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build header with "New Chat" button
  ///
  /// **Material 3 FilledButton:**
  /// - High emphasis for primary action
  /// - Filled background (colorScheme.primary)
  /// - Icon + label variant for clarity
  ///
  /// **Accessibility:**
  /// - Full-width button for easy targeting
  /// - Icon reinforces text meaning
  /// - Proper contrast ratios ensured by Material 3
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        // Full width button
        width: double.infinity,

        child: FilledButton.icon(
          onPressed: () {
            // Create new session via provider
            // Provider handles state updates and persistence
            ref.read(chatSessionsProvider.notifier).createSession();
          },

          // Plus icon for "create" action
          icon: const Icon(Icons.add),

          // Button label
          label: const Text('New Chat'),
        ),
      ),
    );
  }

  /// Build empty state view
  ///
  /// **UX Pattern:**
  /// Clear messaging when list is empty helps users understand
  /// what action to take (click button above)
  ///
  /// **Material 3:**
  /// - Uses onSurfaceVariant for de-emphasized text
  /// - Center alignment for focus
  /// - Adequate padding for breathing room
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No conversations yet\nClick above to start chatting',
          textAlign: TextAlign.center,

          // Material 3: bodyMedium for secondary content
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // onSurfaceVariant: Lower emphasis than onSurface
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

/// Session List Item - Individual session tile
///
/// **Architecture Decision:**
/// Uses StatelessWidget instead of StatefulWidget because:
/// - No local state needed
/// - Parent manages all state via callbacks
/// - Better performance (no State object overhead)
/// - Easier to reason about data flow
///
/// **Flutter Best Practice:**
/// Prefer StatelessWidget when possible. Only use StatefulWidget
/// when you need to manage local state (animations, controllers, etc.)
class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
  });

  /// Chat session data
  ///
  /// **Type Safety (Dart 3.10):**
  /// Using explicit ChatSession type instead of dynamic
  /// provides compile-time type checking and better IDE support
  final ChatSession session;

  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      // Horizontal padding creates gutters
      // Vertical padding creates spacing between items
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

      /// Material + InkWell Pattern
      ///
      /// **Why this combination:**
      /// - Material: Provides background color and shape
      /// - InkWell: Adds ripple effect on tap
      ///
      /// **Flutter 3.38:**
      /// Ripple effects are now faster and match Material 3 specs
      ///
      /// **Selected State:**
      /// Uses secondaryContainer with opacity for subtle highlight
      /// This is Material 3's recommended pattern for selection
      child: Material(
        color: isSelected
            ? colorScheme.secondaryContainer.withOpacity(0.5)
            : Colors.transparent,

        // Rounded corners for modern look
        borderRadius: BorderRadius.circular(12),

        child: InkWell(
          onTap: onTap,

          // Match borderRadius for proper ripple clipping
          borderRadius: BorderRadius.circular(12),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title Row
                ///
                /// Contains: [Pin icon?] + Title + More menu
                Row(
                  children: [
                    /// Pin indicator
                    ///
                    /// **Dart 3.0 Spread Operator:**
                    /// Using ...[] to conditionally add widgets
                    /// This is cleaner than using if/else with separate children
                    if (session.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 14, // Small icon for subtle indicator
                        color: colorScheme.primary, // Primary color = important
                      ),
                      const SizedBox(width: 4), // Spacing
                    ],

                    /// Session Title
                    ///
                    /// **Material 3 Typography:**
                    /// - bodyMedium: Standard text size
                    /// - FontWeight varies by selection state
                    /// - Color adapts to background
                    Expanded(
                      child: Text(
                        session.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          // Selected sessions get bold text
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,

                          // Color adapts to background
                          // onSecondaryContainer when selected (better contrast)
                          // onSurface when not selected (standard text)
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),

                        // Limit to one line with ellipsis
                        // This prevents long titles from breaking layout
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // More options menu
                    _buildPopupMenu(context),
                  ],
                ),

                const SizedBox(height: 4),

                /// Last Message Preview
                ///
                /// **UX Pattern:**
                /// Showing message preview helps users identify conversations
                /// Similar to email clients and messaging apps
                ///
                /// **Material 3:**
                /// - bodySmall: Smaller, secondary text
                /// - onSurfaceVariant: De-emphasized color
                Text(
                  session.lastMessagePreview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),

                  // Allow up to 2 lines of preview
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                /// Metadata Row
                ///
                /// Shows: Time + Message count
                /// Using Spacer to push items to edges
                Row(
                  children: [
                    // Formatted timestamp (e.g., "14:30", "Yesterday", "1/15")
                    Text(
                      _formatTime(session.updatedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    // Pushes message count to right edge
                    const Spacer(),

                    // Message count (only show if > 0)
                    if (session.messageCount > 0)
                      Text(
                        '${session.messageCount} messages',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build context menu for session actions
  ///
  /// **Material 3 Note:**
  /// PopupMenuButton is still used here, but could be upgraded to
  /// MenuAnchor for better Material 3 alignment (similar to ModelSelector)
  ///
  /// **Actions:**
  /// - Pin/Unpin: Toggle session importance
  /// - Delete: Remove session (with confirmation)
  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),

      /// Menu Items
      ///
      /// **Dart 3.10 Pattern:**
      /// Could use records here for item data:
      /// ```dart
      /// final items = [
      ///   ('pin', Icons.push_pin, 'Pin'),
      ///   ('delete', Icons.delete_outline, 'Delete'),
      /// ];
      /// ```
      itemBuilder: (context) => [
        // Pin/Unpin option
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              // Toggle icon based on current state
              Icon(session.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              const SizedBox(width: 12),

              // Toggle text based on current state
              Text(session.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),

        // Delete option (destructive action)
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              // Red icon indicates destructive action
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 12),

              // Red text reinforces danger
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],

      /// Handle menu selection
      ///
      /// **Dart 3.0:**
      /// Could use switch expressions here for cleaner code:
      /// ```dart
      /// onSelected: (value) => switch (value) {
      ///   'pin' => onTogglePin(),
      ///   'delete' => _showDeleteDialog(context),
      ///   _ => null,
      /// }
      /// ```
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onTogglePin();
            break;
          case 'delete':
            // Show confirmation dialog before deleting
            _showDeleteDialog(context);
            break;
        }
      },
    );
  }

  /// Show delete confirmation dialog
  ///
  /// **UX Best Practice:**
  /// Always confirm destructive actions to prevent accidental data loss
  ///
  /// **Material 3 AlertDialog:**
  /// - Clear title explaining action
  /// - Descriptive content with consequences
  /// - Two buttons: Cancel (low emphasis) and Delete (high emphasis)
  ///
  /// **Flutter 3.38:**
  /// AlertDialog now uses Material 3 styling by default:
  /// - Larger corner radius
  /// - Updated padding and spacing
  /// - Better elevation and shadows
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Clear, action-oriented title
        title: const Text('Delete Conversation'),

        // Explain consequences
        content:
            const Text('Are you sure? This action cannot be undone.'),

        /// Action Buttons
        ///
        /// **Material 3 Pattern:**
        /// - TextButton for dismiss/cancel (low emphasis)
        /// - FilledButton for confirm (high emphasis)
        /// - Destructive actions use error color
        actions: [
          // Cancel button (low emphasis)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),

          // Delete button (high emphasis + destructive)
          FilledButton(
            onPressed: () {
              // Perform delete
              onDelete();

              // Close dialog
              Navigator.of(context).pop();
            },

            /// Material 3: Error Color for Destructive Actions
            ///
            /// **Why:**
            /// - Visually signals danger
            /// - Consistent with Material Design guidelines
            /// - Helps prevent accidental taps
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),

            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }

  /// Format timestamp for display
  ///
  /// **Display Logic:**
  /// - Today: Show time (e.g., "14:30")
  /// - Yesterday: Show "Yesterday"
  /// - Older: Show date (e.g., "1/15")
  ///
  /// **Why This Pattern:**
  /// Similar to messaging apps (WhatsApp, Telegram, etc.)
  /// Balances recency awareness with space efficiency
  ///
  /// **Dart 3.10:**
  /// Could use pattern matching for date comparison:
  /// ```dart
  /// return switch (date) {
  ///   _ when date == today => DateFormat('HH:mm').format(dateTime),
  ///   _ when date == yesterday => 'Yesterday',
  ///   _ => DateFormat('M/d').format(dateTime),
  /// };
  /// ```
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();

    // Normalize to date-only (remove time component)
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Compare dates and format accordingly
    if (date == today) {
      // Today: Show time (24-hour format)
      return DateFormat('HH:mm').format(dateTime);
    } else if (date == yesterday) {
      // Yesterday: Show "Yesterday"
      return 'Yesterday';
    } else {
      // Older: Show month/day (e.g., "1/15")
      return DateFormat('M/d').format(dateTime);
    }
  }
}
