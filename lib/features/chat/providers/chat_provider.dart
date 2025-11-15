import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

// 這行是必須的，用於程式碼生成
// 執行 'dart run build_runner watch' 來生成程式碼
part 'chat_provider.g.dart';

/// 聊天會話列表 Provider
///
/// 使用 @riverpod 註解來自動生成 provider
/// 這是 Riverpod 2.x 的新特性，比手動建立 provider 更簡潔
///
/// 優點：
/// 1. 自動生成 provider
/// 2. 類型安全
/// 3. 減少樣板程式碼
/// 4. 支援程式碼補全
@riverpod
class ChatSessions extends _$ChatSessions {
  /// build 方法：初始化狀態
  ///
  /// 這個方法只會在 provider 第一次被讀取時呼叫
  /// 返回值就是這個 provider 的初始狀態
  @override
  List<ChatSession> build() {
    // TODO: 從本地儲存（Hive）載入會話列表
    // 現在先返回一個示範會話
    return [
      ChatSession.create(
        title: '歡迎使用 Koopa Assistant',
      ),
    ];
  }

  /// 建立新會話
  ///
  /// 使用 state = ... 來更新狀態
  /// Riverpod 會自動通知所有監聽者
  void createSession({String? title}) {
    final newSession = ChatSession.create(
      title: title ?? '新對話 ${state.length + 1}',
    );

    // 使用擴展運算子 [...] 建立新列表
    // 這是不可變更新的最佳實踐
    state = [newSession, ...state];
  }

  /// 刪除會話
  void deleteSession(String sessionId) {
    // 使用 where 過濾掉要刪除的會話
    state = state.where((s) => s.id != sessionId).toList();
  }

  /// 更新會話
  ///
  /// 使用 map 來更新特定會話
  /// 這個模式在 Flutter 狀態管理中非常常見
  void updateSession(ChatSession updatedSession) {
    state = state.map((session) {
      return session.id == updatedSession.id ? updatedSession : session;
    }).toList();
  }

  /// 清除會話的訊息
  void clearSessionMessages(String sessionId) {
    state = state.map((session) {
      return session.id == sessionId ? session.clearMessages() : session;
    }).toList();
  }

  /// 切換會話的置頂狀態
  void toggleSessionPin(String sessionId) {
    state = state.map((session) {
      return session.id == sessionId ? session.togglePin() : session;
    }).toList();
  }

  /// 獲取特定會話
  ///
  /// 這不會改變狀態，只是一個查詢方法
  ChatSession? getSession(String sessionId) {
    try {
      return state.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }
}

/// 當前活躍會話 ID Provider
///
/// 使用 StateProvider 來管理簡單的狀態
/// StateProvider 適合用於：
/// 1. 簡單的值（String, int, bool 等）
/// 2. 需要從 UI 直接更新的狀態
final currentSessionIdProvider = StateProvider<String?>((ref) {
  // 監聽會話列表
  final sessions = ref.watch(chatSessionsProvider);

  // 如果沒有選中的會話，自動選擇第一個
  if (sessions.isEmpty) return null;
  return sessions.first.id;
});

/// 當前會話 Provider
///
/// 這是一個衍生 Provider（derived provider）
/// 它基於其他 provider 的值來計算自己的值
///
/// 優點：
/// 1. 自動重新計算
/// 2. 避免重複的狀態
/// 3. 保持資料的單一來源（single source of truth）
final currentSessionProvider = Provider<ChatSession?>((ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) return null;

  final sessions = ref.watch(chatSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.id == sessionId);
  } catch (e) {
    return null;
  }
});

/// 當前會話的訊息列表 Provider
///
/// 另一個衍生 provider
/// 直接提供當前會話的訊息列表，簡化 UI 層的程式碼
final currentMessagesProvider = Provider<List<Message>>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.messages ?? [];
});

/// 聊天服務 Provider（用於發送訊息）
///
/// 這會在後續實作時連接到 HTTP API
@riverpod
class ChatService extends _$ChatService {
  @override
  FutureOr<void> build() {
    // 初始化聊天服務
    // TODO: 連接到 koopa-server API
  }

  /// 發送訊息
  ///
  /// 這是一個異步方法，會：
  /// 1. 添加使用者訊息
  /// 2. 呼叫 API
  /// 3. 接收串流回應
  /// 4. 更新 AI 訊息
  Future<void> sendMessage(String content) async {
    // 獲取當前會話
    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) return;

    final session = ref.read(chatSessionsProvider.notifier).getSession(
          sessionId,
        );
    if (session == null) return;

    // 1. 添加使用者訊息
    final userMessage = Message.user(content);
    final updatedSession = session.addMessage(userMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(updatedSession);

    // 2. 添加一個空的 AI 訊息（用於串流）
    final aiMessage = Message.assistant('', isStreaming: true);
    final sessionWithAi = updatedSession.addMessage(aiMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(sessionWithAi);

    // TODO: 3. 呼叫 API 並處理串流回應
    // 這裡先用模擬回應
    await Future.delayed(const Duration(seconds: 1));

    final mockResponse = '這是一個模擬回應。真實的 API 整合將在後端完成後實作。';
    final completedMessage = aiMessage.copyWith(
      content: mockResponse,
      isStreaming: false,
    );

    final finalSession = sessionWithAi.updateLastMessage(completedMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(finalSession);

    // 4. 如果是第一條訊息，自動更新標題
    if (session.messages.isEmpty) {
      final title = content.length > 30
          ? '${content.substring(0, 30)}...'
          : content;
      final sessionWithTitle = finalSession.updateTitle(title);
      ref.read(chatSessionsProvider.notifier).updateSession(sessionWithTitle);
    }
  }
}
