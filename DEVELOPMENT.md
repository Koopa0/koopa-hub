# 開發指南

本文件提供 Koopa Hub 的詳細開發指南，幫助開發者快速上手。

## 目錄

- [環境設定](#環境設定)
- [專案架構](#專案架構)
- [編碼規範](#編碼規範)
- [常見問題](#常見問題)
- [最佳實踐](#最佳實踐)

## 環境設定

### 1. 安裝 Flutter

確保您已安裝 Flutter 3.38 或更高版本：

```bash
flutter --version
```

如果需要更新 Flutter：

```bash
flutter upgrade
```

### 2. IDE 設定

推薦使用 VS Code 或 Android Studio：

**VS Code 擴展：**
- Flutter
- Dart
- Riverpod Snippets

**Android Studio 插件：**
- Flutter
- Dart

### 3. 程式碼生成設定

本專案使用 `build_runner` 進行程式碼生成。建議在終端保持 watch 模式運行：

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 專案架構

### 資料夾結構說明

```
lib/
├── main.dart              # 應用入口，處理初始化
├── app.dart               # MaterialApp 配置
├── core/                  # 核心功能（主題、常數、工具）
├── features/              # 功能模組（按功能劃分）
└── shared/                # 共享組件
```

### 功能模組結構

每個功能模組遵循以下結構：

```
feature_name/
├── models/       # 資料模型（不可變類別）
├── providers/    # 狀態管理（Riverpod）
├── pages/        # 頁面級 UI
└── widgets/      # 可重用組件
```

## 編碼規範

### Dart 風格指南

遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 規範：

1. **命名規範**
   - 類別：`PascalCase`
   - 變數/函數：`camelCase`
   - 常數：`camelCase` 或 `UPPER_SNAKE_CASE`
   - 私有成員：`_leadingUnderscore`

2. **程式碼格式化**
```bash
# 格式化所有檔案
dart format .

# 格式化特定檔案
dart format lib/features/chat/
```

3. **Lint 檢查**
```bash
# 執行 lint 檢查
dart analyze

# 修復可自動修復的問題
dart fix --apply
```

### Riverpod 最佳實踐

#### 1. 使用 Code Generation

**推薦：**
```dart
@riverpod
class ChatSessions extends _$ChatSessions {
  @override
  List<ChatSession> build() {
    return [];
  }
}
```

**不推薦：**
```dart
final chatSessionsProvider = StateNotifierProvider<...>(...);
```

#### 2. Provider 命名

- Notifier 類別：`XxxNotifier` 或直接用功能名（如 `ChatSessions`）
- 生成的 provider：自動生成為 `xxxProvider`

#### 3. 衍生 Provider

使用 `Provider` 或 `@riverpod` 建立衍生狀態：

```dart
final currentSessionProvider = Provider<ChatSession?>((ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  // ... 邏輯
});
```

### Widget 最佳實踐

#### 1. 使用 ConsumerWidget

**推薦：**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text('$value');
  }
}
```

#### 2. 提取私有 Widget

將複雜的 UI 拆分為私有 widget：

```dart
class _TopBar extends StatelessWidget {
  const _TopBar();
  // ...
}
```

#### 3. 使用 const 構造函數

盡可能使用 `const`：

```dart
const SizedBox(height: 16),  // 推薦
SizedBox(height: 16),         // 不推薦
```

## 常見問題

### Q: 為什麼我的 provider 報錯找不到？

**A:** 可能需要重新生成程式碼：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Q: 如何調試 Riverpod 狀態？

**A:** 使用 Riverpod 的 observer：

```dart
class MyObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('Provider ${provider.name} updated: $newValue');
  }
}

// 在 main.dart 中
runApp(
  ProviderScope(
    observers: [MyObserver()],
    child: MyApp(),
  ),
);
```

### Q: 如何處理異步初始化？

**A:** 使用 `AsyncNotifier`：

```dart
@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    // 異步載入資料
    final prefs = await SharedPreferences.getInstance();
    return loadSettings(prefs);
  }
}
```

### Q: Material 3 主題如何自訂？

**A:** 修改 `lib/core/theme/app_theme.dart`：

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),  // 改變種子顏色
  brightness: Brightness.light,
)
```

## 最佳實踐

### 1. 狀態管理

- **單一數據源**：避免在多個 provider 中複製相同資料
- **細粒度更新**：只監聽需要的部分
- **不可變性**：使用 `copyWith` 更新物件

### 2. 效能優化

- **使用 const**：減少 widget 重建
- **避免匿名函數**：在 build 方法中避免建立新的回調
- **使用 Provider.select**：只監聽需要的欄位

```dart
// 推薦
final title = ref.watch(sessionProvider.select((s) => s?.title));

// 不推薦（會在整個 session 變化時重建）
final session = ref.watch(sessionProvider);
final title = session?.title;
```

### 3. 錯誤處理

使用 `AsyncValue` 處理異步狀態：

```dart
final settingsAsync = ref.watch(settingsProvider);

return settingsAsync.when(
  data: (settings) => _buildContent(settings),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### 4. 測試

編寫單元測試和 widget 測試：

```dart
void main() {
  test('Message model should create correctly', () {
    final message = Message.user('Hello');
    expect(message.content, 'Hello');
    expect(message.type, MessageType.user);
  });
}
```

### 5. 文檔

為公共 API 添加文檔註解：

```dart
/// 聊天訊息模型
///
/// 這是一個不可變的資料類別，代表一條聊天訊息。
/// 支援使用者訊息、AI 訊息和系統訊息。
class Message {
  // ...
}
```

## 工作流程

### 添加新功能

1. **建立功能分支**
```bash
git checkout -b feature/new-feature
```

2. **建立模組結構**
```bash
mkdir -p lib/features/new_feature/{models,providers,pages,widgets}
```

3. **實作功能**
   - 先定義 models
   - 然後實作 providers
   - 最後建立 UI (pages & widgets)

4. **生成程式碼**
```bash
dart run build_runner build --delete-conflicting-outputs
```

5. **測試**
```bash
flutter test
```

6. **提交**
```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

## 除錯技巧

### Flutter DevTools

啟用 DevTools 進行效能分析：

```bash
flutter run
# 然後按 'v' 開啟 DevTools
```

### Riverpod Inspector

使用 Riverpod 的 inspector 查看 provider 狀態：

1. 在 DevTools 中選擇 "Riverpod" 標籤
2. 查看所有 provider 的當前值
3. 追蹤狀態變化

### 日誌

使用 `logger` 套件：

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

## 資源

- [Flutter 文檔](https://docs.flutter.dev/)
- [Riverpod 文檔](https://riverpod.dev/)
- [Material 3 指南](https://m3.material.io/)
- [Dart 語言導覽](https://dart.dev/guides)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
