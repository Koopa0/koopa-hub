#!/bin/bash

# Koopa Hub - Web Development Script
# 解決第一次啟動時 l10n 文件未生成的問題

echo "🚀 Starting Koopa Hub Web Development..."

# 1. 生成國際化文件（如果不存在）
if [ ! -f ".dart_tool/flutter_gen/gen_l10n/app_localizations.dart" ]; then
    echo "📝 Generating localization files..."
    flutter gen-l10n
    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate localization files"
        exit 1
    fi
    echo "✅ Localization files generated"
fi

# 2. 生成 Riverpod 程式碼（如果需要）
echo "🔨 Generating Riverpod code..."
dart run build_runner build --delete-conflicting-outputs

# 3. 運行應用
echo "🌐 Launching app on Chrome..."
flutter run -d chrome
