# Koopa Hub

一個功能完整的跨平台（桌面端優先、支援 Web）AI Hub，基於 Flutter 3.38 和 Material 3 設計。

## 專案簡介

Koopa Hub 是一個現代化的 AI Hub 應用，提供：

- **多模型聊天**：支援本地 RAG、網路搜尋和 Gemini 雲端模型
- **知識庫管理**：文件索引、向量檢索和智能搜尋
- **跨平台支援**：Windows、macOS、Linux 桌面端和 Web
- **現代化 UI**：基於 Material 3 設計，支援深淺主題
- **即時串流**：AI 回應的即時串流顯示

## 技術棧

### 前端
- **Flutter 3.38**：最新的 Flutter 框架
- **Material 3**：Google 最新設計語言
- **Riverpod 3.0**：現代化的狀態管理（使用程式碼生成）
- **Dart 3.10**：支援 records、pattern matching 等最新特性

### 主要依賴
- `flutter_riverpod ^3.0.0`：狀態管理
- `flutter_markdown ^0.7.3`：Markdown 渲染
- `flutter_highlighter ^0.1.1`：程式碼高亮
- `hive_flutter ^1.1.0`：本地資料庫
- `dio ^5.4.3`：HTTP 客戶端

## 快速開始

### 前置要求

- Flutter SDK >= 3.38.0
- Dart SDK >= 3.10.0

### 安裝步驟

1. **克隆專案**
```bash
git clone https://github.com/Koopa0/koopa-hub.git
cd koopa-hub
```

2. **安裝依賴**
```bash
flutter pub get
```

3. **生成 Riverpod 程式碼**
```bash
# 一次性生成
dart run build_runner build --delete-conflicting-outputs

# 或者監聽模式（開發時推薦）
dart run build_runner watch --delete-conflicting-outputs
```

4. **運行應用**

**推薦方式（使用啟動腳本）：**
```bash
# macOS / Linux
./run_web.sh

# Windows
run_web.bat
```

這個腳本會自動：
- 生成國際化文件（第一次運行時）
- 生成 Riverpod 程式碼
- 啟動應用在 Chrome

**手動運行：**
```bash
# 第一次運行需要先生成 l10n 文件
flutter gen-l10n

# 生成 Riverpod 程式碼
dart run build_runner build --delete-conflicting-outputs

# 桌面端
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux

# Web 端
flutter run -d chrome
```

## 專案結構

```
lib/
├── main.dart                      # 應用入口
├── app.dart                       # 主應用 Widget
├── core/                          # 核心功能
│   ├── theme/                     # 主題配置
│   │   └── app_theme.dart
│   ├── constants/                 # 常數定義
│   │   └── app_constants.dart
│   └── utils/                     # 工具函數
├── features/                      # 功能模組
│   ├── home/                      # 首頁
│   │   └── home_page.dart
│   ├── chat/                      # 聊天功能
│   │   ├── models/                # 資料模型
│   │   │   ├── message.dart
│   │   │   └── chat_session.dart
│   │   ├── providers/             # 狀態管理
│   │   │   ├── chat_provider.dart
│   │   │   └── chat_provider.g.dart  # 生成的程式碼
│   │   ├── pages/                 # 頁面
│   │   │   └── chat_page.dart
│   │   └── widgets/               # 組件
│   │       ├── session_sidebar.dart
│   │       ├── message_list.dart
│   │       ├── chat_input.dart
│   │       └── model_selector.dart
│   ├── knowledge/                 # 知識庫功能
│   │   ├── models/
│   │   │   └── knowledge_document.dart
│   │   ├── providers/
│   │   │   ├── knowledge_provider.dart
│   │   │   └── knowledge_provider.g.dart
│   │   ├── pages/
│   │   │   └── knowledge_page.dart
│   │   └── widgets/
│   │       ├── document_list.dart
│   │       └── knowledge_stats.dart
│   └── settings/                  # 設定功能
│       ├── providers/
│       │   ├── settings_provider.dart
│       │   └── settings_provider.g.dart
│       └── pages/
│           └── settings_page.dart
└── shared/                        # 共享組件
    └── widgets/
```

## 功能特性

### 聊天功能 (FS-1)
- [x] 建立、切換和刪除聊天會話
- [x] 即時顯示 AI 的串流回應
- [x] Markdown 和程式碼高亮渲染
- [x] 一鍵清除對話歷史
- [x] 會話置頂功能

### 知識庫管理 (FS-2)
- [x] 顯示已索引的文件列表
- [x] 檔案選擇器添加文件/資料夾
- [x] 刪除文件功能
- [x] 索引狀態顯示（等待、索引中、已索引、失敗）
- [x] 統計資訊儀表板

### AI 模型選擇 (FS-3)
- [x] Koopa (本地 RAG)：使用本地 pgvector 資料
- [x] Koopa (網路搜尋)：使用 httpGet 工具
- [x] Gemini (雲端)：直接呼叫 Gemini API
- [x] 引用來源顯示（Citations）
- [x] API Key 設定介面

### 設定功能
- [x] 伺服器 URL 配置
- [x] Gemini API Key 管理
- [x] 主題模式切換（系統/淺色/深色）
- [x] 伺服器連接測試

## 開發指南

### Riverpod 程式碼生成

本專案使用 Riverpod 3.0 的程式碼生成功能。每當修改 provider 時：

```bash
# 重新生成
dart run build_runner build --delete-conflicting-outputs
```

### 使用 watch 模式（推薦）

在開發時，使用 watch 模式可以自動監聽檔案變更並重新生成：

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 主題自訂

修改 `lib/core/theme/app_theme.dart` 來自訂應用主題：

```dart
static const Color primaryColor = Color(0xFF6750A4);  // 修改主色調
```

### 添加新功能

1. 在 `lib/features/` 下建立新的功能目錄
2. 遵循現有的目錄結構（models, providers, pages, widgets）
3. 使用 `@riverpod` 註解建立 provider
4. 運行 `build_runner` 生成程式碼

## 待實作功能

目前前端 UI 已完成，以下功能需要後端支援：

- [ ] 連接到 koopa-server HTTP API
- [ ] 實現串流聊天回應
- [ ] 實現知識庫索引 API 呼叫
- [ ] 實現檔案上傳和處理
- [ ] 實現 RAG 檢索功能
- [ ] 實現網路搜尋功能
- [ ] Hive 資料持久化
- [ ] 桌面端進程管理（啟動/停止 koopa-server）

## 建構發布版本

### 桌面端

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

### Web

```bash
flutter build web --release
```

## 貢獻指南

歡迎貢獻！請遵循以下步驟：

1. Fork 本專案
2. 建立您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟一個 Pull Request

## 授權

本專案採用 MIT 授權 - 詳見 [LICENSE](LICENSE) 檔案

## 相關連結

- [Flutter 官方文檔](https://docs.flutter.dev/)
- [Riverpod 文檔](https://riverpod.dev/)
- [Material 3 設計規範](https://m3.material.io/)
- [koopa-cli 專案](https://github.com/Koopa0/koopa-cli)
