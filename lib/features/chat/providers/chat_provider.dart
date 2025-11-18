import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../../../core/services/enhanced_mock_api.dart';
import '../widgets/thinking_steps.dart';
import '../widgets/tool_calling.dart';
import '../widgets/source_card.dart';
import '../models/artifact.dart';

// 這行是必須的，用於程式碼生成
// 執行 'dart run build_runner watch' 來生成程式碼
part 'chat_provider.g.dart';

/// 聊天會話列表 Provider
///
/// 使用同步 Notifier 並整合 Hive 持久化
///
/// 實作要點：
/// 1. build 方法同步從 Hive Box 讀取初始狀態
/// 2. 所有寫入方法同時更新 state 和 Hive Box
/// 3. 提供更好的性能和可靠性
@riverpod
class ChatSessions extends _$ChatSessions {
  late Box<ChatSession> _box;

  /// build 方法：同步載入初始狀態
  ///
  /// 從 Hive Box 同步讀取所有會話
  /// 按更新時間排序（最新的在前）
  @override
  List<ChatSession> build() {
    _box = Hive.box<ChatSession>('chat_sessions');

    // 從 Hive 載入會話列表
    final sessions = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // 如果是第一次使用，建立示範會話
    if (sessions.isEmpty) {
      final demoSession = _createDemoSession();
      _box.put(demoSession.id, demoSession);
      return [demoSession];
    }

    return sessions;
  }

  /// 建立示範會話（僅在首次使用時）
  ChatSession _createDemoSession() {
    final demoSession = ChatSession.create(
      title: '歡迎使用 Koopa Hub',
    );

    final userMessage1 = Message.user('什麼是 Flutter 的狀態管理？');
    final aiMessage1 = Message.assistant(
      'Flutter 提供多種狀態管理方案，包括：\n\n'
      '1. **Provider** - Google 官方推薦的狀態管理方案\n'
      '2. **Riverpod** - Provider 的改進版，提供更好的類型安全\n'
      '3. **Bloc** - 使用事件驅動的狀態管理\n'
      '4. **GetX** - 輕量級的狀態管理和路由方案\n\n'
      '在這個專案中，我們使用 **Riverpod 3.0** 配合程式碼生成，'
      '提供類型安全和更簡潔的 API。',
      citations: [
        'Flutter 官方文件 - 狀態管理',
        'Riverpod 文件',
        'Flutter 實戰指南',
      ],
    );

    final userMessage2 = Message.user('可以舉個 Riverpod 的例子嗎？');
    final aiMessage2 = Message.assistant(
      '當然！這是一個簡單的 Riverpod 範例：\n\n'
      '```dart\n'
      '@riverpod\n'
      'class Counter extends _\$Counter {\n'
      '  @override\n'
      '  int build() => 0;\n'
      '\n'
      '  void increment() => state++;\n'
      '  void decrement() => state--;\n'
      '}\n'
      '```\n\n'
      '在 UI 中使用：\n\n'
      '```dart\n'
      'final count = ref.watch(counterProvider);\n'
      '```\n\n'
      '點擊訊息上方的操作列可以複製、編輯或刪除訊息！',
      citations: [
        'Riverpod 程式碼生成指南',
      ],
    );

    return demoSession
        .addMessage(userMessage1)
        .addMessage(aiMessage1)
        .addMessage(userMessage2)
        .addMessage(aiMessage2);
  }

  /// 建立新會話
  ///
  /// 同時更新 state 和 Hive Box
  void createSession({String? title}) {
    final newSession = ChatSession.create(
      title: title ?? '新對話 ${state.length + 1}',
    );

    // 1. 持久化到 Hive
    _box.put(newSession.id, newSession);

    // 2. 更新 UI 狀態
    state = [newSession, ...state];
  }

  /// 刪除會話
  void deleteSession(String sessionId) {
    // 1. 從 Hive 刪除
    _box.delete(sessionId);

    // 2. 更新 UI 狀態
    state = state.where((s) => s.id != sessionId).toList();
  }

  /// 更新會話
  void updateSession(ChatSession updatedSession) {
    // 1. 持久化到 Hive
    _box.put(updatedSession.id, updatedSession);

    // 2. 更新 UI 狀態
    state = state.map((session) {
      return session.id == updatedSession.id ? updatedSession : session;
    }).toList();
  }

  /// 添加訊息到會話
  void addMessage(String sessionId, Message message) {
    final session = getSession(sessionId);
    if (session == null) return;

    final updatedSession = session.addMessage(message);
    updateSession(updatedSession);
  }

  /// 清除會話的訊息
  void clearSessionMessages(String sessionId) {
    final session = getSession(sessionId);
    if (session == null) return;

    final updatedSession = session.clearMessages();
    updateSession(updatedSession);
  }

  /// 切換會話的置頂狀態
  void toggleSessionPin(String sessionId) {
    final session = getSession(sessionId);
    if (session == null) return;

    final updatedSession = session.togglePin();
    updateSession(updatedSession);
  }

