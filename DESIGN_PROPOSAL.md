# Koopa Hub - UI/UX 優化設計方案
> 基於 Gemini Web, LobeChat, Felo Search, Perplexity 的最佳實踐
>
> 設計日期：2025-11-16

## 📋 目錄

1. [設計理念](#設計理念)
2. [核心功能優化](#核心功能優化)
3. [視覺設計系統](#視覺設計系統)
4. [互動體驗優化](#互動體驗優化)
5. [實作優先級](#實作優先級)

---

## 🎨 設計理念

### 核心價值觀
- **簡潔高效**：減少視覺噪音，聚焦對話
- **智能引導**：主動提供建議，降低學習成本
- **流暢體驗**：無縫動畫，即時反饋
- **多端一致**：桌面/平板/手機體驗統一

### 設計靈感來源

| 產品 | 借鏡特點 | 應用場景 |
|------|---------|---------|
| **Gemini Web** | 居中提示框、工具下拉選單 | 首頁佈局、工具選擇器 |
| **LobeChat** | 氣泡/文檔模式切換、PWA 體驗 | 訊息顯示模式、多端適配 |
| **Felo Search** | 簡潔 Q&A 介面、思維導圖輸出 | 知識庫搜尋、結果呈現 |
| **Perplexity** | 步驟展示、引用懸停預覽 | AI 思考過程、來源引用 |

---

## 🚀 核心功能優化

### 1. 聊天介面重設計

#### 1.1 佈局結構（參考 Gemini + LobeChat）

```
┌─────────────────────────────────────────────┐
│  [Logo] Koopa Hub          [工具▼] [設定⚙️] │  ← 頂部工具列
├─────────────────────────────────────────────┤
│                                             │
│    ┌─────────────────────────────────┐     │
│    │  會話標題 + 模型選擇器          │     │  ← 會話標題列
│    │  [🤖 Koopa (本地 RAG) ▼]       │     │
│    └─────────────────────────────────┘     │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  [用戶] 訊息內容...               │   │
│  │  09:30                             │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  [AI] ⚡ 思考中...                │   │  ← 即時進度
│  │  • 搜尋知識庫                      │   │
│  │  • 分析相關文件                    │   │
│  │  • 生成回應                        │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  [AI] 回應內容...                  │   │
│  │                                     │   │
│  │  來源: [📄 doc1.pdf] [📄 doc2.txt]  │   │  ← 引用來源
│  │  [複製] [重新生成] [👍] [👎]       │   │  ← 訊息操作
│  └─────────────────────────────────────┘   │
│                                             │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │  輸入訊息...                    [📎] │   │  ← 輸入框
│  │                                 [🎤] │   │
│  └─────────────────────────────────────┘   │
│  [建議問題1] [建議問題2] [建議問題3]       │  ← 智能建議
└─────────────────────────────────────────────┘
```

#### 1.2 新增功能

**即時進度顯示**（參考 Perplexity）
- 顯示 AI 當前執行步驟
- 可展開查看詳細進度
- 動畫指示當前階段

**引用來源系統**
- 懸停預覽引用內容
- 點擊跳轉至原文
- 引用可信度評分

**訊息操作工具列**
- 複製文本
- 重新生成回應
- 編輯使用者訊息
- 點讚/點踩反饋
- 分享對話

#### 1.3 視覺模式切換（參考 LobeChat）

```dart
enum MessageDisplayMode {
  bubble,   // 氣泡模式（預設）- 適合短對話
  document, // 文檔模式 - 適合長文閱讀
}
```

**氣泡模式**：
- 左右對齊區分用戶/AI
- 圓角氣泡設計
- 適合快速對話

**文檔模式**：
- 全寬顯示
- Markdown 完整渲染
- 適合技術文檔閱讀

### 2. 首頁優化（參考 Gemini 2025）

#### 2.1 佈局改進

```
┌─────────────────────────────────────────────┐
│                                             │
│              🧠 Koopa Hub                   │
│                                             │
│       ┌───────────────────────────────┐    │
│       │  你好，使用者                 │    │  ← 個性化問候
│       │  今天想聊什麼？               │    │
│       └───────────────────────────────┘    │
│                                             │
│       ┌───────────────────────────────┐    │
│       │  輸入訊息或選擇建議...    🔍 │    │  ← 居中搜尋框
│       └───────────────────────────────┘    │
│                                             │
│   [📄 分析文件] [🔍 搜尋知識庫] [💡 創意寫作]│  ← 快速操作
│                                             │
│   最近對話                                  │
│   ┌─────────────┐ ┌─────────────┐         │
│   │ 對話 1      │ │ 對話 2      │         │  ← 對話卡片
│   │ 2 小時前    │ │ 昨天        │         │
│   └─────────────┘ └─────────────┘         │
└─────────────────────────────────────────────┘
```

#### 2.2 智能建議系統

- 基於使用歷史提供個性化建議
- 快速操作按鈕（Pills 設計）
- 最近對話卡片預覽

### 3. 知識庫優化（參考 Felo）

#### 3.1 搜尋結果呈現

```
┌─────────────────────────────────────────────┐
│  搜尋: "Flutter 狀態管理"              [🔍] │
├─────────────────────────────────────────────┤
│  📊 找到 12 個相關結果                      │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  📄 Riverpod 完整指南.pdf          │   │
│  │  相關度: ████████░░ 85%            │   │
│  │                                     │   │
│  │  Riverpod 是 Flutter 推薦的狀態... │   │
│  │                                     │   │
│  │  [開啟文件] [加入對話]             │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  📄 Provider vs Riverpod.md         │   │
│  │  相關度: ███████░░░ 72%            │   │
│  │  ...                                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [思維導圖] [摘要報告] [匯出結果]          │  ← 輸出格式
└─────────────────────────────────────────────┘
```

#### 3.2 新增功能

- 相關度評分視覺化
- 多種輸出格式（思維導圖、報告）
- 文件預覽 Quick Look
- 批次操作支持

### 4. 設定頁面現代化

#### 4.1 分組優化

```
設定
├── 🎨 外觀
│   ├── 主題模式（系統/淺色/深色）
│   ├── 語言（繁體中文/English）
│   ├── 訊息顯示模式（氣泡/文檔）
│   └── 字體大小
├── 🤖 AI 模型
│   ├── 預設模型
│   ├── API 金鑰管理
│   └── 模型參數（進階）
├── 📚 知識庫
│   ├── 索引設定
│   ├── 儲存位置
│   └── 自動備份
├── ⌨️ 快捷鍵
│   └── 自訂快捷鍵設定
└── ℹ️ 關於
    ├── 版本資訊
    ├── 開源授權
    └── GitHub 連結
```

---

## 🎨 視覺設計系統

### 1. 色彩系統（藍色主題）

#### 主色調
```dart
// Light Theme
static const Color primary = Color(0xFF1976D2);      // Material Blue 700
static const Color primaryLight = Color(0xFF63A4FF); // Blue 400
static const Color primaryDark = Color(0xFF004BA0);  // Blue 900

// Dark Theme
static const Color primaryDark = Color(0xFF90CAF9);  // Blue 200
static const Color onPrimary = Color(0xFF003258);    // Blue 900
```

#### 語義色
```dart
// Success (綠色)
static const Color success = Color(0xFF4CAF50);

// Warning (橘色)
static const Color warning = Color(0xFFFF9800);

// Error (紅色)
static const Color error = Color(0xFFF44336);

// Info (藍色)
static const Color info = Color(0xFF2196F3);
```

### 2. 字體系統

```dart
// 標題
headlineLarge: 32px, Bold
headlineMedium: 24px, Bold
headlineSmall: 20px, Semi-Bold

// 正文
bodyLarge: 16px, Regular
bodyMedium: 14px, Regular
bodySmall: 12px, Regular

// 程式碼（考慮加入 JetBrains Mono）
code: 14px, Monospace
```

### 3. 間距系統

```dart
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### 4. 圓角設計

```dart
class BorderRadii {
  static const double sm = 8.0;   // 小元件（按鈕、標籤）
  static const double md = 12.0;  // 卡片、輸入框
  static const double lg = 16.0;  // 大型卡片
  static const double full = 999.0; // 完全圓形（Pills）
}
```

---

## ⚡ 互動體驗優化

### 1. 動畫系統

#### 頁面轉場
```dart
// 淡入淡出 + 位移
PageTransition(
  type: PageTransitionType.fadeIn,
  child: NextPage(),
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOutCubic,
)
```

#### 訊息動畫
```dart
// 新訊息滑入
AnimatedSlide(
  offset: Offset(0, _isVisible ? 0 : 0.1),
  duration: Duration(milliseconds: 400),
  curve: Curves.easeOutCubic,
  child: MessageBubble(...),
)
```

#### 載入動畫
- 骨架屏（Shimmer）取代傳統 Spinner
- 進度條顯示實際進度
- 微動畫增加趣味性

### 2. 互動反饋

```dart
// 按鈕按壓
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  child: ElevatedButton(...),
)

// 懸停效果（桌面）
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    elevation: _isHovered ? 4 : 0,
    duration: Duration(milliseconds: 200),
  ),
)
```

### 3. 觸覺反饋（手機）

```dart
// 重要操作
HapticFeedback.mediumImpact(); // 中等震動

// 錯誤操作
HapticFeedback.heavyImpact();  // 強震動

// 選擇操作
HapticFeedback.selectionClick(); // 輕震動
```

### 4. 鍵盤快捷鍵

| 快捷鍵 | 功能 | 平台 |
|--------|------|------|
| `Cmd/Ctrl + Enter` | 發送訊息 | 全部 |
| `Cmd/Ctrl + N` | 新建對話 | 全部 |
| `Cmd/Ctrl + K` | 快速搜尋 | 全部 |
| `Cmd/Ctrl + ,` | 開啟設定 | 全部 |
| `Cmd/Ctrl + /` | 快捷鍵說明 | 全部 |
| `Cmd/Ctrl + 1-3` | 切換頁面 | 桌面 |
| `Esc` | 關閉對話框/取消 | 全部 |

---

## 📱 響應式設計

### 斷點定義

```dart
class Breakpoints {
  static const double mobile = 600;   // 手機
  static const double tablet = 900;   // 平板
  static const double desktop = 1200; // 桌面
}
```

### 佈局適配

#### 手機（< 600px）
- BottomNavigationBar 取代 NavigationRail
- 全螢幕對話視圖
- 簡化工具列
- 單欄佈局

#### 平板（600-900px）
- NavigationRail 顯示圖標+文字
- 雙欄佈局（側邊欄 + 主內容）
- 抽屜式設定面板

#### 桌面（> 900px）
- 完整 NavigationRail
- 三欄佈局（側邊欄 + 主內容 + 詳情面板）
- 快捷鍵支持
- 懸停效果

---

## 🔧 技術實作細節

### 1. 狀態管理優化

```dart
// 全域 UI 狀態
@riverpod
class AppPreferences extends _$AppPreferences {
  @override
  AppPreferencesState build() {
    return AppPreferencesState(
      themeMode: ThemeMode.system,
      locale: const Locale('zh', 'TW'),
      messageDisplayMode: MessageDisplayMode.bubble,
      fontSize: FontSize.medium,
    );
  }

  void setMessageDisplayMode(MessageDisplayMode mode) {
    state = state.copyWith(messageDisplayMode: mode);
  }
}
```

### 2. 可重用元件庫

```
lib/core/widgets/
├── empty_state.dart         # 空狀態顯示
├── loading_indicator.dart   # 載入指示器
├── confirmation_dialog.dart # 確認對話框
├── error_view.dart          # 錯誤顯示
├── shimmer_loading.dart     # 骨架屏
├── message_bubble.dart      # 訊息氣泡
├── source_citation.dart     # 來源引用
├── progress_steps.dart      # 進度步驟
└── quick_action_button.dart # 快速操作按鈕
```

### 3. 效能優化

```dart
// 使用 const 建構子
const EmptyState(
  title: '尚無對話',
  message: '開始新對話探索 AI 的力量',
);

// ListView.builder 替代 ListView
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    return MessageBubble(
      key: ValueKey(messages[index].id), // 穩定的 key
      message: messages[index],
    );
  },
);

