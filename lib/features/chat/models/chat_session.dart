import 'package:uuid/uuid.dart';
import 'message.dart';

/// AI 模型類型枚舉
///
/// 根據設計文件定義三種模式：
/// - 本地 RAG：使用本地 pgvector 資料庫
/// - 網路搜尋：使用 httpGet 工具進行即時網路搜尋
/// - Gemini 雲端：直接呼叫 Gemini API
enum AIModel {
  localRag('Koopa (本地 RAG)'),
  webSearch('Koopa (網路搜尋)'),
  gemini('Gemini (雲端)');

  const AIModel(this.displayName);
  final String displayName;

  /// 從顯示名稱獲取枚舉值
  static AIModel fromDisplayName(String name) {
    return AIModel.values.firstWhere(
      (e) => e.displayName == name,
      orElse: () => AIModel.localRag,
    );
  }
}

/// 聊天會話模型
///
/// 代表一個完整的對話會話，包含所有訊息和設定。
/// 使用不可變模式確保狀態的可預測性。
class ChatSession {
  /// 會話唯一識別碼
  final String id;

  /// 會話標題（通常取自第一個使用者訊息）
  final String title;

  /// 訊息列表
  ///
  /// 使用 List<Message> 而不是 List<dynamic> 確保類型安全
  /// 在 Dart 3.0+，強類型可以讓編譯器幫我們抓到更多錯誤
  final List<Message> messages;

  /// 選擇的 AI 模型
  final AIModel selectedModel;

  /// 會話建立時間
  final DateTime createdAt;

  /// 最後更新時間（用於排序會話列表）
  final DateTime updatedAt;

  /// 是否已釘選（置頂功能）
  final bool isPinned;

  /// 私有建構子
  const ChatSession._({
    required this.id,
    required this.title,
    required this.messages,
    required this.selectedModel,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  /// 工廠建構子：建立新會話
  ///
  /// 使用預設值簡化物件建立：
  /// - title 預設為「新對話」
  /// - messages 預設為空列表
  /// - selectedModel 預設為本地 RAG
  factory ChatSession.create({
    String title = '新對話',
    AIModel selectedModel = AIModel.localRag,
  }) {
    final now = DateTime.now();
    return ChatSession._(
      id: const Uuid().v4(),
      title: title,
      messages: [],
      selectedModel: selectedModel,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// copyWith 方法：建立修改過的副本
  ///
  /// 支援所有欄位的選擇性更新
  ChatSession copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    AIModel? selectedModel,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ChatSession._(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// 便利方法：添加訊息
  ///
  /// 返回一個新的會話實例，包含新訊息並更新時間戳
  /// 這是函數式編程的風格，避免修改原始物件
  ChatSession addMessage(Message message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// 便利方法：更新最後一條訊息
  ///
  /// 用於串流場景，逐步更新 AI 回應
  /// 使用 List.sublist 和擴展運算子 [...] 建立新列表
  ChatSession updateLastMessage(Message message) {
    if (messages.isEmpty) return this;

    return copyWith(
      messages: [...messages.sublist(0, messages.length - 1), message],
      updatedAt: DateTime.now(),
    );
  }

  /// 便利方法：清除所有訊息
  ChatSession clearMessages() {
    return copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
  }

  /// 便利方法：更新標題
  ///
  /// 通常在第一條使用者訊息後自動生成標題
  ChatSession updateTitle(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }

  /// 便利方法：切換置頂狀態
  ChatSession togglePin() {
    return copyWith(
      isPinned: !isPinned,
      updatedAt: DateTime.now(),
    );
  }

  /// Getter：獲取最後一條訊息的預覽
  ///
  /// 用於會話列表顯示
  /// 使用 ?? 運算子提供預設值
  String get lastMessagePreview {
    if (messages.isEmpty) return '開始新對話...';

    final lastMessage = messages.last;
    final preview = lastMessage.content.replaceAll('\n', ' ');

    // 限制預覽長度為 50 個字元
    return preview.length > 50 ? '${preview.substring(0, 50)}...' : preview;
  }

  /// Getter：訊息數量
  int get messageCount => messages.length;

  /// JSON 序列化
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'selectedModel': selectedModel.displayName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  /// JSON 反序列化
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession._(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      selectedModel:
          AIModel.fromDisplayName(json['selectedModel'] as String? ?? ''),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatSession(id: $id, title: $title, messages: ${messages.length}, model: ${selectedModel.displayName})';
  }
}
