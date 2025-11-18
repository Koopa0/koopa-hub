import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../features/chat/widgets/thinking_steps.dart';
import '../../features/chat/widgets/source_card.dart';
import '../../features/chat/widgets/tool_calling.dart';

/// Enhanced response event types
enum ResponseEventType {
  thinkingStep,
  toolCall,
  searchProgress,
  sources,
  textChunk,
  artifact,
  complete,
}

/// Enhanced response event
class ResponseEvent {
  final ResponseEventType type;
  final dynamic data;

  const ResponseEvent(this.type, this.data);
}

/// Enhanced Mock API with interactive demonstrations
/// Simulates modern AI interfaces like Gemini, Claude, Perplexity
class EnhancedMockApi {
  final Random _random = Random();

  /// Send chat message with rich interactive events
  Stream<ResponseEvent> sendChatMessage({
    required String message,
    required String sessionId,
    required String model,
  }) async* {
    final lowerMessage = message.toLowerCase();

    // Determine response type
    final needsWebSearch = _needsWebSearch(lowerMessage);
    final needsCalculation = _needsCalculation(lowerMessage);
    final needsCodeGeneration = _needsCodeGeneration(lowerMessage);

    // Step 1: Thinking process (Claude-style)
    if (model.contains('Gemini') || model.contains('RAG')) {
      yield* _streamThinkingSteps(message, needsWebSearch, needsCalculation);
    }

    // Step 2: Tool calling (if needed)
    if (needsWebSearch) {
      yield* _streamWebSearch(message);
    } else if (needsCalculation) {
      yield* _streamCalculation(message);
    }

    // Step 3: Main response
    yield* _streamTextResponse(message, model);

    // Step 4: Artifacts (if code generation)
    if (needsCodeGeneration) {
      yield* _streamArtifact(message);
    }

    // Step 5: Complete
    yield const ResponseEvent(ResponseEventType.complete, null);
  }

