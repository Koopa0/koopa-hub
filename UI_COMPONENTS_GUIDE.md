# Koopa Hub - UI 元件使用指南

> 所有新建立的可重用 UI 元件的完整使用指南
> 建立日期：2025-11-16

## 📚 目錄

- [核心元件](#核心元件)
- [聊天元件](#聊天元件)
- [動畫元件](#動畫元件)
- [工具類](#工具類)
- [使用範例](#使用範例)

---

## 🎯 核心元件

### 1. EmptyState - 空狀態顯示

**位置**: `lib/core/widgets/empty_state.dart`

**用途**: 統一顯示空列表、無資料等情境

```dart
EmptyState(
  icon: Icons.chat_bubble_outline,
  title: '尚無對話',
  message: '開始新對話探索 AI 的力量',
  action: () => createNewChat(),
  actionLabel: '開始對話',
)
```

**參數**:
- `icon`: 顯示的圖標
- `title`: 主標題
- `message`: 說明文字
- `action`: 操作按鈕回調（可選）
- `actionLabel`: 操作按鈕文字（可選）

---

### 2. LoadingIndicator - 載入指示器

**位置**: `lib/core/widgets/loading_indicator.dart`

**用途**: 提供多種載入樣式

```dart
// 圓形 Spinner
LoadingIndicator(
  type: LoadingIndicatorType.circular,
  message: '載入中...',
)

// 線性進度條
LoadingIndicator(
  type: LoadingIndicatorType.linear,
  progress: 0.5, // 50%
)

// 骨架屏
LoadingIndicator(
  type: LoadingIndicatorType.shimmer,
)
```

**參數**:
- `type`: 載入類型（circular/linear/shimmer）
- `message`: 載入訊息（可選）
- `progress`: 進度值 0.0-1.0（可選，null 為不確定進度）

---

### 3. ConfirmationDialog - 確認對話框

**位置**: `lib/core/widgets/confirmation_dialog.dart`

**用途**: 統一的確認對話框樣式

```dart
// 顯示對話框
final confirmed = await ConfirmationDialog.show(
  context: context,
  title: '刪除對話',
  message: '確定要刪除此對話嗎？此操作無法復原。',
  icon: Icons.delete_outline,
  confirmText: '刪除',
  cancelText: '取消',
  isDestructive: true, // 危險操作（紅色按鈕）
);

if (confirmed == true) {
  // 用戶確認了操作
}
```

**參數**:
- `title`: 標題
- `message`: 訊息內容
- `icon`: 圖標（可選）
- `iconColor`: 圖標顏色（可選）
- `confirmText`: 確認按鈕文字
- `cancelText`: 取消按鈕文字
- `isDestructive`: 是否為危險操作

---

### 4. ErrorView - 錯誤顯示

**位置**: `lib/core/widgets/error_view.dart`

**用途**: 統一顯示錯誤訊息

```dart
ErrorView(
  title: '載入失敗',
  message: '無法連接到伺服器，請檢查網路連線。',
  onRetry: () => retryLoad(),
  retryLabel: '重試',
)
```

**參數**:
- `title`: 錯誤標題
- `message`: 錯誤訊息
- `onRetry`: 重試回調（可選）
- `retryLabel`: 重試按鈕文字

---

## 💬 聊天元件

### 5. MessageActionBar - 訊息操作工具列

**位置**: `lib/features/chat/widgets/message_action_bar.dart`

**用途**: 提供訊息快速操作（複製、編輯、重新生成等）

```dart
MessageActionBar(
  isUser: false, // AI 訊息
  message: messageContent,
  onAction: (action) {
    switch (action) {
      case MessageAction.copy:
        // 複製訊息
        break;
      case MessageAction.regenerate:
        // 重新生成
        break;
      case MessageAction.delete:
        // 刪除訊息
        break;
    }
  },
)
```

**操作類型**:
- `MessageAction.copy`: 複製
- `MessageAction.edit`: 編輯（僅使用者訊息）
- `MessageAction.regenerate`: 重新生成（僅 AI 訊息）
- `MessageAction.delete`: 刪除

---

### 6. ThinkingIndicator - AI 思考進度

**位置**: `lib/features/chat/widgets/thinking_indicator.dart`

**用途**: 顯示 AI 當前執行的步驟（參考 Perplexity）

```dart
ThinkingIndicator(
  steps: [
    ThinkingStep(
      title: '搜尋知識庫',
      status: ThinkingStatus.completed,
    ),
    ThinkingStep(
      title: '分析相關文件',
      status: ThinkingStatus.analyzing,
      description: '正在處理 3 個文件...',
    ),
    ThinkingStep(
      title: '生成回應',
      status: ThinkingStatus.searching,
    ),
  ],
  currentStep: 1,
)
```

**步驟狀態**:
- `ThinkingStatus.searching`: 搜尋中
- `ThinkingStatus.analyzing`: 分析中
- `ThinkingStatus.generating`: 生成中
- `ThinkingStatus.completed`: 完成

---

### 7. SourceCitation - 來源引用

**位置**: `lib/features/chat/widgets/source_citation.dart`

**用途**: 顯示 AI 回應的參考來源

```dart
SourceCitation(
  sources: [
    CitationSource(
      title: 'document.pdf',
      snippet: '相關內容摘要...',
      icon: Icons.picture_as_pdf,
    ),
    CitationSource(
      title: 'article.md',
      snippet: '參考文章內容...',
      icon: Icons.article,
    ),
  ],
)
```

**功能**:
- 懸停預覽引用內容
- 點擊跳轉（需實作）
- 視覺化引用編號

---

## 🎨 動畫元件

### 8. AnimatedScaleButton - 縮放動畫按鈕

**位置**: `lib/core/widgets/animated_scale_button.dart`

**用途**: 為按鈕添加按壓縮放反饋

```dart
AnimatedScaleButton(
  onTap: () => handleTap(),
  scale: 0.95, // 縮放到 95%
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('點我'),
  ),
)
```

**參數**:
- `child`: 子 Widget
- `onTap`: 點擊回調
- `onLongPress`: 長按回調（可選）
- `scale`: 縮放比例（預設 0.95）
- `duration`: 動畫持續時間

---

### 9. FadeInSlide - 淡入滑入動畫

**位置**: `lib/core/widgets/fade_in_slide.dart`

**用途**: 列表項目、卡片的進入動畫

```dart
FadeInSlide(
  delay: Duration(milliseconds: 100 * index),
  child: ListTile(
    title: Text('項目 $index'),
  ),
)
```

**參數**:
- `child`: 子 Widget
- `delay`: 延遲時間（用於列表項目依序出現）
- `duration`: 動畫持續時間
- `offset`: 滑入偏移量

---

## 🔧 工具類

### 10. Responsive - 響應式工具

**位置**: `lib/core/utils/responsive.dart`

**用途**: 響應式佈局輔助

```dart
// 檢測裝置類型
if (Responsive.isMobile(context)) {
  return MobileLayout();
} else {
  return DesktopLayout();
}

// 根據螢幕寬度取得不同值
final padding = Responsive.valueWhen(
  context: context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// 使用 ResponsiveBuilder
ResponsiveBuilder(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

**斷點**:
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: 900px - 1200px
- Wide: > 1200px

---

### 11. KeyboardShortcuts - 鍵盤快捷鍵

**位置**: `lib/core/utils/keyboard_shortcuts.dart`

**用途**: 定義和顯示鍵盤快捷鍵

**內建快捷鍵**:
| 快捷鍵 | 功能 |
|--------|------|
| `Cmd/Ctrl + Enter` | 發送訊息 |
| `Cmd/Ctrl + N` | 新建對話 |
| `Cmd/Ctrl + K` | 快速搜尋 |
| `Cmd/Ctrl + ,` | 開啟設定 |
| `Cmd/Ctrl + /` | 快捷鍵說明 |
| `Cmd/Ctrl + 1-3` | 切換頁面 |
| `Esc` | 關閉對話框 |

```dart
// 顯示快捷鍵說明
ShortcutsHelpDialog.show(context);

// 使用快捷鍵
Shortcuts(
  shortcuts: {
    AppShortcuts.newChat: NewChatIntent(),
  },
  child: Actions(
    actions: {
      NewChatIntent: CallbackAction(
        onInvoke: (_) => createNewChat(),
      ),
    },
    child: child,
  ),
)
```

---

### 12. SearchDialog - 快速搜尋

**位置**: `lib/core/widgets/search_dialog.dart`

**用途**: 全局搜尋對話和文件

```dart
// 顯示搜尋對話框
final query = await SearchDialog.show(context);
if (query != null) {
  // 處理搜尋查詢
  performSearch(query);
}
```

**功能**:
- 搜尋對話歷史
- 搜尋知識庫文件
- 顯示最近搜尋
- 即時搜尋結果

---

### 13. LanguageSelector - 語言選擇器

**位置**: `lib/core/widgets/language_selector.dart`

**用途**: 語言切換 UI

```dart
LanguageSelector(
  currentLocale: Locale('zh', 'TW'),
  onLanguageChanged: (locale) {
    // 更新語言設定
    ref.read(appPreferencesProvider.notifier)
       .setLocale(locale);
  },
)
```

**支援語言**:
- English (en)
- 繁體中文 (zh_TW)

---

### 14. AppPreferences - 應用偏好設定

**位置**: `lib/core/providers/app_preferences_provider.dart`

**用途**: 管理應用層級的偏好設定

```dart
// 取得當前設定
final prefs = ref.watch(appPreferencesProvider);

// 設定訊息顯示模式
ref.read(appPreferencesProvider.notifier)
   .setMessageDisplayMode(MessageDisplayMode.document);

// 切換模式
ref.read(appPreferencesProvider.notifier)
   .toggleMessageDisplayMode();

// 設定字體大小
ref.read(appPreferencesProvider.notifier)
   .setFontSize(FontSize.large);

// 設定語言
ref.read(appPreferencesProvider.notifier)
   .setLocale(Locale('en', ''));
```

**設定項目**:
- 訊息顯示模式（氣泡/文檔）
- 字體大小（小/中/大）
- 語言設定

---

## 📖 使用範例

### 範例 1: 優化空狀態顯示

**Before**:
```dart
// 舊的空狀態
Center(
  child: Text('沒有資料'),
)
```

**After**:
```dart
EmptyState(
  icon: Icons.folder_open,
  title: '尚無文件',
  message: '點擊上方按鈕以新增文件或資料夾',
  action: () => addDocument(),
  actionLabel: '新增文件',
)
```

---

### 範例 2: 改善載入體驗

**Before**:
```dart
// 簡單的 CircularProgressIndicator
if (isLoading) CircularProgressIndicator()
```

**After**:
```dart
if (isLoading)
  LoadingIndicator(
    type: LoadingIndicatorType.shimmer,
    message: '正在載入文件...',
  )
```

---

### 範例 3: 添加訊息操作

**Before**:
```dart
// 只有訊息內容
Text(message.content)
```

**After**:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(message.content),
    MessageActionBar(
      isUser: message.isUser,
      message: message.content,
      onAction: handleMessageAction,
    ),
  ],
)
```

---

### 範例 4: 響應式佈局

**Before**:
```dart
// 固定佈局
NavigationRail(...)
```

**After**:
```dart
ResponsiveBuilder(
  mobile: BottomNavigationBar(...),
  desktop: NavigationRail(...),
)
```

---

### 範例 5: 添加動畫效果

**Before**:
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(...),
)
```

**After**:
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return FadeInSlide(
      delay: Duration(milliseconds: 50 * index),
      child: ListTile(...),
    );
  },
)
```

---

## 🎯 最佳實踐

### 1. 一致性
所有相同類型的元件使用相同的樣式：
- 所有空狀態使用 `EmptyState`
- 所有確認對話框使用 `ConfirmationDialog`
- 所有載入狀態使用 `LoadingIndicator`

### 2. 響應式優先
始終考慮不同螢幕尺寸：
```dart
final padding = Responsive.valueWhen(
  context: context,
  mobile: 16.0,
  desktop: 32.0,
);
```

### 3. 動畫適度
不要過度使用動畫，保持流暢自然：
```dart
// 好的：簡單的淡入
FadeInSlide(child: widget)

// 避免：過於複雜的動畫
RotatingBouncingScalingFadeWidget(child: widget)
```

### 4. 無障礙支援
為互動元素添加語義標籤：
```dart
Semantics(
  label: '刪除訊息',
  button: true,
  child: IconButton(...),
)
```

### 5. 效能優化
使用 `const` 建構子：
```dart
const EmptyState(
  icon: Icons.inbox,
  title: '空的',
  message: '沒有內容',
)
```

---

## 🚀 下一步

### 待整合的元件

1. **在現有頁面中使用新元件**
   - 更新 `KnowledgePage` 使用 `EmptyState`
   - 更新對話框使用 `ConfirmationDialog`
   - 添加 `MessageActionBar` 到訊息列表

2. **完善快捷鍵**
   - 整合到主應用
   - 添加更多快捷鍵
   - 實作快捷鍵處理邏輯

3. **實作搜尋功能**
   - 連接實際資料源
   - 實作搜尋演算法
   - 添加搜尋歷史持久化

4. **語言切換**
   - 整合到設定頁面
   - 實作動態切換
   - 更新所有硬編碼字串

---

## 📝 總結

所有元件都已建立並可立即使用！

**元件統計**:
- ✅ 14 個新元件
- ✅ 4 個核心元件
- ✅ 3 個聊天專用元件
- ✅ 2 個動畫元件
- ✅ 5 個工具類

**下一步**: 執行 `dart run build_runner build --delete-conflicting-outputs` 生成程式碼，然後開始整合這些元件！

---

**文件版本**: v1.0
**建立日期**: 2025-11-16
**作者**: Claude (Anthropic)
