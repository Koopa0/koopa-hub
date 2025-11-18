import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/knowledge_document.dart';
import '../../chat/providers/chat_provider.dart'; // 用於 apiClient

part 'knowledge_provider.g.dart';

/// 知識庫文件列表 Provider
///
/// 使用同步 Notifier 並整合 Hive 持久化
@riverpod
class KnowledgeDocuments extends _$KnowledgeDocuments {
  late Box<KnowledgeDocument> _box;

  @override
  List<KnowledgeDocument> build() {
    _box = Hive.box<KnowledgeDocument>('knowledge_documents');

    // 從 Hive 載入文件列表
    final documents = _box.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

    // 如果是第一次使用，建立示範文件
    if (documents.isEmpty) {
      final demoDocs = _createDemoDocuments();
      for (final doc in demoDocs) {
        _box.put(doc.id, doc);
      }
      return demoDocs;
    }

    return documents;
  }

  /// 建立示範文件（僅在首次使用時）
  List<KnowledgeDocument> _createDemoDocuments() {
    return [
      KnowledgeDocument.create(
        path: '/documents/flutter_guide.pdf',
        size: 2048576,
      ).markAsIndexed(
        summary: 'Flutter 開發完整指南，涵蓋基礎概念、狀態管理、路由導航等核心主題',
        vectorCount: 125,
      ),
      KnowledgeDocument.create(
        path: '/documents/riverpod_tutorial.md',
        size: 512000,
      ).markAsIndexed(
        summary: 'Riverpod 3.0 使用教學，包含程式碼生成和最佳實踐',
        vectorCount: 68,
      ),
      KnowledgeDocument.create(
        path: '/documents/design_patterns.txt',
        size: 1024000,
      ).markAsIndexing(),
      KnowledgeDocument.create(
        path: '/data/api_documentation.json',
        size: 256000,
      ).markAsIndexed(
        summary: 'API 文件集合，包含所有端點的詳細說明和範例',
        vectorCount: 42,
      ),
    ];
  }

  /// 添加文件
  ///
  /// 同時更新 state 和 Hive Box
  void addDocument({
    required String path,
    required int size,
  }) {
    final newDoc = KnowledgeDocument.create(
      path: path,
      size: size,
    );

    // 1. 持久化到 Hive
    _box.put(newDoc.id, newDoc);

    // 2. 更新 UI 狀態
    state = [...state, newDoc];

    // 自動開始索引
    _startIndexing(newDoc.id);
  }

  /// 添加多個文件
  void addDocuments(List<({String path, int size})> files) {
    final newDocs = files.map((file) {
      return KnowledgeDocument.create(
        path: file.path,
        size: file.size,
      );
    }).toList();

    // 1. 批次持久化到 Hive
    for (final doc in newDocs) {
      _box.put(doc.id, doc);
    }

    // 2. 更新 UI 狀態
    state = [...state, ...newDocs];

    // 批次索引
    for (final doc in newDocs) {
      _startIndexing(doc.id);
    }
  }

  /// 刪除文件
  Future<void> removeDocument(String documentId) async {
    // 呼叫 API 刪除向量資料
    final apiClient = ref.read(apiClientProvider);
    await apiClient.deleteDocument(documentId);

    // 1. 從 Hive 刪除
    _box.delete(documentId);

    // 2. 更新 UI 狀態
    state = state.where((doc) => doc.id != documentId).toList();
  }

  /// 更新文件狀態
  void updateDocument(KnowledgeDocument updatedDoc) {
    // 1. 持久化到 Hive
    _box.put(updatedDoc.id, updatedDoc);

    // 2. 更新 UI 狀態
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
      // 2. 呼叫 API 進行索引
      final apiClient = ref.read(apiClientProvider);
      final result = await apiClient.indexDocument(
        path: doc.path,
        size: doc.size,
      );

      // 3. 標記為完成
      final updatedDoc = state.firstWhere((d) => d.id == documentId);
      updateDocument(updatedDoc.markAsIndexed(
        summary: result['summary'] as String,
        vectorCount: result['vectorCount'] as int,
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
  Future<void> clearAll() async {
    // 呼叫 API 清空所有向量資料
    final apiClient = ref.read(apiClientProvider);
    await apiClient.clearAllDocuments();

    // 1. 清空 Hive Box
    await _box.clear();

    // 2. 更新 UI 狀態
    state = [];
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
}) knowledgeStats(Ref ref) {
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
List<KnowledgeDocument> deletableDocuments(Ref ref) {
  final documents = ref.watch(knowledgeDocumentsProvider);
  return documents.where((doc) => doc.canDelete).toList();
}
