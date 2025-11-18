import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/knowledge_provider.dart';
import '../widgets/document_list.dart';
import '../widgets/knowledge_stats.dart';

/// Knowledge Base Management Page - Document indexing and RAG
///
/// **Purpose:**
/// Central hub for managing documents used in Retrieval-Augmented Generation (RAG):
/// - View indexed documents list
/// - Add new files or folders
/// - Delete documents from index
/// - Monitor indexing status and statistics
///
/// **Flutter 3.38 Features Used:**
/// - Material 3 ColorScheme tokens (surface, outlineVariant)
/// - FilledButton + OutlinedButton for visual hierarchy
/// - Updated Scaffold and Divider styling
///
/// **Dart 3.10 Best Practices:**
/// - ConsumerWidget for reactive state
/// - Records for file data (path, size tuple)
/// - Context.mounted check for async operations
///
/// **Third-Party Packages:**
/// - file_picker: Cross-platform file selection
///
/// **RAG Concept:**
/// Knowledge base allows AI to retrieve relevant documents
/// before generating answers, improving accuracy and adding citations
class KnowledgePage extends ConsumerWidget {
  const KnowledgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch documents list - rebuilds when documents change
    final documents = ref.watch(knowledgeDocumentsProvider);

    return Scaffold(
      // Material 3: Surface background
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Column(
        children: [
          // Header with title and action buttons
          _buildHeader(context, ref),

          // Visual separator
          const Divider(height: 1),

          // Statistics card (index status, document count, etc.)
          const KnowledgeStats(),

          const Divider(height: 1),

          /// Document List or Empty State
          ///
          /// **Conditional Rendering:**
          /// - Empty: Show welcome message with add button
          /// - Has documents: Show scrollable list
          Expanded(
            child: documents.isEmpty
                ? _buildEmptyState(context, ref)
                : const DocumentList(),
          ),
        ],
      ),
    );
  }

  /// Build header with title and action buttons
  ///
  /// **Material 3 Button Hierarchy:**
  /// - FilledButton: Primary action (Add Files) - high emphasis
  /// - OutlinedButton: Secondary action (Add Folder) - medium emphasis
  ///
  /// **Layout:**
  /// Icon + Title | Spacer | Add Files | Add Folder
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// Knowledge icon
          ///
          /// **Material Icons:**
          /// library_books represents documents/knowledge
          Icon(
            Icons.library_books,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: 12),

          /// Page title
          ///
          /// **Material 3 Typography:**
          /// headlineSmall for page headers
          /// FontWeight.bold for emphasis
          Text(
            'Knowledge Base',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Pushes buttons to right edge
          const Spacer(),

          /// Add Files Button (Primary action)
          ///
          /// **FilledButton (Material 3):**
          /// - Highest emphasis
          /// - Filled background (primary color)
          /// - Used for most important action
          FilledButton.icon(
            onPressed: () => _pickFiles(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Files'),
          ),

          const SizedBox(width: 8),

          /// Add Folder Button (Secondary action)
          ///
          /// **OutlinedButton (Material 3):**
          /// - Medium emphasis
          /// - Outline border, no fill
          /// - Used for less common actions
          OutlinedButton.icon(
            onPressed: () => _pickDirectory(context, ref),
            icon: const Icon(Icons.folder_open),
            label: const Text('Add Folder'),
          ),
        ],
      ),
    );
  }

  /// Build empty state view
  ///
  /// **UX Pattern:**
  /// Empty states should:
  /// - Clearly explain why it's empty
  /// - Provide clear call-to-action
  /// - Use friendly, encouraging tone
  /// - Include primary action inline
  ///
  /// **Material 3 Design:**
  /// - Large icon as visual focus
  /// - Text hierarchy (headline → body)
  /// - De-emphasized colors (onSurfaceVariant)
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large decorative icon
          Icon(
            Icons.library_books_outlined,
            size: 80,
            // outlineVariant: Subtle, decorative
            color: theme.colorScheme.outlineVariant,
          ),

          const SizedBox(height: 24),

          // Headline text
          Text(
            'Knowledge Base is Empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // Instructional text
          Text(
            'Add files or folders to build your knowledge base',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Primary action button
          FilledButton.icon(
            onPressed: () => _pickFiles(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Files'),
          ),
        ],
      ),
    );
  }

  /// Pick files for knowledge base
  ///
  /// **file_picker Package:**
  /// Cross-platform file selection (desktop, web, mobile)
  ///
  /// **Supported File Types:**
  /// - txt: Plain text
  /// - md: Markdown documents
  /// - pdf: PDF documents
  /// - docx: Word documents
  /// - json: JSON data
  /// - csv: CSV spreadsheets
  ///
  /// **Dart 3.0 Records:**
  /// Using (path: String, size: int) record syntax
  /// for type-safe file data without creating a class
  ///
  /// **Async Pattern:**
  /// - await file picker
  /// - check context.mounted before showing snackbar
  /// - prevents errors if user navigates away during picker
  Future<void> _pickFiles(BuildContext context, WidgetRef ref) async {
    /// FilePicker.platform.pickFiles
    ///
    /// **Parameters:**
    /// - allowMultiple: User can select multiple files
    /// - type: FileType.custom (restrict to specific extensions)
    /// - allowedExtensions: Only show these file types
    ///
    /// **Returns:**
    /// FilePickerResult? (null if user cancelled)
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'pdf', 'docx', 'json', 'csv'],
    );

    /// Process selected files
    ///
    /// **Dart 3.0 Records Pattern:**
    /// (path: file.path!, size: file.size)
    /// Creates a record with named fields
    ///
    /// **Why Records over Class:**
    /// - Lightweight for simple data
    /// - No need to define separate class
    /// - Pattern matching friendly
    /// - Dart 3.0 feature
    if (result != null && result.files.isNotEmpty) {
      final files = result.files.map((file) {
        /// Record Syntax
        ///
        /// **Type:** ({String path, int size})
        /// Automatically inferred from assignment
        ///
        /// **Named Fields:**
        /// More readable than positional: (file.path!, file.size)
        return (
          path: file.path!,
          size: file.size,
        );
      }).toList();

      /// Add to knowledge base
      ///
      /// **Riverpod Pattern:**
      /// ref.read().notifier for state mutations
      /// Provider handles persistence and indexing
      ref.read(knowledgeDocumentsProvider.notifier).addDocuments(files);

      /// Show confirmation snackbar
      ///
      /// **context.mounted Check (Flutter 3.38):**
      /// After async operations, widget might be disposed
      /// Always check mounted before using context
      ///
      /// **Why Important:**
      /// Prevents errors like "Don't use BuildContexts across async gaps"
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          /// Material 3 SnackBar
          ///
          /// **Design:**
          /// - Bottom toast notification
          /// - Auto-dismiss after duration
          /// - Optional action button
          ///
          /// **Action Pattern:**
          /// Provides immediate undo/view functionality
          SnackBar(
            content: Text('Added ${files.length} files to knowledge base'),

            /// SnackBarAction
            ///
            /// **UX Pattern:**
            /// Allows user to quickly navigate to related view
            /// or undo the action
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // TODO: Scroll to newly added files
                // or navigate to specific document
              },
            ),
          ),
        );
      }
    }
  }

  /// Pick directory for bulk import
  ///
  /// **Use Case:**
  /// Import entire documentation folder, project files, etc.
  ///
  /// **file_picker Pattern:**
  /// getDirectoryPath() returns single directory path
  ///
  /// **Future Enhancement:**
  /// Should scan directory recursively for supported files
  /// Currently adds directory entry as placeholder
  Future<void> _pickDirectory(BuildContext context, WidgetRef ref) async {
    /// Get directory path
    ///
    /// **Platform Support:**
    /// - Desktop: Native folder picker
    /// - Web: Limited support
    /// - Mobile: Permission-dependent
    ///
    /// **Returns:**
    /// String? path (null if cancelled)
    final result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      /// TODO: Implement recursive directory scanning
      ///
      /// **Planned Logic:**
      /// 1. Walk directory tree
      /// 2. Filter by allowed extensions
      /// 3. Calculate total size
      /// 4. Add all files to knowledge base
      /// 5. Show progress indicator for large folders
      ///
      /// **Current Implementation:**
      /// Adds directory path as placeholder
      /// Size 0 indicates directory (not individual file)
      ref.read(knowledgeDocumentsProvider.notifier).addDocument(
            path: result,
            size: 0, // 0 indicates directory
          );

      /// Confirmation message
      ///
      /// **context.mounted:**
      /// Always check after async operations
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          /// Simple SnackBar (no action)
          ///
          /// **When to use:**
          /// Informational messages that don't need user action
          const SnackBar(
            content: Text('Folder added to indexing queue'),
          ),
        );
      }
    }
  }
}
