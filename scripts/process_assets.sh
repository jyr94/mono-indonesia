#!/bin/bash

# ============================================================
# process_assets.sh
# Script untuk resize & konversi game asset Monopoli Indonesia
# sesuai spesifikasi di revamp.md
#
# REQUIREMENT: ImageMagick
# Install: brew install imagemagick
# ============================================================

# Warna output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_DIR="$PROJECT_ROOT/scripts/raw_assets"
OUTPUT_DIR="$PROJECT_ROOT/assets/images"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Monopoli Indonesia - Asset Processor v1.0   ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Cek ImageMagick
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
  echo -e "${RED}❌ ImageMagick tidak ditemukan!${NC}"
  echo -e "   Install dengan: ${YELLOW}brew install imagemagick${NC}"
  exit 1
fi

MAGICK_CMD="magick"
if ! command -v magick &> /dev/null; then
  MAGICK_CMD="convert"
fi

echo -e "${GREEN}✅ ImageMagick ditemukan${NC}"
echo -e "   Input  : ${YELLOW}$INPUT_DIR${NC}"
echo -e "   Output : ${YELLOW}$OUTPUT_DIR${NC}"
echo ""

# Buat direktori output
mkdir -p "$OUTPUT_DIR/board/tiles/properties"
mkdir -p "$OUTPUT_DIR/characters/token_red"
mkdir -p "$OUTPUT_DIR/characters/token_blue"
mkdir -p "$OUTPUT_DIR/characters/token_green"
mkdir -p "$OUTPUT_DIR/characters/token_yellow"
mkdir -p "$OUTPUT_DIR/dice"
mkdir -p "$OUTPUT_DIR/buildings"
mkdir -p "$OUTPUT_DIR/ui"
mkdir -p "$OUTPUT_DIR/background"
mkdir -p "$OUTPUT_DIR/particles"
mkdir -p "$INPUT_DIR"

# ============================================================
# FUNGSI: resize ke ukuran TEPAT, pertahankan transparansi
# ============================================================
resize_asset() {
  local src="$1"
  local dest="$2"
  local width="$3"
  local height="$4"
  local label="$5"

  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}⚠️  Skip: $label (tidak ada di input)${NC}"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  $MAGICK_CMD "$src" \
    -resize "${width}x${height}!" \
    -background none \
    -define png:color-type=6 \
    "$dest"

  if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ $label → ${width}x${height}px${NC}"
  else
    echo -e "  ${RED}❌ Gagal: $label${NC}"
  fi
}

# ============================================================
# 1. BOARD BASE — 2048x2048
# ============================================================
echo -e "${BLUE}📦 [1] BOARD BASE${NC}"
resize_asset "$INPUT_DIR/board_base.png" "$OUTPUT_DIR/board/board_base.png" 2048 2048 "board_base"
echo ""

# ============================================================
# 2. CORNER TILES — 256x256
# ============================================================
echo -e "${BLUE}📦 [2] CORNER & SPECIAL TILES (256x256)${NC}"
for tile in tile_go tile_jail tile_freeparking tile_gotojail tile_chance tile_community_chest; do
  resize_asset "$INPUT_DIR/$tile.png" "$OUTPUT_DIR/board/tiles/$tile.png" 256 256 "$tile"
done
echo ""

# ============================================================
# 3. PROPERTY TILES — 256x128
# ============================================================
echo -e "${BLUE}📦 [3] PROPERTY TILES (256x128)${NC}"
properties=(prop_malioboro prop_kraton prop_braga prop_asia_afrika prop_tunjungan
  prop_jembatan_suramadu prop_lawang_sewu prop_sam_poo_kong prop_tanah_lot
  prop_ubud prop_kuta_beach prop_monas prop_thamrin prop_sudirman
  prop_istana_negara prop_fort_rotterdam prop_losari_beach prop_raja_ampat prop_komodo)
for prop in "${properties[@]}"; do
  resize_asset "$INPUT_DIR/$prop.png" "$OUTPUT_DIR/board/tiles/properties/$prop.png" 256 128 "$prop"
done
for tile in tile_kereta tile_bandara tile_tol; do
  resize_asset "$INPUT_DIR/$tile.png" "$OUTPUT_DIR/board/tiles/$tile.png" 256 128 "$tile"
done
echo ""

# ============================================================
# 4. CHARACTER SPRITES — 512x512
# ============================================================
echo -e "${BLUE}📦 [4] CHARACTER SPRITES (512x512)${NC}"
for color in red blue green yellow; do
  for anim in idle walk celebrate; do
    resize_asset "$INPUT_DIR/token_${color}_${anim}.png" "$OUTPUT_DIR/characters/token_${color}/${anim}.png" 512 512 "token_${color}_${anim}"
  done
