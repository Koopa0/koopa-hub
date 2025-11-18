import 'package:uuid/uuid.dart';
import '../widgets/thinking_steps.dart';
import '../widgets/tool_calling.dart';
import '../widgets/source_card.dart';
import 'artifact.dart';

/// 訊息類型枚舉
/// 定義三種訊息類型：使用者、助理、系統
enum MessageType {
  user('user'),
  assistant('assistant'),
  system('system');

  const MessageType(this.value);
  final String value;
}

/// 聊天訊息模型
///
/// 這是一個不可變的 (immutable) 資料類別，使用 final 關鍵字確保資料一致性。
/// 在 Flutter 中，不可變類別是最佳實踐，因為它們：
/// 1. 更容易進行狀態管理
/// 2. 避免意外的副作用
/// 3. 提升效能（可以使用 const 建構子）
class Message {
  /// 唯一識別碼，使用 UUID 確保全域唯一性
  final String id;

  /// 訊息內容
  final String content;

  /// 訊息類型（使用者/助理/系統）
  final MessageType type;

  /// 創建時間戳，使用 DateTime 處理時區和格式化
  final DateTime timestamp;

  /// 引用來源列表（用於 RAG 功能，顯示資料來源）
  /// 使用 List<String> 儲存多個來源 URL 或檔案路徑
  final List<String> citations;

  /// 是否正在串流中（用於顯示打字動畫）
  final bool isStreaming;

  /// AI 思考步驟（用於顯示推理過程）
  final List<ThinkingStep>? thinkingSteps;

  /// 工具調用列表（用於顯示工具使用過程）
  final List<ToolCall>? toolCalls;

  /// 來源引用列表（用於顯示網頁搜尋結果）
  final List<SourceCitation>? sources;

  /// Artifact（AI 生成的內容）
  final Artifact? artifact;

  /// 私有建構子，強制使用命名建構子
  /// 這是一個好的設計模式，可以提供更清晰的 API
  const Message._({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.citations = const [],
    this.isStreaming = false,
    this.thinkingSteps,
    this.toolCalls,
    this.sources,
    this.artifact,
  });

  /// 工廠建構子：建立使用者訊息
  ///
  /// 工廠建構子的優點：
  /// 1. 可以返回快取的實例
  /// 2. 可以返回子類別實例
  /// 3. 提供更語義化的 API
  factory Message.user(String content) {
    return Message._(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  /// 工廠建構子：建立助理訊息
  factory Message.assistant(
    String content, {
    List<String> citations = const [],
    bool isStreaming = false,
  }) {
    return Message._(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      citations: citations,
      isStreaming: isStreaming,
    );
  }

  /// 工廠建構子：建立系統訊息
  factory Message.system(String content) {
    return Message._(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
  }

  /// copyWith 方法：建立修改過的副本
  ///
  /// 這是不可變類別的核心模式。因為欄位是 final，
  /// 我們不能直接修改它們，所以需要建立一個新的實例。
  ///
  /// 使用方式：
  /// final newMessage = oldMessage.copyWith(content: 'new content');
  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    List<String>? citations,
    bool? isStreaming,
    List<ThinkingStep>? thinkingSteps,
    List<ToolCall>? toolCalls,
    List<SourceCitation>? sources,
    Artifact? artifact,
  }) {
    return Message._(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      citations: citations ?? this.citations,
      isStreaming: isStreaming ?? this.isStreaming,
      thinkingSteps: thinkingSteps ?? this.thinkingSteps,
      toolCalls: toolCalls ?? this.toolCalls,
      sources: sources ?? this.sources,
      artifact: artifact ?? this.artifact,
    );
  }

  /// JSON 序列化：將物件轉換為 Map
  /// 用於儲存到本地或發送到伺服器
  /// 注意：thinkingSteps, toolCalls, sources, artifact 是暫時性資料，不需要持久化
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.value,
      'timestamp': timestamp.toIso8601String(),
      'citations': citations,
      'isStreaming': isStreaming,
      // thinkingSteps, toolCalls, sources, artifact 不序列化（僅用於 UI 顯示）
    };
  }

  /// JSON 反序列化：從 Map 建立物件
  ///
  /// 工廠建構子用於從 JSON 建立實例
  /// 使用 ?? 運算子提供預設值，增加容錯性
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message._(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      citations: (json['citations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  /// 重寫 == 運算子和 hashCode
  /// 這對於在集合中比較物件很重要
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 重寫 toString 方便除錯
  @override
  String toString() {
    return 'Message(id: $id, type: ${type.value}, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
