#!/bin/bash
set -e

echo "=== Monopoli Indonesia — Production Build Script ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}Error: Flutter not found. Install from https://flutter.dev${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 1: Getting dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}Step 2: Running tests...${NC}"
flutter test

echo -e "${YELLOW}Step 3: Analyzing code...${NC}"
flutter analyze

echo ""
echo "=== Building targets ==="
echo ""

# Build Web PWA
echo -e "${YELLOW}Building Web PWA...${NC}"
flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first --base-href /
echo -e "${GREEN}Web build complete: build/web/${NC}"

# Build Android APK
echo -e "${YELLOW}Building Android APK...${NC}"
flutter build apk --release --split-per-abi
echo -e "${GREEN}Android APK build complete: build/app/outputs/flutter-apk/${NC}"

# Build Android App Bundle (for Play Store)
echo -e "${YELLOW}Building Android App Bundle...${NC}"
flutter build appbundle --release
echo -e "${GREEN}Android AAB build complete: build/app/outputs/bundle/release/${NC}"

echo ""
echo -e "${GREEN}=== All builds complete! ===${NC}"
echo ""
echo "Deploy web to Firebase Hosting:"
echo "  firebase deploy --only hosting"
echo ""
echo "Upload APK to Google Play Console:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
