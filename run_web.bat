@echo off
REM Koopa Hub - Web Development Script (Windows)
REM 解決第一次啟動時 l10n 文件未生成的問題

echo 🚀 Starting Koopa Hub Web Development...

REM 1. 生成國際化文件（如果不存在）
if not exist "lib\l10n\app_localizations.dart" (
    echo 📝 Generating localization files...
    call flutter gen-l10n
    if errorlevel 1 (
        echo ❌ Failed to generate localization files
        exit /b 1
    )
    echo ✅ Localization files generated
)

REM 2. 生成 Riverpod 程式碼
echo 🔨 Generating Riverpod code...
call dart run build_runner build --delete-conflicting-outputs

REM 3. 運行應用
echo 🌐 Launching app on Chrome...
call flutter run -d chrome