  /// Stream thinking steps
  Stream<ResponseEvent> _streamThinkingSteps(
    String message,
    bool needsWebSearch,
    bool needsCalculation,
  ) async* {
    final steps = <ThinkingStep>[];

    // Step 1: Understanding query
    steps.add(ThinkingStep(
      title: '理解問題',
      description: '分析使用者的問題和意圖',
      status: ThinkingStepStatus.inProgress,
      timestamp: DateTime.now(),
    ));
    yield ResponseEvent(ResponseEventType.thinkingStep, steps.toList());
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(200)));

    steps[0] = steps[0].copyWith(status: ThinkingStepStatus.completed);
    yield ResponseEvent(ResponseEventType.thinkingStep, steps.toList());

    // Step 2: Determine approach
    if (needsWebSearch || needsCalculation) {
      await Future.delayed(const Duration(milliseconds: 200));
      steps.add(ThinkingStep(
        title: needsWebSearch ? '規劃搜尋策略' : '規劃計算步驟',
        description: needsWebSearch ? '確定需要搜尋的關鍵字和來源' : '分解數學表達式',
        status: ThinkingStepStatus.inProgress,
        timestamp: DateTime.now(),
      ));
      yield ResponseEvent(ResponseEventType.thinkingStep, steps.toList());
      await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(300)));

      steps[1] = steps[1].copyWith(status: ThinkingStepStatus.completed);
      yield ResponseEvent(ResponseEventType.thinkingStep, steps.toList());
    }

    // Step 3: Ready to proceed
    await Future.delayed(const Duration(milliseconds: 200));
    steps.add(ThinkingStep(
      title: '準備回應',
      description: '整理資訊並生成答案',
      status: ThinkingStepStatus.completed,
      timestamp: DateTime.now(),
    ));
    yield ResponseEvent(ResponseEventType.thinkingStep, steps.toList());
  }

  /// Stream web search process
  Stream<ResponseEvent> _streamWebSearch(String message) async* {
    // Tool call: Start search
    var toolCall = ToolCall(
      toolName: 'web_search',
      description: '搜尋相關資訊',
      input: {'query': message, 'max_results': 5},
      status: ToolCallStatus.running,
      timestamp: DateTime.now(),
    );
    yield ResponseEvent(ResponseEventType.toolCall, toolCall);

    // Simulate search progress
    await Future.delayed(const Duration(milliseconds: 800));
    yield ResponseEvent(
      ResponseEventType.searchProgress,
      '正在搜尋網路...',
    );

    await Future.delayed(const Duration(milliseconds: 600));
    yield ResponseEvent(
      ResponseEventType.searchProgress,
      '找到 5 個相關來源',
    );

    // Generate mock sources
    final sources = _generateMockSources(message);
    await Future.delayed(const Duration(milliseconds: 400));
    yield ResponseEvent(ResponseEventType.sources, sources);

    // Tool call complete
    toolCall = toolCall.copyWith(
      status: ToolCallStatus.completed,
      output: {
        'sources_found': sources.length,
        'search_time_ms': 1200,
      },
    );
    yield ResponseEvent(ResponseEventType.toolCall, toolCall);
  }

  /// Stream calculation tool call
  Stream<ResponseEvent> _streamCalculation(String message) async* {
    // Extract expression (simplified)
    final expression = _extractMathExpression(message);

    var toolCall = ToolCall(
      toolName: 'calculator',
      description: '執行數學計算',
      input: {'expression': expression},
      status: ToolCallStatus.running,
      timestamp: DateTime.now(),
    );
    yield ResponseEvent(ResponseEventType.toolCall, toolCall);

    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    // Calculate result (simplified)
    final result = _calculateMockResult(expression);

    toolCall = toolCall.copyWith(
      status: ToolCallStatus.completed,
      output: {'result': result},
    );
    yield ResponseEvent(ResponseEventType.toolCall, toolCall);
  }

  /// Stream text response
  ///
  /// 支援中文和英文的字元級串流
  /// 將文字分成小塊（2-3個字元）進行串流，以支援中文打字效果
  Stream<ResponseEvent> _streamTextResponse(String message, String model) async* {
    final response = _generateResponse(message, model);

    // 使用字元級串流，每次發送 2-3 個字元
    // 這樣可以支援中文、英文和混合文字
    const int chunkSize = 3;
    String accumulated = '';

    for (int i = 0; i < response.length; i += chunkSize) {
      final end = (i + chunkSize > response.length)
          ? response.length
          : i + chunkSize;
      accumulated = response.substring(0, end);

      // 隨機延遲 50-100ms，模擬真實的打字速度
      await Future.delayed(Duration(milliseconds: 50 + _random.nextInt(50)));
      yield ResponseEvent(ResponseEventType.textChunk, accumulated);
    }

    // 確保最後一個字元也被發送
    if (accumulated != response) {
      yield ResponseEvent(ResponseEventType.textChunk, response);
    }
  }

  /// Stream artifact generation
  Stream<ResponseEvent> _streamArtifact(String message) async* {
    await Future.delayed(const Duration(milliseconds: 500));

    final code = _generateMockCode(message);
    yield ResponseEvent(
      ResponseEventType.artifact,
      {
        'type': 'code',
        'language': 'dart',
        'title': 'Generated Code',
        'content': code,
      },
    );
  }

  // Helper methods

  bool _needsWebSearch(String message) {
    return message.contains('最新') ||
        message.contains('latest') ||
        message.contains('2025') ||
        message.contains('新聞') ||
        message.contains('news') ||
        message.contains('搜尋') ||
        message.contains('search');
  }

  bool _needsCalculation(String message) {
    return message.contains('+') ||
        message.contains('-') ||
        message.contains('*') ||
        message.contains('/') ||
        message.contains('計算') ||
        message.contains('calculate');
  }

  bool _needsCodeGeneration(String message) {
    return message.contains('code') ||
        message.contains('程式') ||
        message.contains('function') ||
        message.contains('class') ||
        message.contains('寫一個') ||
        message.contains('write a');
  }

  List<SourceCitation> _generateMockSources(String query) {
    return [
      SourceCitation(
        title: 'Flutter Documentation - Official Guide',
        url: 'https://flutter.dev/docs',
        snippet:
            'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
        citationNumber: 1,
      ),
      SourceCitation(
        title: 'Riverpod - Provider Reimagined',
        url: 'https://riverpod.dev',
        snippet:
            'A reactive caching and data-binding framework that helps you manage state in your Flutter applications.',
        citationNumber: 2,
      ),
      SourceCitation(
        title: 'Material Design 3 - Design System',
        url: 'https://m3.material.io',
        snippet:
            'Material Design is a design system built and supported by Google designers and developers.',
        citationNumber: 3,
      ),
      SourceCitation(
        title: 'Dart Programming Language',
        url: 'https://dart.dev',
        snippet:
            'Dart is a client-optimized language for fast apps on any platform.',
        citationNumber: 4,
      ),
      SourceCitation(
        title: 'GitHub - Flutter Repository',
        url: 'https://github.com/flutter/flutter',
        snippet:
            'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.',
        citationNumber: 5,
      ),
    ];
  }

  String _extractMathExpression(String message) {
    // Simplified extraction
    final regex = RegExp(r'[\d\+\-\*/\(\)\s]+');
    final match = regex.firstMatch(message);
    return match?.group(0)?.trim() ?? '0';
  }

  double _calculateMockResult(String expression) {
    // Simplified calculation - just return a random number for demo
    return 42.0 + _random.nextDouble() * 100;
  }

  String _generateResponse(String message, String model) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('你好') ||
        lowerMessage.contains('hello') ||
        lowerMessage.contains('hi')) {
      return '你好！我是 Koopa AI 助手。我可以幫助您進行網路搜尋、計算、程式碼生成等任務。請問有什麼我可以協助的嗎？';
    }

    if (_needsWebSearch(lowerMessage)) {
      return '根據搜尋結果，我找到了以下相關資訊：\n\nFlutter 是 Google 開發的 UI 工具包，用於從單一程式碼庫建構美觀的原生編譯應用程式。'
          '最新版本 Flutter 3.38 包含了許多效能改進和新功能。\n\n特別值得注意的是，Flutter 現在對 Material Design 3 有更好的支援，'
          '並且改進了對桌面平台的支援。Riverpod 3.0 也提供了更強大的狀態管理功能。';
    }

    if (_needsCalculation(lowerMessage)) {
      return '經過計算，結果是 ${_calculateMockResult(_extractMathExpression(message)).toStringAsFixed(2)}。\n\n'
          '這個計算使用了標準的數學運算規則。';
    }

    if (_needsCodeGeneration(lowerMessage)) {
      return '我已經為您生成了程式碼。這段程式碼展示了如何在 Flutter 中使用 Riverpod 進行狀態管理。\n\n'
          '您可以在右側的 Artifact 視窗中查看完整的程式碼，並且可以直接複製使用。';
    }

    // Default response
    return '這是一個很好的問題。基於我的理解，我可以提供以下資訊：\n\n'
        '${model} 模型專門設計用於處理這類問題。我會盡力為您提供準確且有幫助的答案。\n\n'
        '如果您需要更具體的資訊，歡迎提供更多細節，我會進一步協助您。';
  }

  String _generateMockCode(String message) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State provider
final counterProvider = StateProvider<int>((ref) => 0);

class CounterApp extends ConsumerWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Count:'),
            Text(
              '\$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  // Knowledge Base API methods

  /// Delete a document from the knowledge base
  Future<void> deleteDocument(String documentId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real implementation, this would delete the document from the vector store
  }

  /// Index a document in the knowledge base
  Future<Map<String, dynamic>> indexDocument({
    required String path,
    required int size,
  }) async {
    // Simulate indexing process
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));

    // Return mock indexing result
    return {
      'summary': 'Document indexed successfully. Contains information about ${path.split('/').last}',
      'vectorCount': 50 + _random.nextInt(100),
    };
  }

  /// Clear all documents from the knowledge base
  Future<void> clearAllDocuments() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would clear all documents from the vector store
  }
}
