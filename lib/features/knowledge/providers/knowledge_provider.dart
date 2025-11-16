import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/knowledge_document.dart';

part 'knowledge_provider.g.dart';

/// 知識庫文件列表 Provider
///
/// 管理所有已索引的文件
@riverpod
class KnowledgeDocuments extends _$KnowledgeDocuments {
  @override
  List<KnowledgeDocument> build() {
    // TODO: 從本地儲存（Hive）載入文件列表
    // 現在返回示範文件，展示不同狀態

    // 示範文件 1: 已索引的 PDF
    final doc1 = KnowledgeDocument.create(
      path: '/documents/flutter_guide.pdf',
      size: 2048576, // 2MB
    ).markAsIndexed(
      summary: 'Flutter 開發完整指南，涵蓋基礎概念、狀態管理、路由導航等核心主題',
      vectorCount: 125,
    );

    // 示範文件 2: 已索引的 Markdown
    final doc2 = KnowledgeDocument.create(
      path: '/documents/riverpod_tutorial.md',
      size: 512000, // 500KB
    ).markAsIndexed(
      summary: 'Riverpod 3.0 使用教學，包含程式碼生成和最佳實踐',
      vectorCount: 68,
    );

    // 示範文件 3: 索引中
    final doc3 = KnowledgeDocument.create(
      path: '/documents/design_patterns.txt',
      size: 1024000, // 1MB
    ).markAsIndexing();

    // 示範文件 4: 已索引的 JSON
    final doc4 = KnowledgeDocument.create(
      path: '/data/api_documentation.json',
      size: 256000, // 250KB
    ).markAsIndexed(
      summary: 'API 文件集合，包含所有端點的詳細說明和範例',
      vectorCount: 42,
    );

    return [doc1, doc2, doc3, doc4];
  }

  /// 添加文件
  ///
  /// 接收檔案路徑和大小，建立新的文件記錄
  void addDocument({
    required String path,
    required int size,
  }) {
    final newDoc = KnowledgeDocument.create(
      path: path,
      size: size,
    );

    state = [...state, newDoc];

    // 自動開始索引
    _startIndexing(newDoc.id);
  }

  /// 添加多個文件
  ///
  /// 批次處理多個檔案
  void addDocuments(List<({String path, int size})> files) {
    final newDocs = files.map((file) {
      return KnowledgeDocument.create(
        path: file.path,
        size: file.size,
      );
    }).toList();

    state = [...state, ...newDocs];

    // 批次索引
    for (final doc in newDocs) {
      _startIndexing(doc.id);
    }
  }

  /// 刪除文件
  void removeDocument(String documentId) {
    state = state.where((doc) => doc.id != documentId).toList();
    // TODO: 呼叫 API 刪除向量資料
  }

  /// 更新文件狀態
  void updateDocument(KnowledgeDocument updatedDoc) {
    state = state.map((doc) {
      return doc.id == updatedDoc.id ? updatedDoc : doc;
    }).toList();
  }

  /// 開始索引流程
  ///
  /// 這是一個私有方法，自動在添加文件後呼叫
  Future<void> _startIndexing(String documentId) async {
    // 1. 標記為索引中
    final doc = state.firstWhere((d) => d.id == documentId);
    updateDocument(doc.markAsIndexing());

    try {
      // TODO: 2. 呼叫 API 進行索引
      // POST /knowledge/add
      await Future.delayed(const Duration(seconds: 2)); // 模擬 API 呼叫

      // 3. 標記為完成
      final updatedDoc = state.firstWhere((d) => d.id == documentId);
      updateDocument(updatedDoc.markAsIndexed(
        summary: '這是一個模擬的文件摘要',
        vectorCount: 42,
      ));
    } catch (e) {
      // 4. 如果失敗，標記為失敗
      final updatedDoc = state.firstWhere((d) => d.id == documentId);
      updateDocument(updatedDoc.markAsFailed(e.toString()));
    }
  }

  /// 重新索引失敗的文件
  Future<void> reindexDocument(String documentId) async {
    await _startIndexing(documentId);
  }

  /// 清空所有文件
  void clearAll() {
    state = [];
    // TODO: 呼叫 API 清空所有向量資料
  }
}

/// 知識庫統計資訊 Provider
///
/// 衍生 provider，提供統計資訊
@riverpod
({
  int total,
  int indexed,
  int indexing,
  int failed,
}) knowledgeStats(ref) {
  final documents = ref.watch(knowledgeDocumentsProvider);

  return (
    total: documents.length,
    indexed: documents.where((d) => d.status == DocumentStatus.indexed).length,
    indexing: documents.where((d) => d.status == DocumentStatus.indexing).length,
    failed: documents.where((d) => d.status == DocumentStatus.failed).length,
  );
}

/// 可刪除的文件列表 Provider
///
/// 只顯示可以刪除的文件（排除正在索引的）
@riverpod
List<KnowledgeDocument> deletableDocuments(ref) {
  final documents = ref.watch(knowledgeDocumentsProvider);
  return documents.where((doc) => doc.canDelete).toList();
}
