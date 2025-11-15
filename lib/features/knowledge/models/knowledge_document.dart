import 'package:uuid/uuid.dart';

/// 文件狀態枚舉
///
/// 追蹤文件的索引狀態
enum DocumentStatus {
  /// 等待索引
  pending('pending', '等待索引'),

  /// 索引中
  indexing('indexing', '索引中...'),

  /// 索引完成
  indexed('indexed', '已索引'),

  /// 索引失敗
  failed('failed', '失敗'),

  /// 已刪除
  deleted('deleted', '已刪除');

  const DocumentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  /// 從字串值獲取枚舉
  static DocumentStatus fromValue(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DocumentStatus.pending,
    );
  }
}

/// 知識庫文件模型
///
/// 代表一個被索引的文件或目錄
/// 對應設計文件中的 RAG 功能需求
class KnowledgeDocument {
  /// 文件唯一識別碼
  final String id;

  /// 文件名稱
  final String name;

  /// 文件路徑（可以是檔案或目錄）
  final String path;

  /// 文件類型（副檔名）
  /// 例如：.txt, .md, .pdf, .docx
  final String type;

  /// 文件大小（bytes）
  final int size;

  /// 索引狀態
  final DocumentStatus status;

  /// 添加時間
  final DateTime addedAt;

  /// 最後索引時間
  final DateTime? indexedAt;

  /// 錯誤訊息（如果索引失敗）
  final String? errorMessage;

  /// 文件摘要（從內容提取的摘要）
  final String? summary;

  /// 向量數量（索引後的向量片段數量）
  final int? vectorCount;

  /// 私有建構子
  const KnowledgeDocument._({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.status,
    required this.addedAt,
    this.indexedAt,
    this.errorMessage,
    this.summary,
    this.vectorCount,
  });

  /// 工廠建構子：建立新文件
  ///
  /// 自動從路徑提取文件名稱和類型
  factory KnowledgeDocument.create({
    required String path,
    required int size,
  }) {
    // 從路徑提取文件名
    final name = path.split('/').last;

    // 從文件名提取副檔名
    final type = name.contains('.')
        ? '.${name.split('.').last}'
        : ''; // 無副檔名則為空字串

    return KnowledgeDocument._(
      id: const Uuid().v4(),
      name: name,
      path: path,
      type: type,
      size: size,
      status: DocumentStatus.pending,
      addedAt: DateTime.now(),
    );
  }

  /// copyWith 方法
  KnowledgeDocument copyWith({
    String? id,
    String? name,
    String? path,
    String? type,
    int? size,
    DocumentStatus? status,
    DateTime? addedAt,
    DateTime? indexedAt,
    String? errorMessage,
    String? summary,
    int? vectorCount,
  }) {
    return KnowledgeDocument._(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      indexedAt: indexedAt ?? this.indexedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      summary: summary ?? this.summary,
      vectorCount: vectorCount ?? this.vectorCount,
    );
  }

  /// 便利方法：標記為索引中
  KnowledgeDocument markAsIndexing() {
    return copyWith(
      status: DocumentStatus.indexing,
      errorMessage: null, // 清除之前的錯誤
    );
  }

  /// 便利方法：標記為索引完成
  KnowledgeDocument markAsIndexed({
    String? summary,
    int? vectorCount,
  }) {
    return copyWith(
      status: DocumentStatus.indexed,
      indexedAt: DateTime.now(),
      summary: summary,
      vectorCount: vectorCount,
      errorMessage: null,
    );
  }

  /// 便利方法：標記為失敗
  KnowledgeDocument markAsFailed(String error) {
    return copyWith(
      status: DocumentStatus.failed,
      errorMessage: error,
    );
  }

  /// Getter：格式化文件大小
  ///
  /// 將 bytes 轉換為人類可讀的格式
  /// 例如：1024 bytes -> 1 KB
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Getter：是否可以刪除
  ///
  /// 只有在索引完成或失敗時才能刪除
  /// 索引中的文件不應該被刪除
  bool get canDelete => status != DocumentStatus.indexing;

  /// Getter：是否可以重新索引
  ///
  /// 失敗的文件可以重新索引
  bool get canReindex => status == DocumentStatus.failed;

  /// JSON 序列化
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'status': status.value,
      'addedAt': addedAt.toIso8601String(),
      'indexedAt': indexedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'summary': summary,
      'vectorCount': vectorCount,
    };
  }

  /// JSON 反序列化
  factory KnowledgeDocument.fromJson(Map<String, dynamic> json) {
    return KnowledgeDocument._(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      status: DocumentStatus.fromValue(json['status'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
      indexedAt: json['indexedAt'] != null
          ? DateTime.parse(json['indexedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      summary: json['summary'] as String?,
      vectorCount: json['vectorCount'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KnowledgeDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'KnowledgeDocument(id: $id, name: $name, status: ${status.displayName})';
  }
}
