import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/knowledge_provider.dart';
import '../widgets/document_list.dart';
import '../widgets/knowledge_stats.dart';
import '../../../core/widgets/empty_state.dart';

/// 知識庫管理頁面
///
/// 功能：
/// - 顯示已索引的文件列表
/// - 添加新文件/資料夾
/// - 刪除文件
/// - 顯示索引狀態和統計資訊
class KnowledgePage extends ConsumerWidget {
  const KnowledgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(knowledgeDocumentsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // 頂部工具欄
          _buildHeader(context, ref),

          const Divider(height: 1),

          // 統計資訊卡片
          const KnowledgeStats(),

          const Divider(height: 1),

          // 文件列表
          Expanded(
            child: documents.isEmpty
                ? _buildEmptyState(context, ref)
                : const DocumentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.library_books,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '知識庫',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _pickFiles(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('添加文件'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _pickDirectory(context, ref),
            icon: const Icon(Icons.folder_open),
            label: const Text('添加資料夾'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.library_books_outlined,
      title: '知識庫是空的',
      message: '添加文件或資料夾開始建立您的知識庫',
      action: () => _pickFiles(context, ref),
      actionLabel: '添加文件',
    );
  }

  /// 選擇文件
  Future<void> _pickFiles(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'pdf', 'docx', 'json', 'csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      final files = result.files.map((file) {
        return (
          path: file.path!,
          size: file.size,
        );
      }).toList();

      ref.read(knowledgeDocumentsProvider.notifier).addDocuments(files);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加 ${files.length} 個文件到知識庫'),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  /// 選擇資料夾
  Future<void> _pickDirectory(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      // TODO: 實作資料夾掃描邏輯
      // 目前只添加一個示範項目
      ref.read(knowledgeDocumentsProvider.notifier).addDocument(
            path: result,
            size: 0,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('資料夾已添加到索引隊列'),
          ),
        );
      }
    }
  }
}