  /// 獲取特定會話
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
/// 使用 Riverpod 3.0 code generation 來管理簡單的狀態
/// 管理當前選擇的會話 ID
@riverpod
class CurrentSessionId extends _$CurrentSessionId {
  @override
  String? build() {
    // 監聽會話列表
    final sessions = ref.watch(chatSessionsProvider);

    // 如果沒有選中的會話，自動選擇第一個
    if (sessions.isEmpty) return null;
    return sessions.first.id;
  }

  void setSessionId(String? id) => state = id;
}

/// 當前會話 Provider
///
/// 這是一個衍生 Provider（derived provider）
/// 它基於其他 provider 的值來計算自己的值
///
/// 優點：
/// 1. 自動重新計算
/// 2. 避免重複的狀態
/// 3. 保持資料的單一來源（single source of truth）
@riverpod
ChatSession? currentSession(Ref ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) return null;

  final sessions = ref.watch(chatSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.id == sessionId);
  } catch (e) {
    return null;
  }
}

/// 當前會話的訊息列表 Provider
///
/// 另一個衍生 provider
/// 直接提供當前會話的訊息列表，簡化 UI 層的程式碼
@riverpod
List<Message> currentMessages(Ref ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.messages ?? [];
}

/// Enhanced Mock API Provider
@riverpod
EnhancedMockApi enhancedMockApi(Ref ref) {
  return EnhancedMockApi();
}

/// Artifact 側邊欄狀態 Provider
///
/// 管理側邊欄的顯示/隱藏和當前顯示的 Artifact
@riverpod
class ArtifactSidebar extends _$ArtifactSidebar {
  @override
  Artifact? build() {
    return null;
  }

  /// 顯示 Artifact
  void showArtifact(Artifact artifact) {
    state = artifact;
  }

  /// 隱藏側邊欄
  void hide() {
    state = null;
  }

  /// 切換顯示狀態
  void toggle() {
    state = null;
  }
}

/// 聊天服務 Provider（用於發送訊息）
///
/// 使用 Mock API 提供流式響應
@riverpod
class ChatService extends _$ChatService {
  @override
  FutureOr<void> build() {
    // 初始化聊天服務
  }

  /// 發送訊息（使用 Enhanced Mock API）
  ///
  /// 處理多種事件類型：
  /// 1. 添加使用者訊息
  /// 2. 處理思考步驟（thinkingStep）
  /// 3. 處理工具調用（toolCall）
  /// 4. 處理搜尋進度（searchProgress）
  /// 5. 處理來源引用（sources）
  /// 6. 處理文字串流（textChunk）
  /// 7. 處理 Artifacts（artifact）
  /// 8. 完成標記（complete）
  Future<void> sendMessage(String content) async {
    // 驗證輸入
    if (content.trim().isEmpty) {
      debugPrint('Cannot send empty message');
      return;
    }

    // 獲取當前會話
    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) {
      debugPrint('No session selected');
      return;
    }

    final session = ref.read(chatSessionsProvider.notifier).getSession(
          sessionId,
        );
    if (session == null) {
      debugPrint('Session not found: $sessionId');
      return;
    }

