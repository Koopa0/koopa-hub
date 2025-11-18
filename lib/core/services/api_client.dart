import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Mock API Client for Koopa Hub
///
/// 這個類提供模擬的 API 服務，用於展示應用功能
/// 在實際部署時，可以替換為真實的 HTTP 客戶端
class ApiClient {
  final String baseUrl;
  final Random _random = Random();

  ApiClient({this.baseUrl = 'http://localhost:8080'});

  /// 檢查服務器連接
  Future<bool> checkHealth() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // 模擬：總是返回成功
      return true;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// 發送聊天消息（流式響應）
  ///
  /// 返回一個 Stream，模擬打字效果
  Stream<String> sendChatMessage({
    required String message,
    required String sessionId,
    required String model,
  }) async* {
    await Future.delayed(const Duration(milliseconds: 500));

    // 根據不同模型生成不同的回應
    String response = _generateMockResponse(message, model);

    // 模擬流式響應 - 逐字輸出
    final words = response.split(' ');
    String accumulated = '';

    for (int i = 0; i < words.length; i++) {
      accumulated += (i == 0 ? '' : ' ') + words[i];

      // 隨機延遲，模擬真實打字速度
      final delay = 30 + _random.nextInt(70); // 30-100ms
      await Future.delayed(Duration(milliseconds: delay));

      yield accumulated;
    }
  }

