import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/confirmation_dialog.dart';
import '../providers/knowledge_provider.dart';
import '../models/knowledge_document.dart';

/// 文件列表
///
/// 顯示所有已索引的文件
class DocumentList extends ConsumerWidget {
  const DocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

/// 文件卡片
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
            // 文件名稱和狀態
            Row(
              children: [
                _buildFileIcon(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                _buildStatusChip(theme),
              ],
            ),

            const SizedBox(height: 12),

            // 文件詳情
            Row(
              children: [
                _buildInfoChip(
                  theme,
                  Icons.storage,
                  document.formattedSize,
                ),
                const SizedBox(width: 12),
                if (document.vectorCount != null)
                  _buildInfoChip(
                    theme,
                    Icons.grain,
                    '${document.vectorCount} 向量',
                  ),
                const Spacer(),
                // 操作按鈕
                if (document.canReindex)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref
                          .read(knowledgeDocumentsProvider.notifier)
                          .reindexDocument(document.id);
                    },
                    tooltip: '重新索引',
                  ),
                if (document.canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteDialog(context, ref),
                    tooltip: '刪除',
                  ),
              ],
            ),

            // 摘要
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

            // 錯誤訊息
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
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
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

  Widget _buildFileIcon(ThemeData theme) {
    final icon = switch (document.type) {
      '.txt' => Icons.description,
      '.md' => Icons.article,
      '.pdf' => Icons.picture_as_pdf,
      '.docx' => Icons.description,
      '.json' => Icons.code,
      '.csv' => Icons.table_chart,
      _ => Icons.insert_drive_file,
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

  Widget _buildStatusChip(ThemeData theme) {
    final (color, icon) = switch (document.status) {
      DocumentStatus.pending => (
          theme.colorScheme.tertiaryContainer,
          Icons.schedule
        ),
      DocumentStatus.indexing => (
          theme.colorScheme.primaryContainer,
          Icons.sync
        ),
      DocumentStatus.indexed => (
          theme.colorScheme.primaryContainer,
          Icons.check_circle
        ),
      DocumentStatus.failed => (theme.colorScheme.errorContainer, Icons.error),
      DocumentStatus.deleted => (
          theme.colorScheme.surfaceContainerHighest,
          Icons.delete
        ),
    };

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(document.status.displayName),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

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

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: '刪除文件',
      message: '確定要刪除「${document.name}」嗎？\n此操作將從知識庫中移除此文件。',
      icon: Icons.delete_outline,
      confirmText: '刪除',
      cancelText: '取消',
      isDestructive: true,
    );

    if (confirmed == true) {
      ref.read(knowledgeDocumentsProvider.notifier).removeDocument(document.id);
    }
  }
}
