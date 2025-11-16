# Koopa Hub

跨平台 AI 助手中心，支援本地 RAG、多模型聊天和實時網路搜索。

## 前置需求

- Flutter 3.38+ (包含 Dart 3.10+)
- Chrome（用於 Web 開發）

## 快速開始

### 初始化專案

```bash
make setup
```

這會自動：
1. 安裝所有依賴 (`flutter pub get`)
2. 生成 Riverpod 代碼 (`build_runner`)

### 執行應用

**Web 版本（Chrome）：**
```bash
make web
```

**桌面版本：**
```bash
make run
```

## 開發指令

查看所有可用指令：
```bash
make help
```

常用指令：
- `make setup` - 初始化專案
- `make build` - 生成 Riverpod 代碼
- `make watch` - 監聽模式（自動重新生成）
- `make web` - 執行 Web 版本
- `make run` - 執行桌面版本
- `make lint` - 執行 linter 檢查
- `make format` - 格式化程式碼
- `make clean` - 清理建置快取

## 技術棧

- **框架**: Flutter 3.38 / Dart 3.10
- **狀態管理**: Riverpod 3.0（程式碼生成）
- **UI**: Material Design 3
- **本地儲存**: Hive + SharedPreferences
- **Markdown 渲染**: flutter_markdown + flutter_highlighter

## 專案結構

```
lib/
├── core/
│   └── constants/
│       ├── app_constants.dart      # 應用常數
│       └── design_tokens.dart      # 設計系統常數
├── features/
│   ├── chat/                       # 聊天功能
│   │   ├── models/
│   │   ├── providers/              # Riverpod providers
│   │   └── widgets/
│   ├── knowledge/                  # 知識庫功能
│   │   ├── models/
│   │   ├── providers/
│   │   └── pages/
│   └── settings/                   # 設定功能
│       ├── providers/
│       └── pages/
└── main.dart
```

## 最佳實踐

本專案遵循 Flutter 3.38 和 Dart 3.10 最佳實踐：

✅ Riverpod 3.0 程式碼生成 (`@riverpod` 註解)
✅ Material Design 3 ColorScheme（無硬編碼顏色）
✅ 設計系統 (8dp 網格、一致的間距)
✅ AsyncNotifier 模式處理非同步狀態
✅ Record types 作為資料模型（Dart 3.0+ 特性）
✅ 完整的錯誤處理 (AsyncValue.guard)

## 程式碼生成

### 自動生成的檔案

以下檔案由 build_runner 自動生成，**請勿手動編輯**：

- `*.g.dart` - Riverpod provider 生成檔案

這些檔案已加入 `.gitignore`，每次 clone 專案後需要執行 `make setup` 重新生成。

### 手動生成代碼

如需手動重新生成：

```bash
# 單次生成
dart run build_runner build --delete-conflicting-outputs

# 監聽模式（檔案變更時自動生成）
dart run build_runner watch --delete-conflicting-outputs
```

或使用 Makefile：
```bash
make build  # 單次生成
make watch  # 監聽模式
```

## 疑難排解

### "Type 'XxxRef' not found" 或類似錯誤

**原因**: Riverpod 生成的檔案不存在

**解決方法**:
```bash
make clean
make setup
```

### 建置快取問題

```bash
make clean
flutter pub get
make build
```

## 授權

MIT License