  /// 索引知識庫文檔
  Future<Map<String, dynamic>> indexDocument({
    required String path,
    required int size,
  }) async {
    // 模擬索引過程
    final indexingTime = 1000 + _random.nextInt(2000); // 1-3秒
    await Future.delayed(Duration(milliseconds: indexingTime));

    // 模擬生成向量數量（根據文件大小）
    final vectorCount = (size / 10000).ceil() + _random.nextInt(20);

    // 模擬生成摘要
    final summary = _generateMockSummary(path);

    return {
      'success': true,
      'vectorCount': vectorCount,
      'summary': summary,
      'indexedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 刪除知識庫文檔
  Future<bool> deleteDocument(String documentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// 清空所有知識庫
  Future<bool> clearAllDocuments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// 生成模擬響應
  String _generateMockResponse(String message, String model) {
    final lowerMessage = message.toLowerCase();

    // 根據問題類型生成不同回應
    if (lowerMessage.contains('你好') ||
        lowerMessage.contains('hello') ||
        lowerMessage.contains('hi')) {
      return _getGreeting();
    } else if (lowerMessage.contains('什麼是') ||
        lowerMessage.contains('什么是') ||
        lowerMessage.contains('what is')) {
      return _getExplanation(message);
    } else if (lowerMessage.contains('如何') ||
        lowerMessage.contains('怎麼') ||
        lowerMessage.contains('怎么') ||
        lowerMessage.contains('how to')) {
      return _getHowTo(message);
    } else if (lowerMessage.contains('比較') ||
        lowerMessage.contains('比较') ||
        lowerMessage.contains('區別') ||
        lowerMessage.contains('区别') ||
        lowerMessage.contains('difference')) {
      return _getComparison(message);
    } else if (lowerMessage.contains('範例') ||
        lowerMessage.contains('例子') ||
        lowerMessage.contains('example')) {
      return _getExample(message);
    } else {
      return _getGenericResponse(message, model);
    }
  }

  String _getGreeting() {
    final greetings = [
      '你好！我是 Koopa AI 助手，很高興為你服務！有什麼我可以幫助你的嗎？',
      '嗨！歡迎使用 Koopa Hub。我可以協助你進行知識查詢、網路搜尋或一般對話。',
      'Hello! 我是你的 AI 助手。無論是技術問題、學習資料，還是日常對話，我都樂意協助！',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }

  String _getExplanation(String message) {
    return '''讓我為你解釋一下：

**核心概念**
這是一個重要的主題，涉及多個方面的知識。

**主要特點**
1. **易於理解** - 概念清晰，容易掌握
2. **實用性強** - 可以應用在實際場景中
3. **擴展性好** - 可以根據需求進行調整

**實際應用**
在實際使用中，這個概念被廣泛應用於各種場景，能夠有效解決相關問題。

**小提示**
建議從基礎開始學習，逐步深入，這樣能夠更好地理解和運用。

你還想了解更多細節嗎？''';
  }

  String _getHowTo(String message) {
    return '''讓我為你說明具體步驟：

**步驟一：準備工作**
首先，確保你已經了解基本概念和前置需求。

**步驟二：開始實作**
1. 建立基本架構
2. 配置必要的參數
3. 測試功能是否正常

**步驟三：優化調整**
根據實際需求進行微調，確保達到最佳效果。

**步驟四：驗證結果**
✅ 檢查是否符合預期
✅ 進行必要的測試
✅ 記錄問題和解決方案

**最佳實踐**
- 保持代碼簡潔
- 添加必要的註釋
- 遵循業界標準

需要我詳細說明某個步驟嗎？''';
  }

  String _getComparison(String message) {
    return '''讓我為你比較一下這些選項：

**選項 A**
優點：
- ✅ 性能優異
- ✅ 易於上手
- ✅ 社群支持良好

缺點：
- ⚠️ 學習曲線稍陡
- ⚠️ 某些場景下不適用

**選項 B**
優點：
- ✅ 功能豐富
- ✅ 文檔完善
- ✅ 靈活性高

缺點：
- ⚠️ 配置複雜
- ⚠️ 資源消耗較大

**建議**
根據你的具體需求選擇最合適的方案。如果注重性能，選擇 A；如果需要更多功能，選擇 B。

需要更詳細的比較嗎？''';
  }

  String _getExample(String message) {
    return '''這裡是一個實用的範例：

```dart
// 範例代碼
class Example {
  final String name;
  final int value;

  Example({
    required this.name,
    required this.value,
  });

  void doSomething() {
    print('執行操作: \$name');
  }
}

// 使用範例
void main() {
  final example = Example(
    name: 'Demo',
    value: 42,
  );

  example.doSomething();
}
```

**說明**
這個範例展示了基本的使用方法。你可以根據需求進行修改和擴展。

**關鍵點**
- 📌 注意參數的類型定義
- 📌 使用 `required` 確保必要參數不會遺漏
- 📌 添加適當的註釋提高可讀性

還需要其他範例嗎？''';
  }

  String _getGenericResponse(String message, String model) {
    final responses = [
      '''我理解你的問題。讓我為你提供詳細的回答：

**核心要點**
${message.length > 50 ? '你提出了一個很好的問題' : '這是一個有趣的話題'}，值得深入探討。

**詳細說明**
根據我的分析，這個問題涉及多個層面。從技術角度來看，我們需要考慮以下幾點：

1. **基礎概念** - 理解基本原理
2. **實際應用** - 如何在實踐中運用
3. **注意事項** - 需要注意的細節

**建議**
建議你可以從基礎開始，循序漸進地學習。如果遇到問題，隨時可以問我！

還有什麼想了解的嗎？''',
      '''感謝你的提問！這是一個很棒的問題。

**回答概要**
基於你的問題，我整理了以下要點：

**關鍵資訊**
• 這個主題在實際應用中很常見
• 有多種解決方案可供選擇
• 每種方案都有其優缺點

**深入分析**
從技術實現的角度來看，我們可以採用不同的策略。選擇合適的方案需要考慮你的具體需求和使用場景。

**實用提示**
💡 先理解核心概念
💡 多練習實際操作
💡 參考最佳實踐

希望這個回答對你有幫助！如果需要更具體的說明，請告訴我。''',
    ];

    String baseResponse = responses[_random.nextInt(responses.length)];

    // 根據模型添加特定資訊
    if (model == 'local_rag') {
      baseResponse +=
          '\n\n**資料來源**\n📚 這個回答參考了你的知識庫中的相關文件。';
    } else if (model == 'web_search') {
      baseResponse +=
          '\n\n**網路資源**\n🌐 這個回答結合了最新的網路搜尋結果。';
    } else if (model == 'gemini') {
      baseResponse +=
          '\n\n**AI 分析**\n🤖 這個回答由 Gemini 模型生成，結合了廣泛的知識。';
    }

    return baseResponse;
  }

  /// 生成文檔摘要
  String _generateMockSummary(String path) {
    final fileName = path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    final summaryTemplates = {
      'pdf': '本 PDF 文件包含了豐富的技術資料和實用範例，涵蓋了核心概念、最佳實踐和進階主題。',
      'md': '這份 Markdown 文件詳細記錄了重要知識點，包含程式碼範例、圖表說明和步驟指南。',
      'txt': '這個文本文件整理了關鍵資訊和參考資料，適合快速查閱和學習。',
      'json': '此 JSON 文件包含結構化資料，可用於 API 文件、配置說明或資料集參考。',
      'docx': '這份 Word 文件提供了完整的說明文件，包含詳細的內容和格式化的資訊。',
      'csv': '這個 CSV 文件包含表格資料，可用於數據分析、統計和資料視覺化。',
    };

    return summaryTemplates[extension] ??
        '這份文件包含了有價值的資訊和參考資料，已成功索引到知識庫中。';
  }
}