done
echo ""

# ============================================================
# 5. DICE — 256x256
# ============================================================
echo -e "${BLUE}📦 [5] DICE (256x256)${NC}"
for i in 1 2 3 4 5 6; do
  resize_asset "$INPUT_DIR/dice_face_$i.png" "$OUTPUT_DIR/dice/dice_face_$i.png" 256 256 "dice_face_$i"
done
resize_asset "$INPUT_DIR/dice_complete_3d.png" "$OUTPUT_DIR/dice/dice_complete_3d.png" 256 256 "dice_complete_3d"
resize_asset "$INPUT_DIR/dice_shadow.png" "$OUTPUT_DIR/dice/dice_shadow.png" 256 256 "dice_shadow"
echo ""

# ============================================================
# 6. BUILDINGS — 128x128
# ============================================================
echo -e "${BLUE}📦 [6] BUILDINGS (128x128)${NC}"
for building in house_1 house_2 house_3 house_4 hotel; do
  resize_asset "$INPUT_DIR/$building.png" "$OUTPUT_DIR/buildings/$building.png" 128 128 "$building"
done
echo ""

# ============================================================
# 7. UI ELEMENTS
# ============================================================
echo -e "${BLUE}📦 [7] UI ELEMENTS${NC}"
resize_asset "$INPUT_DIR/money_stack.png"              "$OUTPUT_DIR/ui/money_stack.png"       256 256 "money_stack"
resize_asset "$INPUT_DIR/bankruptcy_banner.png"        "$OUTPUT_DIR/ui/bankruptcy_banner.png" 512 256 "bankruptcy_banner"
resize_asset "$INPUT_DIR/winner_crown.png"             "$OUTPUT_DIR/ui/winner_crown.png"      256 256 "winner_crown"
resize_asset "$INPUT_DIR/ui_money_panel.png"           "$OUTPUT_DIR/ui/ui_money_panel.png"    512 128 "ui_money_panel"
resize_asset "$INPUT_DIR/card_chance_template.png"     "$OUTPUT_DIR/ui/card_chance.png"       512 768 "card_chance"
resize_asset "$INPUT_DIR/card_community_template.png"  "$OUTPUT_DIR/ui/card_community.png"    512 768 "card_community"
echo ""

# ============================================================
# 8. BACKGROUND — 2048xN
# ============================================================
echo -e "${BLUE}📦 [8] BACKGROUND LAYERS${NC}"
resize_asset "$INPUT_DIR/bg_sky_layer.png"       "$OUTPUT_DIR/background/bg_sky.png"       2048 1024 "bg_sky"
resize_asset "$INPUT_DIR/bg_mountains_layer.png" "$OUTPUT_DIR/background/bg_mountains.png" 2048 512  "bg_mountains"
resize_asset "$INPUT_DIR/bg_sea_layer.png"       "$OUTPUT_DIR/background/bg_sea.png"       2048 512  "bg_sea"
resize_asset "$INPUT_DIR/bg_islands_layer.png"   "$OUTPUT_DIR/background/bg_islands.png"   2048 512  "bg_islands"
echo ""

# ============================================================
# 9. PARTICLES — 64x64
# ============================================================
echo -e "${BLUE}📦 [9] PARTICLES (64x64)${NC}"
for particle in coin star money_rain confetti_red confetti_gold star_sparkle; do
  resize_asset "$INPUT_DIR/particle_$particle.png" "$OUTPUT_DIR/particles/$particle.png" 64 64 "particle_$particle"
done
echo ""

# ============================================================
# 10. ONBOARDING — 1024x1024
# ============================================================
echo -e "${BLUE}📦 [10] ONBOARDING (1024x1024)${NC}"
for onboard in board multiplayer; do
  resize_asset "$INPUT_DIR/onboarding_${onboard}.png" "$OUTPUT_DIR/ui/onboarding_${onboard}.png" 1024 1024 "onboarding_$onboard"
done

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}🎉 Selesai! Asset tersimpan di: assets/images/${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "📁 Cara pakai:"
echo -e "   1. Taruh semua raw asset di: ${YELLOW}scripts/raw_assets/${NC}"
echo -e "      (nama file harus sesuai, lihat list di atas)"
echo -e "   2. Jalankan: ${YELLOW}bash scripts/process_assets.sh${NC}"
