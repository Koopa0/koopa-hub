import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_session.dart';
import '../providers/chat_provider.dart';

/// AI Model Selector - Dropdown for switching AI models
///
/// **Purpose:**
/// Allows users to switch between different AI backends for the current session:
/// - Koopa (Local RAG): Local knowledge retrieval
/// - Koopa (Web Search): Real-time web search
/// - Gemini (Cloud): Google's cloud AI model
///
/// **Flutter 3.38 Features Used:**
/// - `MenuAnchor`: Material 3 dropdown menu component (replaces PopupMenuButton)
/// - `FilledButton.tonalIcon`: Material 3 tonal variant with icon + label
/// - `MenuItemButton`: Material 3 menu item with better touch targets
///
/// **Dart 3.10 Best Practices:**
/// - Switch expressions for icon mapping
/// - Pattern matching for cleaner conditional logic
/// - const constructors for performance
///
/// **Material 3 Design:**
/// - Uses tonal buttons for secondary actions
/// - Proper icon sizing (18px for inline icons)
/// - Check mark indicator for selected state
/// - ColorScheme-based theming
///
/// **User Experience:**
/// - Shows current model name and icon in button
/// - Clear visual feedback for selected model (checkmark)
/// - Smooth dropdown animation
/// - Touch-friendly menu items
class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current session for reactive updates
    // Widget rebuilds automatically when session changes
    final session = ref.watch(currentSessionProvider);

    // Early return if no session selected
    // Using SizedBox.shrink() instead of Container() for better performance
    if (session == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return MenuAnchor(
      /// MenuAnchor (Flutter 3.10+)
      ///
      /// **Why MenuAnchor over PopupMenuButton:**
      /// - Better Material 3 alignment
      /// - More flexible positioning options
      /// - Improved animation and transitions
      /// - Consistent with other Material 3 components
      ///
      /// **Builder Pattern:**
      /// Provides controller for opening/closing menu programmatically
      builder: (context, controller, child) {
        return FilledButton.tonalIcon(
          /// FilledButton.tonalIcon (Material 3)
          ///
          /// **Material 3 Button Hierarchy:**
          /// 1. FilledButton: High emphasis (primary action)
          /// 2. FilledButton.tonal: Medium emphasis (secondary action) ← We use this
          /// 3. OutlinedButton: Low emphasis (tertiary action)
          /// 4. TextButton: Lowest emphasis (inline action)
          ///
          /// **Why Tonal:**
          /// Model selection is important but not the primary action
          /// in the chat interface. Tonal style provides clear affordance
          /// without dominating the UI.
          ///
          /// **Icon + Label:**
          /// Combining icon and text improves recognition and scannability
          onPressed: () {
            // Toggle menu open/closed
            // This pattern gives users control to dismiss menu
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },

          // Icon representing current model
          icon: _getModelIcon(session.selectedModel),

          // Display name of current model
          label: Text(session.selectedModel.displayName),
        );
      },

      /// Menu Items
      ///
      /// **Pattern:** Map enum values to menu items
      /// This ensures all models are always available and
      /// automatically updates if new models are added to enum
      menuChildren: AIModel.values.map((model) {
        final isSelected = model == session.selectedModel;

        return MenuItemButton(
          /// MenuItemButton (Material 3)
          ///
          /// **Improvements over MenuItem:**
          /// - Better touch targets (minimum 48x48)
          /// - Consistent padding and spacing
          /// - Built-in hover/focus states
          /// - Supports leading and trailing icons
          ///
          /// **Accessibility:**
          /// Material 3 ensures proper contrast ratios and
          /// touch target sizes for all users

          // Icon at start of menu item
          leadingIcon: _getModelIcon(model),

          // Checkmark for currently selected model
          // Material 3: Use primary color for selection indicators
          trailingIcon: isSelected
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : null,

          /// Update session when model is selected
          ///
          /// **Flow:**
          /// 1. Create updated session with new model
          /// 2. Call provider notifier to update state
          /// 3. Riverpod propagates change to all watchers
          /// 4. UI rebuilds automatically with new model
          ///
          /// **Dart 3.10:**
          /// Could use records for more complex updates:
          /// ```dart
          /// final (session, model) = (currentSession, newModel);
          /// ```
          onPressed: () {
            // copyWith pattern for immutable updates
            // This is a best practice for state management
            final updatedSession = session.copyWith(selectedModel: model);

            ref.read(chatSessionsProvider.notifier).updateSession(
                  updatedSession,
                );
          },

          // Model display name
          child: Text(model.displayName),
        );
      }).toList(),
    );
  }

  /// Get icon for AI model
  ///
  /// **Dart 3.0 Switch Expression:**
  /// This is more concise and safer than traditional switch statements:
  /// - Exhaustiveness checking (compiler ensures all cases covered)
  /// - Expression-based (returns value directly)
  /// - No break statements needed
  ///
  /// **Icon Selection:**
  /// - storage: Represents local database/RAG
  /// - search: Represents web search capability
  /// - cloud: Represents cloud-based AI service
  ///
  /// **Material 3:**
  /// Using 18px icon size for inline icons (vs 24px for standalone)
  /// This creates better visual balance with text
  Icon _getModelIcon(AIModel model) {
    return Icon(
      switch (model) {
        AIModel.localRag => Icons.storage,
        AIModel.webSearch => Icons.search,
        AIModel.gemini => Icons.cloud,
      },
      size: 18,
    );
  }
}
