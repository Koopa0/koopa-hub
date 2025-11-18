# Koopa Hub - Demo 觸發關鍵字指南

> 本指南說明如何在 Demo 中觸發各種 AI 互動功能

## 🎯 快速測試指令

### 1. 🔍 Web Search（網頁搜尋）

**觸發效果：** 思考步驟 + 工具調用 + 來源引用卡片

**觸發關鍵字：**
- **中文：** 最新、新聞、搜尋
- **英文：** latest、news、search、2025

**範例測試指令：**
```
2025年最新的Flutter版本是什麼？
搜尋 Riverpod 的最新功能
What's the latest news about Dart?
```

**預期結果：**
1. 顯示思考步驟（理解問題 → 規劃搜尋策略 → 準備回應）
2. 顯示工具調用卡片（Web Search）
3. 顯示 5 個來源引用卡片（可點擊開啟外部連結）
4. 逐字串流回應文字

---

### 2. 🧮 計算器（Calculator）

**觸發效果：** 思考步驟 + 工具調用

**觸發關鍵字：**
- **符號：** +、-、*、/
- **中文：** 計算
- **英文：** calculate

**範例測試指令：**
```
計算 (123 + 456) * 2
Calculate 100 / 5 + 20
999 - 111 是多少？
```

**預期結果：**
1. 顯示思考步驟（理解問題 → 規劃計算步驟 → 準備回應）
2. 顯示工具調用卡片（Calculator）
3. 逐字串流回應計算結果

---

### 3. 💻 程式碼生成（Artifact 側邊欄）

**觸發效果：** Artifact 側邊欄（類似 Claude Web）

**觸發關鍵字：**
- **中文：** 程式、寫一個
- **英文：** code、function、class、write a

**範例測試指令：**
```
寫一個 Flutter counter 程式
Write a function to calculate factorial
請幫我寫一個 Dart class
```

**預期結果：**
1. 顯示思考步驟
2. 逐字串流回應說明文字
3. 顯示 Artifact 卡片（點擊後開啟側邊欄）
4. 側邊欄顯示語法高亮的程式碼
5. 可以複製程式碼
6. 可以關閉側邊欄（點擊右上角 X）

---

### 4. 💬 一般對話（純文字）

**觸發效果：** 純文字回應（無額外功能）

**範例測試指令：**
```
你好
什麼是 Flutter？
介紹一下 Material Design 3
```

**預期結果：**
1. 無思考步驟
2. 無工具調用
3. 無來源引用
4. 無 Artifact
5. 僅顯示逐字串流的文字回應

---

## 🏠 Dashboard 測試

### 最近對話顯示

**如何測試：**
1. 進入「Conversations」模式，發送幾則訊息
2. 切換回「Home」模式
3. 查看「Recent Conversations」區域

**預期結果：**
- 顯示最近 3 個對話
- 每個卡片顯示：
  - 對話標題
  - 第一則訊息預覽
  - 時間戳記（例如「2 min ago」）
  - 訊息數量
- 點擊卡片可直接開啟該對話

---

## 🎨 UI 功能測試

### Artifact 側邊欄

**測試步驟：**
1. 輸入 `寫一個 Flutter counter 程式`
2. 等待回應完成
3. 點擊 Artifact 卡片
4. 觀察側邊欄開啟
5. 嘗試複製程式碼
6. 點擊右上角 X 關閉側邊欄

**預期結果：**
- 側邊欄從右側滑入（佔 30% 寬度）
- 聊天區域縮小為 70% 寬度
- 可以邊聊天邊查看 Artifact
- 語法高亮正確顯示
- 複製功能正常運作

---

## 🔧 技術細節

### 觸發邏輯位置

程式碼位置：`lib/core/services/enhanced_mock_api.dart`

```dart
// Web Search 判斷
bool _needsWebSearch(String message) {
  return message.contains('最新') ||
      message.contains('latest') ||
      message.contains('2025') ||
      message.contains('新聞') ||
      message.contains('news') ||
      message.contains('搜尋') ||
      message.contains('search');
}

// 計算器判斷
bool _needsCalculation(String message) {
  return message.contains('+') ||
      message.contains('-') ||
      message.contains('*') ||
      message.contains('/') ||
      message.contains('計算') ||
      message.contains('calculate');
}

// 程式碼生成判斷
bool _needsCodeGeneration(String message) {
  return message.contains('code') ||
      message.contains('程式') ||
      message.contains('function') ||
      message.contains('class') ||
      message.contains('寫一個') ||
      message.contains('write a');
}
```

### 模型選擇影響

- **Gemini (RAG)** 或 **Gemini (Web Search)** 模型：會顯示思考步驟
- **其他模型（Koopa）** ：僅在有工具調用時顯示思考步驟

---

## 📝 測試檢查清單

使用此清單確保所有功能正常運作：

- [ ] **Web Search**
  - [ ] 觸發思考步驟
  - [ ] 顯示工具調用卡片
  - [ ] 顯示 5 個來源卡片
  - [ ] 來源卡片可點擊開啟外部連結
  - [ ] 文字逐字串流顯示

- [ ] **Calculator**
  - [ ] 觸發思考步驟
  - [ ] 顯示工具調用卡片
  - [ ] 計算結果正確顯示
  - [ ] 文字逐字串流顯示

- [ ] **Code Generation (Artifact)**
  - [ ] 顯示 Artifact 卡片
  - [ ] 點擊卡片開啟側邊欄
  - [ ] 側邊欄語法高亮正確
  - [ ] 複製按鈕功能正常
  - [ ] 關閉按鈕功能正常
  - [ ] 可以邊聊天邊查看 Artifact

- [ ] **Dashboard**
  - [ ] 顯示最近 3 個對話
  - [ ] 卡片顯示正確資訊
  - [ ] 時間戳記格式正確
  - [ ] 點擊卡片切換對話正常

- [ ] **一般對話**
  - [ ] 純文字回應正常
  - [ ] 中文逐字顯示正確
  - [ ] 英文逐字顯示正確
  - [ ] 無多餘 UI 元素

---

## 🚀 下一步

完成測試後，您可以：

1. **優化串流延遲** - 調整文字顯示速度
2. **新增載入動畫** - 改善等待體驗
3. **改進錯誤處理** - 提供更友善的錯誤訊息
4. **整合真實 API** - 連接 koopa-cli 後端

---

**最後更新：** 2025-11-18
**版本：** v1.0 - Artifact Sidebar + Dashboard Update
