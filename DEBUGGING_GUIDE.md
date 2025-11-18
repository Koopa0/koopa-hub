# 🔧 Koopa Hub - 調試指南

> **版本：** Phase 1 Complete
> **日期：** 2025-11-18
> **目的：** 解決常見問題和調試功能觸發

---

## 🚨 常見問題排解

### 問題 1: "寫一個 Flutter counter 程式" 沒有觸發 Artifact

**症狀：**
- 輸入包含 "寫一個" 或 "程式" 的訊息
- 沒有出現 Artifact 卡片
- 只有純文字回應

**可能原因：**

#### 原因 A: Provider 程式碼未生成

**檢查方式：**
```bash
# 檢查是否存在生成的檔案
ls -la lib/features/chat/providers/chat_provider.g.dart
```

**解決方案：**
```bash
# 執行程式碼生成
flutter pub run build_runner build --delete-conflicting-outputs

# 如果出現錯誤，清除快取後重試
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

#### 原因 B: 選擇的模型不支援思考步驟

**檢查方式：**
- 查看聊天介面右上角的模型選擇器
- 確認當前選擇的模型

**解決方案：**
- 切換到 **Gemini (RAG)** 或 **Gemini (Web Search)** 模型
- 這兩個模型會觸發思考步驟

**程式碼位置：** `lib/core/services/enhanced_mock_api.dart:46`
```dart
// 只有 Gemini 模型會顯示思考步驟
if (model.contains('Gemini') || model.contains('RAG')) {
  yield* _streamThinkingSteps(...);
}
```

---

#### 原因 C: 觸發邏輯未匹配

**檢查方式：**
在 `lib/core/services/enhanced_mock_api.dart` 添加調試輸出：

```dart
Stream<ResponseEvent> sendChatMessage({
  required String message,
  required String sessionId,
  required String model,
}) async* {
  final lowerMessage = message.toLowerCase();
  final needsCodeGeneration = _needsCodeGeneration(lowerMessage);

  // 添加調試輸出
  debugPrint('🔍 Message: $message');
  debugPrint('🔍 Lower: $lowerMessage');
  debugPrint('🔍 Needs Code Generation: $needsCodeGeneration');

  // ...
}
```

**預期輸出：**
```
🔍 Message: 寫一個 Flutter counter 程式
🔍 Lower: 寫一個 flutter counter 程式
🔍 Needs Code Generation: true
```

**如果顯示 false：**
- 檢查 `_needsCodeGeneration` 方法
- 確認關鍵字列表

---

#### 原因 D: Artifact 事件未正確處理

**檢查方式：**
在 `lib/features/chat/providers/chat_provider.dart` 的 `sendMessage` 方法中添加調試：

```dart
await for (final event in stream) {
  debugPrint('📥 Event type: ${event.type}');  // 添加這行

  if (!ref.mounted) {
    debugPrint('Provider disposed, stopping stream processing');
    break;
  }

  switch (event.type) {
    case ResponseEventType.artifact:
      debugPrint('🎨 Artifact event received!');  // 添加這行
      final artifactData = event.data as Map<String, dynamic>;
      // ...
  }
}
```

**預期輸出：**
```
📥 Event type: ResponseEventType.thinkingStep
📥 Event type: ResponseEventType.textChunk
📥 Event type: ResponseEventType.artifact
🎨 Artifact event received!
📥 Event type: ResponseEventType.complete
```

---

### 問題 2: "Provider disposed" 訊息出現

**症狀：**
- 控制台顯示 "Provider disposed, stopping stream processing"
- 訊息串流中斷

**原因：**
- 快速切換對話或頁面
- Provider 在串流過程中被釋放

**這是正常行為嗎？**
✅ **是的！** 這是我們添加的保護機制，防止錯誤發生。

**如果影響功能：**
1. 避免在訊息串流期間切換頁面
2. 等待回應完成後再操作
3. 如果問題持續，重新發送訊息

---

### 問題 3: Dashboard 不顯示最近對話

**症狀：**
- Dashboard 顯示 "No recent conversations"
- 明明有發送過訊息

**可能原因：**

#### 原因 A: Hive 資料未載入

**解決方案：**
```dart
// 完全重啟應用程式（非 Hot Reload）
// 在 VS Code 或 Android Studio 中:
// 1. 停止應用程式
// 2. 重新執行
```

---

#### 原因 B: 會話未正確儲存

**檢查方式：**
在 `lib/features/chat/providers/chat_provider.dart` 添加調試：

```dart
void createSession({String? title}) {
  final newSession = ChatSession.create(
    title: title ?? '新對話 ${state.length + 1}',
  );

  debugPrint('💾 Saving session: ${newSession.id}');  // 添加這行

  // 1. 持久化到 Hive
  _box.put(newSession.id, newSession);

  // 2. 更新 UI 狀態
  state = [newSession, ...state];
}
```

---

### 問題 4: Artifact 側邊欄不開啟

**症狀：**
- 點擊 Artifact 卡片
- 側邊欄沒有出現

**可能原因：**

#### 原因 A: artifactSidebarProvider 未生成

**解決方案：**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

#### 原因 B: 點擊事件未觸發

**檢查方式：**
在 `lib/features/chat/widgets/message_list.dart` 添加調試：

```dart
void _showArtifactViewer(BuildContext context) {
  if (widget.message.artifact == null) {
    debugPrint('❌ Artifact is null');  // 添加這行
    return;
  }

  debugPrint('🎨 Opening artifact sidebar');  // 添加這行

  // 使用 provider 在側邊欄顯示 Artifact
  ref.read(artifactSidebarProvider.notifier).showArtifact(
        widget.message.artifact!,
      );
}
```

---

## 🔍 完整調試流程

### 步驟 1: 確認環境

```bash
# 檢查 Flutter 版本
flutter --version

