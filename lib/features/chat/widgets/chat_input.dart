import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';

/// Chat Input Widget - User message entry component
///
/// **Purpose:**
/// Provides a text input field with send functionality for chat messages.
/// Designed to feel natural and responsive, similar to modern messaging apps.
///
/// **Flutter 3.38 Features Used:**
/// - Material 3 `TextField` with updated styling
/// - `FilledButton` (Material 3 replacement for raised buttons)
/// - Proper keyboard handling and focus management
///
/// **Dart 3.10 Best Practices:**
/// - Uses `ConsumerStatefulWidget` for local state + global state
/// - Implements proper resource cleanup in `dispose()`
/// - Follows const constructor pattern where possible
///
/// **User Experience:**
/// - Multi-line support (up to 5 lines)
/// - Visual feedback during message sending
/// - Automatic focus return after send
/// - Disabled state while processing
class ChatInput extends ConsumerStatefulWidget {
  const ChatInput({super.key});

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  /// Text editing controller
  ///
  /// **Why we need this:**
  /// - Allows programmatic access to input text
  /// - Enables clearing input after send
  /// - Provides text change notifications if needed
  ///
  /// **Important:** Must be disposed to prevent memory leaks
  final TextEditingController _controller = TextEditingController();

  /// Focus node for keyboard management
  ///
  /// **Purpose:**
  /// - Controls when keyboard appears/disappears
  /// - Allows programmatic focus control
  /// - Essential for good UX (return focus after send)
  ///
  /// **Important:** Must be disposed to prevent memory leaks
  final FocusNode _focusNode = FocusNode();

  /// Sending state flag
  ///
  /// **Why local state:**
  /// This is UI-only state that doesn't need to be in global state.
  /// It only affects this widget's rendering and is temporary.
  ///
  /// **Alternative:** Could use AsyncValue from Riverpod, but that's
  /// overkill for simple loading state
  bool _isSending = false;

  @override
  void dispose() {
    /// Critical: Clean up resources
    ///
    /// **Why this matters:**
    /// TextEditingController and FocusNode both hold native resources
    /// and register listeners. Failing to dispose them causes memory leaks.
    ///
    /// **Best Practice:** Always dispose in reverse order of creation
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Material 3: Surface color for input area
      // This slightly elevates the input from main content
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        // Subtle top border for visual separation
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),

      child: Row(
        // Align to bottom for multi-line input
        // This keeps send button aligned with last line of text
        crossAxisAlignment: CrossAxisAlignment.end,

        children: [
          // Text input field - takes available space
          Expanded(
            child: _buildTextField(theme),
          ),

          const SizedBox(width: 12),

          // Send button - fixed width
          _buildSendButton(theme),
        ],
      ),
    );
  }

  /// Build the text input field
  ///
  /// **Material 3 Features:**
  /// - Uses `filled` style (surfaceContainerHighest background)
  /// - Circular border radius for modern look
  /// - No outline, relies on background color for definition
  ///
  /// **Accessibility:**
  /// - Clear hint text
  /// - Proper text input action
  /// - Supports assistive technologies
  Widget _buildTextField(ThemeData theme) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,

      // Allow multiple lines but limit to 5 for UX
      // This prevents the input from taking over the screen
      maxLines: 5,
      minLines: 1,

      // Text input action
      // `newline` allows Enter to create new lines
      // Use `send` to make Enter submit instead
      textInputAction: TextInputAction.newline,

      // Material 3: Updated input decoration
      decoration: InputDecoration(
        hintText: 'Type a message...',

        // Material 3: Filled style
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,

        // Circular border for modern look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none, // No border in Material 3 filled style
        ),

        // Padding inside the text field
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),

      // Submit on Enter key
      onSubmitted: (_) => _sendMessage(),
    );
  }

  /// Build the send button
  ///
  /// **Material 3 Features:**
  /// - Uses `FilledButton` (new in Material 3)
  /// - Circular shape for visual consistency with input
  /// - Shows loading indicator when sending
  ///
  /// **States:**
  /// - Normal: Shows send icon
  /// - Sending: Shows loading spinner
  /// - Disabled: Grayed out when sending
  Widget _buildSendButton(ThemeData theme) {
    return FilledButton(
      // Disable button while sending
      // This prevents multiple simultaneous sends
      onPressed: _isSending ? null : _sendMessage,

      // Circular button style
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),

        // Material 3: Primary color for primary action
        // backgroundColor is automatically set from theme
      ),

      // Show loading indicator or send icon
      child: _isSending
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                // White color works on primary background
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send),
    );
  }

  /// Send message logic
  ///
  /// **Flow:**
  /// 1. Validate input (not empty)
  /// 2. Set sending state (disable button, show loading)
  /// 3. Call API via provider
  /// 4. Clear input on success
  /// 5. Return focus to input
  /// 6. Reset sending state
  ///
  /// **Error Handling:**
  /// Uses try-finally to ensure state is reset even if send fails
  ///
  /// **Dart 3.10:**
  /// Could use pattern matching for result handling, but
  /// async/await is clearer for this use case
  Future<void> _sendMessage() async {
    // Trim whitespace from input
    // This prevents sending messages that are only spaces/newlines
    final text = _controller.text.trim();

    // Validate: Don't send empty messages
    if (text.isEmpty) return;

    // Set sending state
    // This disables the button and shows loading indicator
    setState(() => _isSending = true);

    try {
      // Clear input immediately for better UX
      // User sees their message "sent" right away
      _controller.clear();

      // Send message via provider
      // This is an async operation that:
      // 1. Adds user message to session
      // 2. Calls AI API
      // 3. Streams response back
      await ref.read(chatServiceProvider.notifier).sendMessage(text);
    } finally {
      // Always reset state, even if error occurs
      // This prevents the UI from getting stuck in loading state
      if (mounted) {
        setState(() => _isSending = false);

        // Return focus to input for next message
        // This creates a smooth typing experience
        _focusNode.requestFocus();
      }
    }
  }
}