    // 1. 添加使用者訊息
    final userMessage = Message.user(content);
    final updatedSession = session.addMessage(userMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(updatedSession);

    // 2. 添加一個空的 AI 訊息（用於串流）
    final aiMessage = Message.assistant('', isStreaming: true);
    var sessionWithAi = updatedSession.addMessage(aiMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(sessionWithAi);

    try {
      // 3. 呼叫 Enhanced Mock API
      final api = ref.read(enhancedMockApiProvider);

      final stream = api.sendChatMessage(
        message: content,
        sessionId: sessionId,
        model: session.selectedModel.name,
      );

      // 暫存的資料，用於累積事件
      List<ThinkingStep>? thinkingSteps;
      List<ToolCall>? toolCalls;
      List<SourceCitation>? sources;
      Artifact? artifact;
      String textContent = '';

      // 4. 處理事件流
      await for (final event in stream) {
        // ✅ 檢查 provider 是否仍然存在（避免 disposal 錯誤）
        if (!ref.mounted) {
          debugPrint('Provider disposed, stopping stream processing');
          break;
        }

        switch (event.type) {
          case ResponseEventType.thinkingStep:
            // 更新思考步驟
            thinkingSteps = List<ThinkingStep>.from(event.data);
            _updateMessage(
              sessionId,
              aiMessage,
              textContent,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );
            break;

          case ResponseEventType.toolCall:
            // 添加或更新工具調用
            final toolCall = event.data as ToolCall;
            if (toolCalls == null) {
              toolCalls = [toolCall];
            } else {
              // 查找並更新或添加
              final index =
                  toolCalls.indexWhere((tc) => tc.toolName == toolCall.toolName);
              if (index >= 0) {
                toolCalls[index] = toolCall;
              } else {
                toolCalls.add(toolCall);
              }
            }
            _updateMessage(
              sessionId,
              aiMessage,
              textContent,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );
            break;

          case ResponseEventType.searchProgress:
            // 搜尋進度可以顯示在文字中（可選）
            // 或者可以忽略，因為有 toolCall 事件
            break;

          case ResponseEventType.sources:
            // 添加來源引用
            sources = List<SourceCitation>.from(event.data);
            _updateMessage(
              sessionId,
              aiMessage,
              textContent,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );
            break;

          case ResponseEventType.textChunk:
            // 更新文字內容
            textContent = event.data as String;
            _updateMessage(
              sessionId,
              aiMessage,
              textContent,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );
            break;

          case ResponseEventType.artifact:
            // 添加 Artifact
            final artifactData = event.data as Map<String, dynamic>;
            artifact = Artifact(
              id: aiMessage.id + '_artifact',
              title: artifactData['title'] as String,
              type: ArtifactType.values.firstWhere(
                (e) => e.name == artifactData['type'],
                orElse: () => ArtifactType.code,
              ),
              content: artifactData['content'] as String,
              language: artifactData['language'] as String?,
              createdAt: DateTime.now(),
            );
            _updateMessage(
              sessionId,
              aiMessage,
              textContent,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );
            break;

          case ResponseEventType.complete:
            // ✅ 檢查 provider 是否仍然存在
            if (!ref.mounted) break;

            // 標記為完成
            final completedMessage = aiMessage.copyWith(
              content: textContent,
              isStreaming: false,
              thinkingSteps: thinkingSteps,
              toolCalls: toolCalls,
              sources: sources,
              artifact: artifact,
            );

            final finalSession = ref.read(chatSessionsProvider.notifier).getSession(sessionId);
            if (finalSession != null) {
              final completedSession = finalSession.updateLastMessage(completedMessage);
              ref.read(chatSessionsProvider.notifier).updateSession(completedSession);

              // 如果是第一條訊息，自動更新標題
              if (session.messages.isEmpty) {
                final title = content.length > 30
                    ? '${content.substring(0, 30)}...'
                    : content;
                final sessionWithTitle = completedSession.updateTitle(title);
                ref.read(chatSessionsProvider.notifier).updateSession(sessionWithTitle);
              }
            }
            break;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to send message: $e');
      debugPrint('Stack trace: $stackTrace');

      // ✅ 檢查 provider 是否仍然存在
      if (!ref.mounted) return;

      // 生成友善的錯誤訊息
      final friendlyError = _getFriendlyErrorMessage(e);

      // 更新 AI 訊息為錯誤狀態
      final errorMessage = aiMessage.copyWith(
        content: friendlyError,
        isStreaming: false,
      );

      final errorSession = sessionWithAi.updateLastMessage(errorMessage);
      ref.read(chatSessionsProvider.notifier).updateSession(errorSession);
    }
  }

  /// 生成友善的錯誤訊息
  String _getFriendlyErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();

    // 網路錯誤
    if (errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return '❌ 網路連線問題\n\n'
          '無法連接到伺服器，請檢查您的網路連線。\n\n'
          '💡 建議：\n'
          '• 檢查網路連線是否正常\n'
          '• 稍後再試\n'
          '• 重新整理頁面';
    }

    // Timeout 錯誤
    if (errorStr.contains('timeout')) {
      return '❌ 請求超時\n\n'
          '伺服器回應時間過長。\n\n'
          '💡 建議：\n'
          '• 請稍後再試\n'
          '• 嘗試簡化您的問題';
    }

    // Provider 錯誤
    if (errorStr.contains('disposed') || errorStr.contains('provider')) {
      return '❌ 系統狀態錯誤\n\n'
          '應用程式狀態已重置。\n\n'
          '💡 建議：\n'
          '• 重新發送訊息即可\n'
          '• 如果問題持續，請重新整理頁面';
    }

    // 權限錯誤
    if (errorStr.contains('permission') || errorStr.contains('forbidden')) {
      return '❌ 權限不足\n\n'
          '您沒有執行此操作的權限。\n\n'
          '💡 建議：\n'
          '• 檢查您的帳戶權限\n'
          '• 聯繫管理員';
    }

    // 一般錯誤
    return '❌ 發生錯誤\n\n'
        '處理您的請求時遇到問題。\n\n'
        '💡 建議：\n'
        '• 重新發送訊息\n'
        '• 嘗試不同的問題\n'
        '• 如果問題持續，請聯繫支援\n\n'
        '錯誤詳情：${error.toString()}';
  }

  /// 輔助方法：更新訊息
  void _updateMessage(
    String sessionId,
    Message aiMessage,
    String content, {
    List<ThinkingStep>? thinkingSteps,
    List<ToolCall>? toolCalls,
    List<SourceCitation>? sources,
    Artifact? artifact,
  }) {
    // ✅ 檢查 provider 是否仍然存在
    if (!ref.mounted) return;

    final streamingMessage = aiMessage.copyWith(
      content: content,
      isStreaming: true,
      thinkingSteps: thinkingSteps,
      toolCalls: toolCalls,
      sources: sources,
      artifact: artifact,
    );

    final currentSession =
        ref.read(chatSessionsProvider.notifier).getSession(sessionId);
    if (currentSession == null) return;

    final updatedStreamSession =
        currentSession.updateLastMessage(streamingMessage);
    ref.read(chatSessionsProvider.notifier).updateSession(
          updatedStreamSession,
        );
  }
}