# 確認專案依賴
flutter pub get

# 生成 Provider 程式碼
flutter pub run build_runner build --delete-conflicting-outputs
```

### 步驟 2: 啟用調試模式

在 `lib/core/services/enhanced_mock_api.dart` 添加：

```dart
class EnhancedMockApi {
  final Random _random = Random();
  final bool _debug = true;  // 添加這行

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

    if (_debug) {  // 添加這段
      debugPrint('═══════════════════════════════');
      debugPrint('🔍 Debug Info:');
      debugPrint('  Message: $message');
      debugPrint('  Model: $model');
      debugPrint('  Needs Web Search: $needsWebSearch');
      debugPrint('  Needs Calculation: $needsCalculation');
      debugPrint('  Needs Code Generation: $needsCodeGeneration');
      debugPrint('═══════════════════════════════');
    }

    // ...
  }
}
```

### 步驟 3: 測試觸發關鍵字

使用這些確定會觸發的指令：

```
# Web Search (確定觸發)
2025年最新的Flutter資訊

# Calculator (確定觸發)
123 + 456

# Code Generation (確定觸發)
寫一個function

# 混合觸發 (同時有 code 和程式)
write a Dart program
```

### 步驟 4: 檢查控制台輸出

啟動應用程式後，查看控制台：

```
# 正常輸出應該類似：
═══════════════════════════════
🔍 Debug Info:
  Message: 寫一個function
  Model: Koopa (M)
  Needs Web Search: false
  Needs Calculation: false
  Needs Code Generation: true  ✅ 應該是 true