// 圖片快取
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerLoading(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

---

## 📊 實作優先級

### 🔴 P0 - 核心體驗（第一週）

1. ✅ **修復型別安全問題** - 已完成
2. ⭐ **建立可重用元件庫**
   - Empty State
   - Loading Indicator
   - Confirmation Dialog
3. ⭐ **響應式設計基礎**
   - 斷點系統
   - 手機 BottomNavigationBar
   - 平板/桌面 NavigationRail

### 🟡 P1 - 重要功能（第二週）

4. ⭐ **聊天介面優化**
   - 訊息顯示模式切換
   - 訊息操作工具列
   - 智能建議系統
5. ⭐ **動畫系統**
   - 頁面轉場
   - 訊息動畫
   - 載入骨架屏
6. ⭐ **鍵盤快捷鍵**
   - 基本快捷鍵
   - 快捷鍵幫助面板

### 🟢 P2 - 增強功能（第三週）

7. ⭐ **即時進度顯示**
   - AI 思考步驟展示
   - 可展開詳情
8. ⭐ **引用來源系統**
   - 懸停預覽
   - 點擊跳轉
9. ⭐ **搜尋功能**
   - 對話歷史搜尋
   - 知識庫搜尋優化
10. ⭐ **語言切換 UI**
    - 設定頁面語言選擇器
    - 即時切換無需重啟

### 🔵 P3 - 進階功能（第四週+）

11. ⭐ **多種輸出格式**
    - 思維導圖
    - 摘要報告
12. ⭐ **語音支持**
    - 語音輸入
    - TTS 語音輸出
13. ⭐ **進階自訂**
    - 自訂主題色
    - 字體大小調整
    - AI 參數調整

---

## ✅ 驗收標準

### 使用者體驗指標
- ✅ 首次載入時間 < 2 秒
- ✅ 頁面轉場動畫流暢（60 FPS）
- ✅ 支援 3 種螢幕尺寸（手機/平板/桌面）
- ✅ 支援深淺兩種主題
- ✅ 支援英文和繁體中文

### 程式碼品質指標
- ✅ 無 `dynamic` 型別使用
- ✅ 所有元件都有適當的 `const` 標記
- ✅ 所有互動元件都有 `Semantics` 標籤
- ✅ 符合 Flutter/Dart 最佳實踐
- ✅ 通過 `flutter analyze` 無警告

### 功能完整性
- ✅ 所有按鈕都有視覺反饋
- ✅ 所有輸入都有驗證
- ✅ 所有錯誤都有友善提示
- ✅ 所有載入狀態都有指示器

---

## 📚 參考資源

- [Material Design 3](https://m3.material.io/)
- [Flutter 效能最佳實踐](https://docs.flutter.dev/perf/best-practices)
- [Riverpod 官方文檔](https://riverpod.dev/)
- [Flutter 國際化指南](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

**設計者**: Claude (Anthropic)
**審核者**: Koopa Team
**版本**: v1.0
**最後更新**: 2025-11-16
