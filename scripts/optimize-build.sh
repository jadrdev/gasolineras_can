#!/bin/bash

echo "🚀 Optimizando compilación de Flutter..."

# Limpiar cache de Flutter
echo "🧹 Limpiando cache de Flutter..."
flutter clean

# Limpiar cache de CocoaPods
echo "🧹 Limpiando cache de CocoaPods..."
cd ios && pod cache clean --all && cd ..

# Obtener dependencias optimizadas
echo "📦 Obteniendo dependencias..."
flutter pub get

# Optimizar CocoaPods para iOS
echo "🍎 Optimizando CocoaPods..."
cd ios
pod deintegrate 2>/dev/null || true
pod setup
pod install --repo-update
cd ..

# Pre-compilar dependencias para debug
echo "⚡ Pre-compilando para debug..."
flutter build ios --debug --no-codesign

echo "✅ Optimización completada!"
echo "💡 Tip: La primera compilación después de esto puede ser lenta, pero las siguientes serán mucho más rápidas."