═══════════════════════════════
📥 Event type: ResponseEventType.textChunk
📥 Event type: ResponseEventType.artifact  ✅ 應該出現
🎨 Artifact event received!  ✅ 應該出現
```

---

## 📊 觸發關鍵字完整列表

### Web Search 觸發

```dart
bool _needsWebSearch(String message) {
  return message.contains('最新') ||
      message.contains('latest') ||
      message.contains('2025') ||
      message.contains('新聞') ||
      message.contains('news') ||
      message.contains('搜尋') ||
      message.contains('search');
}
```

**測試指令：**
- ✅ `最新的Flutter版本`
- ✅ `latest news about Dart`
- ✅ `2025年的技術趨勢`
- ✅ `搜尋 Riverpod 文件`

---

### Calculator 觸發

```dart
bool _needsCalculation(String message) {
  return message.contains('+') ||
      message.contains('-') ||
      message.contains('*') ||
      message.contains('/') ||
      message.contains('計算') ||
      message.contains('calculate');
}
```

**測試指令：**
- ✅ `123 + 456`
- ✅ `計算 100 除以 5`
- ✅ `calculate 999 * 2`

---

### Code Generation 觸發（Artifact）

```dart
bool _needsCodeGeneration(String message) {
  return message.contains('code') ||
      message.contains('程式') ||
      message.contains('function') ||
      message.contains('class') ||
      message.contains('寫一個') ||
      message.contains('write a');
}
```

**測試指令：**
- ✅ `寫一個 Flutter app`
- ✅ `write a function`
- ✅ `create a Dart class`
- ✅ `show me some code`
- ✅ `生成程式碼`

**注意：** 關鍵字是 **OR** 關係，只要包含其中一個就會觸發！

---

## 🎯 快速測試腳本

創建一個測試檔案來驗證觸發邏輯：

```dart
// test/trigger_test.dart
void main() {
  test('Web Search trigger', () {
    final message = '2025年最新的Flutter版本'.toLowerCase();
    final triggered = message.contains('最新') ||
        message.contains('latest') ||
        message.contains('2025');

    expect(triggered, true);
    print('✅ Web Search: $triggered');
  });

  test('Code Generation trigger', () {
    final message = '寫一個 Flutter counter 程式'.toLowerCase();
    final triggered = message.contains('code') ||
        message.contains('程式') ||
        message.contains('function') ||
        message.contains('class') ||
        message.contains('寫一個');

    expect(triggered, true);
    print('✅ Code Generation: $triggered');
  });
}
```

執行測試：
```bash
flutter test test/trigger_test.dart
```

---

## 🆘 如果以上都無法解決

### 最終檢查清單

- [ ] 執行 `flutter pub get`
- [ ] 執行 `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] 完全重啟應用程式（非 Hot Reload）
- [ ] 清除應用程式資料並重新安裝
- [ ] 檢查 Flutter 版本（建議 3.38+）
- [ ] 檢查是否有編譯錯誤

### 收集調試資訊

如果問題仍然存在，請提供：

1. **Flutter 版本：**
   ```bash
   flutter --version
   ```

2. **控制台完整輸出：**
   - 從啟動到問題發生的所有訊息

3. **測試指令：**
   - 您輸入的確切文字

4. **預期行為 vs 實際行為：**
   - 應該發生什麼
   - 實際發生了什麼

5. **截圖：**
   - 使用者介面狀態
   - 控制台輸出

---

## 💡 調試技巧

### 技巧 1: 使用斷點

在 VS Code 或 Android Studio 中：
1. 在 `_needsCodeGeneration` 方法設置斷點
2. 輸入測試訊息
3. 檢查 `message` 參數的值

### 技巧 2: 使用 debugPrint

strategically 添加 `debugPrint` 來追蹤執行流程：

```dart
debugPrint('🔵 Step 1: Checking message');
debugPrint('🟢 Step 2: Message matched');
debugPrint('🟡 Step 3: Generating artifact');
debugPrint('🔴 Error occurred: $e');
```

### 技巧 3: 檢查 Riverpod 狀態

使用 Riverpod DevTools：
1. 啟用 Riverpod DevTools
2. 檢查 `artifactSidebarProvider` 的狀態
3. 確認值是否正確更新

---

**最後更新：** 2025-11-18
**版本：** Phase 1 Complete - Debugging Guide
