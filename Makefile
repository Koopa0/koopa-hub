.PHONY: help setup clean build run web watch lint format test

# 預設目標：顯示幫助
help:
	@echo "Koopa Hub - Makefile 指令"
	@echo ""
	@echo "開發指令："
	@echo "  make setup    - 初始化專案（安裝依賴 + 生成代碼）"
	@echo "  make build    - 生成 Riverpod 代碼"
	@echo "  make watch    - 監聽模式自動生成代碼"
	@echo "  make run      - 執行應用（桌面）"
	@echo "  make web      - 執行應用（Web/Chrome）"
	@echo ""
	@echo "程式碼品質："
	@echo "  make lint     - 執行 linter 檢查"
	@echo "  make format   - 格式化程式碼"
	@echo "  make test     - 執行測試"
	@echo ""
	@echo "清理："
	@echo "  make clean    - 清理建置快取"

# 初始化專案
setup:
	@echo "🚀 初始化 Koopa Hub..."
	@echo ""
	@echo "📦 安裝依賴..."
	flutter pub get
	@echo ""
	@echo "⚙️  生成 Riverpod 代碼..."
	dart run build_runner build --delete-conflicting-outputs
	@echo ""
	@echo "✅ 設定完成！"
	@echo ""
	@echo "執行應用："
	@echo "  make web    - Web 版本（Chrome）"
	@echo "  make run    - 桌面版本"

# 清理建置快取
clean:
	@echo "🧹 清理建置快取..."
	flutter clean
	@echo "✅ 清理完成"

# 生成 Riverpod 代碼
build:
	@echo "⚙️  生成 Riverpod 代碼..."
	dart run build_runner build --delete-conflicting-outputs

# 監聽模式（自動重新生成）
watch:
	@echo "👀 啟動監聽模式..."
	dart run build_runner watch --delete-conflicting-outputs

# 執行應用（桌面）
run:
	@echo "🚀 啟動應用（桌面）..."
	flutter run

# 執行應用（Web）
web:
	@echo "🌐 啟動應用（Chrome）..."
	flutter run -d chrome

# Linter 檢查
lint:
	@echo "🔍 執行 linter 檢查..."
	flutter analyze
	@echo ""
	@echo "🔍 執行 custom_lint 檢查..."
	dart run custom_lint

# 格式化程式碼
format:
	@echo "✨ 格式化程式碼..."
	dart format lib/ test/

# 執行測試
test:
	@echo "🧪 執行測試..."
	flutter test
