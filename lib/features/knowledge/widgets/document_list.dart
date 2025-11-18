import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/confirmation_dialog.dart';
import '../providers/knowledge_provider.dart';
import '../models/knowledge_document.dart';

/// Document List - Displays all indexed documents
///
/// **Purpose:**
/// Shows scrollable list of documents in knowledge base
/// with status, metadata, and action buttons
///
/// **Flutter 3.38 Features:**
/// - Material 3 Card with updated elevation/styling
/// - ListView.builder for efficient rendering
///
/// **Performance:**
/// Only builds visible cards (viewport optimization)
class DocumentList extends ConsumerWidget {
  const DocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch documents - rebuilds when list changes
    final documents = ref.watch(knowledgeDocumentsProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _DocumentCard(document: document);
      },
    );
  }
}

/// Document Card - Individual document display
///
/// **Components:**
/// - File icon (based on extension)
/// - Name and path
/// - Status chip (pending, indexing, indexed, failed)
/// - Metadata (size, vector count)
/// - Action buttons (reindex, delete)
/// - Summary (if available)
/// - Error message (if failed)
///
/// **Material 3:**
/// Uses Card with proper elevation and spacing
class _DocumentCard extends ConsumerWidget {
  const _DocumentCard({required this.document});

  final KnowledgeDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row
            ///
            /// **Layout:** Icon | Name/Path | Status Chip
            Row(
              children: [
                // File type icon
                _buildFileIcon(theme),

                const SizedBox(width: 12),

                /// Document info
                ///
                /// **Expanded:**
                /// Takes available space between icon and status chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document name
                      Text(
                        document.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // File path
                      Text(
                        document.path,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Status indicator
                _buildStatusChip(theme),
              ],
            ),

            const SizedBox(height: 12),

            /// Metadata and Actions Row
            ///
            /// **Layout:** Size | Vector Count | Spacer | Reindex | Delete
            Row(
              children: [
                // File size chip
                _buildInfoChip(
                  theme,
                  Icons.storage,
                  document.formattedSize,
                ),

                const SizedBox(width: 12),

                // Vector count (if indexed)
                if (document.vectorCount != null)
                  _buildInfoChip(
                    theme,
                    Icons.grain,
                    '${document.vectorCount} vectors',
                  ),

                // Push action buttons to right
                const Spacer(),

                /// Reindex Button
                ///
                /// **When shown:**
                /// Only for documents that support re-indexing
                /// (failed or outdated documents)
                if (document.canReindex)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref
                          .read(knowledgeDocumentsProvider.notifier)
                          .reindexDocument(document.id);
                    },
                    tooltip: 'Re-index',
                  ),

                /// Delete Button
                ///
                /// **When shown:**
                /// Only for documents that can be deleted
                /// (not currently indexing)
                if (document.canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteDialog(context, ref),
                    tooltip: 'Delete',
                  ),
              ],
            ),

            /// Document Summary
            ///
            /// **When shown:**
            /// AI-generated summary (if available)
            ///
            /// **Purpose:**
            /// Helps users quickly understand document content
            if (document.summary != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              Text(
                document.summary!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            /// Error Message
            ///
            /// **When shown:**
            /// If indexing failed
            ///
            /// **Material 3:**
            /// Uses errorContainer for visual alert
            if (document.errorMessage != null) ...[
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Error icon
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    // Error message
                    Expanded(
                      child: Text(
                        document.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build file type icon
  ///
  /// **Dart 3.0 Switch Expression:**
  /// Maps file extension to appropriate icon
  ///
  /// **Icon Choices:**
  /// - description: Generic document
  /// - article: Markdown files
  /// - picture_as_pdf: PDF files
  /// - code: JSON files
  /// - table_chart: CSV files
  ///
  /// **Material 3:**
  /// Icon placed in colored container (primaryContainer)
  Widget _buildFileIcon(ThemeData theme) {
    final icon = switch (document.type) {
      '.txt' => Icons.description,
      '.md' => Icons.article,
      '.pdf' => Icons.picture_as_pdf,
      '.docx' => Icons.description,
      '.json' => Icons.code,
      '.csv' => Icons.table_chart,
      _ => Icons.insert_drive_file, // Default/unknown file type
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Build status chip
  ///
  /// **Dart 3.0 Records + Switch Expression:**
  /// Returns (Color, IconData) tuple based on status
  ///
  /// **Statuses:**
  /// - pending: Waiting to be indexed
  /// - indexing: Currently processing
  /// - indexed: Successfully indexed
  /// - failed: Indexing failed
  /// - deleted: Marked for deletion
  ///
  /// **Material 3 Chip:**
  /// Compact visual indicator with icon and label
  Widget _buildStatusChip(ThemeData theme) {
    /// Status mapping
    ///
    /// **Record Pattern:**
    /// (Color background, IconData icon)
    /// Destructured into separate variables below
    final (color, icon) = switch (document.status) {
      DocumentStatus.pending => (
          theme.colorScheme.tertiaryContainer,
          Icons.schedule,
        ),
      DocumentStatus.indexing => (
          theme.colorScheme.primaryContainer,
          Icons.sync,
        ),
      DocumentStatus.indexed => (
          theme.colorScheme.primaryContainer,
          Icons.check_circle,
        ),
      DocumentStatus.failed => (
          theme.colorScheme.errorContainer,
          Icons.error,
        ),
      DocumentStatus.deleted => (
          theme.colorScheme.surfaceContainerHighest,
          Icons.delete,
        ),
    };

    /// Material 3 Chip
    ///
    /// **Properties:**
    /// - avatar: Leading icon
    /// - label: Status text
    /// - backgroundColor: From switch expression
    /// - visualDensity.compact: Smaller touch target
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(document.status.displayName),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Build info chip (size, vector count, etc.)
  ///
  /// **Pattern:**
  /// Icon + Text label in a Row
  ///
  /// **Used for:**
  /// - File size
  /// - Vector count
  /// - Last updated time
  /// - etc.
  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Show delete confirmation dialog
  ///
  /// **Material 3 AlertDialog:**
  /// - Clear title
  /// - Descriptive content
  /// - TextButton for cancel (low emphasis)
  /// - FilledButton for delete (high emphasis + error color)
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${document.name}"?\n'
          'This will remove the document from your knowledge base.',
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),

          /// Delete button
          ///
          /// **Material 3 Pattern:**
          /// Destructive actions use error color background
          FilledButton(
            onPressed: () {
              // Remove from knowledge base
              ref
                  .read(knowledgeDocumentsProvider.notifier)
                  .removeDocument(document.id);

              // Close dialog
              Navigator.of(context).pop();
            },

            // Error color signals destructive action
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),

            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(knowledgeDocumentsProvider.notifier).removeDocument(document.id);
    }
  }
}
