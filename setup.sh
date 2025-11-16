#!/bin/bash

# Koopa Hub - Setup Script
# Run this script to generate all necessary code files

echo "🚀 Koopa Hub - Code Generation Setup"
echo ""

# 1. Install dependencies
echo "📦 Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✅ Dependencies installed"
echo ""

# 2. Generate localization files
echo "🌍 Generating localization files..."
flutter gen-l10n
if [ $? -ne 0 ]; then
    echo "❌ Failed to generate localization files"
    exit 1
fi
echo "✅ Localization files generated"
echo ""

# 3. Generate Riverpod code
echo "⚙️  Generating Riverpod provider code..."
dart run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "❌ Failed to generate Riverpod code"
    exit 1
fi
echo "✅ Riverpod code generated"
echo ""

echo "🎉 Setup complete! You can now run the app with:"
echo "   flutter run -d chrome    (for web)"
echo "   flutter run              (for desktop)"
