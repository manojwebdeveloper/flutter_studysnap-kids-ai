#!/bin/bash
# ─────────────────────────────────────────────────────────────
# StudySnap Kids AI — One-script setup
# Run: chmod +x setup.sh && ./setup.sh
# ─────────────────────────────────────────────────────────────
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  StudySnap Kids AI — Project Setup${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. Check Flutter
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}❌ Flutter not found. Install from https://flutter.dev${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Flutter found:${NC} $(flutter --version | head -1)"

# 2. Create asset directories
echo ""
echo -e "${YELLOW}→ Creating asset directories...${NC}"
mkdir -p assets/images assets/icons assets/fonts
touch assets/images/.gitkeep assets/icons/.gitkeep
echo -e "${GREEN}✓ Asset directories created${NC}"

# 3. Create .env if it doesn't exist
if [ ! -f ".env" ]; then
  echo ""
  echo -e "${YELLOW}→ Creating .env from template...${NC}"
  cp .env.example .env
  echo -e "${GREEN}✓ .env created${NC}"
  echo -e "${YELLOW}  ⚠️  Add your ANTHROPIC_API_KEY to .env before running${NC}"
else
  echo -e "${GREEN}✓ .env already exists${NC}"
fi

# 4. Flutter pub get
echo ""
echo -e "${YELLOW}→ Installing dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"

# 5. Code generation
echo ""
echo -e "${YELLOW}→ Running code generation (Drift + Riverpod + Freezed)...${NC}"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"

# 6. Check for Nunito fonts
echo ""
if [ -z "$(ls assets/fonts/*.ttf 2>/dev/null)" ]; then
  echo -e "${YELLOW}⚠️  Nunito font files missing from assets/fonts/${NC}"
  echo "   Download from https://fonts.google.com/specimen/Nunito"
  echo "   Required files:"
  echo "     assets/fonts/Nunito-Regular.ttf"
  echo "     assets/fonts/Nunito-SemiBold.ttf"
  echo "     assets/fonts/Nunito-Bold.ttf"
  echo "     assets/fonts/Nunito-ExtraBold.ttf"
  echo "     assets/fonts/Nunito-Black.ttf"
else
  echo -e "${GREEN}✓ Nunito fonts found${NC}"
fi

# 7. Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Add ANTHROPIC_API_KEY to .env"
echo "  2. Add Nunito font files to assets/fonts/ (if not done)"
echo "  3. Run:  flutter run"
echo ""
echo "For iOS — Info.plist is at ios/Runner/Info.plist (already configured)"
echo "For GitHub:"
echo "  git init && git add . && git commit -m 'feat: initial commit'"
echo "  gh repo create manojwebdeveloper/studysnap-kids-ai --private --source=. --push"
echo ""
