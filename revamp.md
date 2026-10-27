# 🎮 REVAMP: Monopoli Indonesia — Visual & Engine Upgrade

> Dokumen ini merinci rencana lengkap upgrade visual game dari Flutter widget biasa ke **Flame engine** dengan asset 3D/2.5D bergaya cartoon Indonesia yang menarik. Setiap section mencakup rencana teknis, kebutuhan asset, dan **prompt siap pakai** untuk generate di AI image generator.

---

## 📋 Ringkasan Revamp

| Aspek | Sekarang | Setelah Revamp |
|-------|----------|----------------|
| Rendering engine | Flutter Widget + CustomPainter | **Flame 2D Game Engine** |
| Board | Matrix4 perspective transform | **Isometric 2.5D board** dengan tile art |
| Token pemain | Widget lingkaran sederhana | **Karakter animasi 4-arah sprite** |
| Dadu | Icon + animasi rotation | **3D dice dengan physics bounce** |
| Landmark tiles | Foto JPG + SVG flat | **Illustrated isometric landmark** |
| Rumah/Hotel | Box kecil berwarna | **3D-style mini building sprite** |
| Background | Gradient solid | **Parallax Indonesia panorama** |
| UI overlay | Material widgets | **Flame + Flutter hybrid overlay** |
| Efek & partikel | Konfeti sederhana | **Coin rain, dust, light beam** |
| Suara | AudioPlayers basic | **Flame Audio dengan spatial cues** |

---

## 🏗️ Arsitektur Flame

### Dependency baru (`pubspec.yaml`)
```yaml
dependencies:
  flame: ^1.18.0              # Core game engine
  flame_tiled: ^1.20.0        # Tiled map loader (isometric board)
  flame_audio: ^2.11.0        # Audio management
  flame_riverpod: ^5.0.0      # Riverpod integration dengan Flame
  flame_lottie: ^0.3.1        # Lottie animation dalam Flame
```

### Struktur folder baru
```
lib/
├── game/                      ← NEW: Flame game world
│   ├── monopoli_game.dart      ← FlameGame root class
│   ├── components/
│   │   ├── board_component.dart     ← IsometricBoard (PositionComponent)
│   │   ├── tile_component.dart      ← Setiap tile sebagai SpriteComponent
│   │   ├── player_component.dart    ← Token dengan SpriteAnimationComponent
│   │   ├── dice_component.dart      ← 3D dice dengan physics
│   │   ├── house_component.dart     ← Rumah/hotel sprite
│   │   └── particle_component.dart  ← Efek partikel
│   └── overlays/
│       ├── hud_overlay.dart         ← Flutter widget HUD di atas Flame
│       ├── action_overlay.dart      ← Tombol aksi
│       └── chat_overlay.dart        ← Chat panel
assets/
├── images/                    ← TETAP + tambahan
│   ├── board/                  ← NEW
│   │   ├── board_base.png      ← Isometric board background
│   │   ├── tiles/              ← 40 tile artwork individual
│   │   │   ├── tile_go.png
│   │   │   ├── tile_jail.png
│   │   │   ├── ... (semua tile)
│   │   │   └── properties/     ← Per landmark
│   │   │       ├── monas.png
│   │   │       ├── borobudur.png
│   │   │       └── ... (24 properti)
│   ├── characters/             ← NEW: Token karakter
│   │   ├── token_red/
│   │   │   ├── idle.png        ← Sprite sheet idle (4 arah)
│   │   │   ├── walk.png        ← Sprite sheet jalan
│   │   │   └── celebrate.png   ← Sprite sheet menang
│   │   ├── token_blue/ ...
│   │   ├── token_green/ ...
│   │   └── token_yellow/ ...
│   ├── dice/                   ← NEW: Dice 3D
│   │   ├── dice_sheet.png      ← Sprite sheet 6 muka dadu
│   │   └── dice_shadow.png     ← Drop shadow
│   ├── buildings/              ← NEW
│   │   ├── house_1.png         ← 1 rumah
│   │   ├── house_2.png         ← 2 rumah
│   │   ├── house_3.png         ← 3 rumah
│   │   ├── house_4.png         ← 4 rumah
│   │   └── hotel.png           ← Hotel
│   ├── ui/                     ← NEW: UI elements
│   │   ├── card_chance.png
│   │   ├── card_community.png
│   │   ├── money_stack.png
│   │   ├── bankruptcy_banner.png
│   │   └── winner_crown.png
│   ├── background/             ← NEW
│   │   ├── bg_sky.png          ← Layer langit (parallax)
│   │   ├── bg_mountains.png    ← Layer gunung
│   │   ├── bg_sea.png          ← Layer laut
│   │   └── bg_islands.png      ← Layer pulau
│   └── particles/              ← NEW
│       ├── coin.png
│       ├── confetti_red.png
│       ├── confetti_gold.png
│       └── star_sparkle.png
├── tiled/                      ← NEW: Tiled map files
│   └── board.tmj               ← Isometric board map
└── audio/                      ← TETAP + tambahan
    ├── ... (existing)
    ├── dice_roll_3d.mp3        ← NEW: Suara dadu realistis
    ├── building_place.mp3      ← NEW: Suara bangun gedung
    └── coin_collect.mp3        ← NEW: Suara koin
```

---

## 🎨 Katalog Asset & AI Prompts

> **Panduan penggunaan prompt:**
> - Tool rekomendasi: **Midjourney v6**, **Leonardo.ai**, atau **Adobe Firefly**
> - Tambahkan `--ar 1:1` untuk sprite/token, `--ar 2:1` untuk board tile landscape
> - Semua asset harus punya **background transparan (PNG)**
> - Style konsisten: `cartoon isometric, vibrant colors, Indonesian theme, game asset, clean outline`

---

### 🗺️ 1. BOARD & TILES

#### 1.1 Board Base (Isometric)

**File:** `assets/images/board/board_base.png`
**Ukuran:** 2048×2048 px
**Format:** PNG

```
PROMPT:
Isometric game board for Indonesian Monopoly board game, 
top-down 45-degree angle view, square board with 10 tiles 
on each side, lush green center area with Indonesian landmark 
illustrations (Monas tower, Borobudur temple, Komodo dragon, 
Raja Ampat ocean), warm colorful cartoon style, batik pattern 
border decoration, gold and red color scheme, high detail 
game board texture, vibrant tropical colors, clean game art 
style, white background, transparent background, 4K resolution
```

---

#### 1.2 Corner Tiles (4 buah)

**File:** `assets/images/board/tiles/tile_go.png`, dll
**Ukuran:** 256×256 px masing-masing

```
PROMPT tile_go.png:
Isometric game tile for "GO" space in Indonesian Monopoly, 
cartoon style, bold red arrow pointing right with "MULAI" 
text in Indonesian, gold coin decorations, festive Indonesian 
batik border, 3D cartoon style, vibrant colors, white background,
clean game asset style, high contrast, no text except "MULAI"
```

```
PROMPT tile_jail.png:
Isometric game tile for jail/prison space, Indonesian cartoon 
style, cute cartoon jail bars with small character peeking 
through, blue color scheme, "PENJARA" text, playful not scary, 
Indonesian game art style, vibrant colors, white background
```

```
PROMPT tile_freeparking.png:
Isometric game tile for free parking, Indonesian cartoon style,
cute warung (Indonesian street food stall) with umbrella,
relaxing tropical vibe, green color scheme, palm trees,
"PARKIR GRATIS" text, warm colors, game asset style
```

```
PROMPT tile_gotojail.png:
Isometric game tile for "Go to Jail" space, Indonesian cartoon 
style, friendly police officer (satpol PP) pointing finger,
red warning colors, "KE PENJARA" text, dramatic but cute cartoon
style, high contrast, clean white background
```

---

#### 1.3 Property Tiles — Landmark Indonesia (24 buah)

**Ukuran:** 256×128 px (landscape untuk tile kecil di pinggir board)

**File naming:** `assets/images/board/tiles/properties/[nama_kota]_[nama].png`

---

**YOGYAKARTA GROUP (coklat/brown)**

```
PROMPT prop_malioboro.png:
Isometric cartoon illustration of Malioboro Street Yogyakarta,
Indonesia, bustling street market with colorful batik shops,
becak (bicycle rickshaw) in foreground, traditional Javanese
architecture, warm yellow-orange lighting, game tile art style,
vibrant cartoon colors, 2.5D isometric view, clean outline,
transparent background
```

```
PROMPT prop_kraton.png:
Isometric cartoon illustration of Kraton Yogyakarta (Sultan's Palace),
traditional Javanese royal palace architecture, ornate golden gates,
royal guards in traditional costume, warm amber colors,
game tile art style, vibrant cartoon, isometric view
```

---

**BANDUNG GROUP (biru muda/light blue)**

```
PROMPT prop_braga.png:
Isometric cartoon illustration of Jalan Braga Bandung Indonesia,
Dutch colonial architecture buildings, vintage cafe with outdoor
seating, warm Edison light bulbs, art deco style mixed with
tropical plants, cool blue-purple evening lighting, game art style
```

```
PROMPT prop_asia_afrika.png:
Isometric cartoon illustration of Asia Afrika Street Bandung,
historic colonial buildings, Gedung Merdeka (Independence Hall)
in background, classic cars, flags, warm afternoon lighting,
Indonesian game art style, cartoon isometric
```

---

**SURABAYA GROUP (merah muda/pink)**

```
PROMPT prop_tunjungan.png:
Isometric cartoon illustration of Tunjungan Plaza area Surabaya
Indonesia, modern shopping mall with hero monument (patung suroboyo)
nearby, city skyline, vibrant urban cartoon style, game tile art,
warm lighting, detailed architectural elements
```

```
PROMPT prop_jembatan_suramadu.png:
Isometric cartoon illustration of Suramadu Bridge (Jembatan Suramadu)
Surabaya, longest bridge in Indonesia spanning over blue sea,
suspension cables, ships passing underneath, golden sunset,
dramatic lighting, cartoon game art style, epic scale
```

---

**SEMARANG GROUP (oranye/orange)**

```
PROMPT prop_lawang_sewu.png:
Isometric cartoon illustration of Lawang Sewu (Thousand Doors) 
Semarang Indonesia, Dutch colonial landmark with many windows,
slightly mysterious but beautiful, warm afternoon light filtering
through arched doors, cartoon game art style, detailed architecture
```

```
PROMPT prop_sam_poo_kong.png:
Isometric cartoon illustration of Sam Poo Kong Temple Semarang,
Chinese-Javanese temple architecture, red lanterns, pagoda roof,
tropical garden, colorful and vibrant, cartoon game art style,
festive atmosphere
```

---

**BALI GROUP (hijau/green)**

```
PROMPT prop_tanah_lot.png:
Isometric cartoon illustration of Tanah Lot Temple Bali Indonesia,
temple on rocky island surrounded by ocean waves, dramatic sunset
sky, tropical palm trees, Balinese architecture with tiered roofs,
vibrant cartoon game art style, epic ocean scenery
```

```
PROMPT prop_ubud.png:
Isometric cartoon illustration of Ubud Bali Indonesia, rice terrace 
valley with lush green paddies, traditional Balinese dancer in
foreground, monkey forest, tropical greenery, magical atmosphere,
vibrant cartoon game art style
```

```
PROMPT prop_kuta_beach.png:
Isometric cartoon illustration of Kuta Beach Bali, white sandy
beach with surfers, beach umbrellas, food vendors, sunset sky,
tropical palm trees, vibrant holiday atmosphere, cartoon game art
style, warm golden lighting
```

---

**JAKARTA GROUP (biru tua/dark blue)**

```
PROMPT prop_monas.png:
Isometric cartoon illustration of Monas (National Monument) Jakarta
Indonesia, tall golden-tipped obelisk monument, surrounding park
with Indonesian flag, modern city buildings in background, proud
nationalist atmosphere, vibrant cartoon game art style, dramatic
lighting with golden flame top
```

```
PROMPT prop_thamrin.png:
Isometric cartoon illustration of Jalan Thamrin Jakarta CBD,
modern skyscrapers, Hotel Indonesia Roundabout (Bundaran HI)
with welcome statue, busy urban traffic, TransJakarta bus,
modern city cartoon game art style, blue sky
```

```
PROMPT prop_sudirman.png:
Isometric cartoon illustration of Jalan Sudirman Jakarta,
modern skyscraper district, MRT Jakarta elevated rail,
international financial center vibe, luxury towers, modern
Indonesian city, vibrant cartoon game art style, daytime
```

```
PROMPT prop_istana_negara.png:
Isometric cartoon illustration of Istana Negara (State Palace)
Jakarta Indonesia, grand white colonial palace with Indonesian
presidential guards, red-white Indonesian flag, ceremonial
grandeur, vibrant cartoon game art style, patriotic atmosphere
```

---

**MAKASSAR GROUP (merah/red - paling mahal)**

```
PROMPT prop_fort_rotterdam.png:
Isometric cartoon illustration of Fort Rotterdam (Benteng Rotterdam)
Makassar Sulawesi Indonesia, Dutch colonial fort with thick stone
walls, cannons, Makassar Strait sea visible in background,
historical atmosphere, vibrant cartoon game art style
```

```
PROMPT prop_losari_beach.png:
Isometric cartoon illustration of Losari Beach (Pantai Losari)
Makassar Indonesia, famous sunset pier with "PANTAI LOSARI" sign,
seafood stalls, cool sea breeze atmosphere, spectacular sunset
with orange-purple sky, vibrant cartoon game art style
```

---

**RAJA AMPAT GROUP (hijau tua/dark green - paling mahal)**

```
PROMPT prop_raja_ampat.png:
Isometric cartoon illustration of Raja Ampat Islands Papua Indonesia,
crystal clear turquoise water with mushroom-shaped limestone islands
covered in dense jungle, colorful tropical fish visible through water,
ultimate tropical paradise, vibrant cartoon game art style, 
breathtaking natural beauty, paradise vibe
```

```
PROMPT prop_komodo.png:
Isometric cartoon illustration of Komodo National Park Indonesia,
Komodo dragon on pink beach with white-pink sand, dramatic volcanic
hills, turquoise sea, adventurous atmosphere, majestic prehistoric
creature, vibrant cartoon game art style, epic natural setting
```

---

#### 1.4 Special Tiles (Chance & Community Chest)

```
PROMPT tile_chance.png:
Game tile card for chance/luck in Indonesian board game,
bright orange with golden question mark, Indonesian batik 
decorative border, "KESEMPATAN" text, cartoon game style,
glowing magical effect, coin and star decorations, vibrant
```

```
PROMPT tile_community_chest.png:
Game tile card for community chest in Indonesian board game,
bright blue with treasure chest filled with Indonesian rupiah bills,
"DANA UMUM" text, decorative Indonesian batik border, cartoon
game style, warm welcoming feel, coins spilling out
```

---

#### 1.5 Utility Tiles

```
PROMPT tile_kereta.png:
Isometric cartoon Indonesian train (KRL Commuter / KA intercity),
red and white train on rails, Indonesian Railway (KAI) style,
motion blur effect showing speed, game tile art, vibrant cartoon
```

```
PROMPT tile_bandara.png:
Isometric cartoon Indonesian airport terminal, modern glass 
architecture with Garuda Indonesia plane taking off, Indonesian
tropical sky, game tile art style, vibrant cartoon, clean
```

```
PROMPT tile_tol.png:
Isometric cartoon Indonesian toll road (jalan tol), cars passing
through toll gate, Trans-Java highway sign, tropical landscape,
game tile art style, vibrant colors
```

---

### 🧍 2. CHARACTER TOKENS (4 Karakter)

**Ukuran sprite sheet:** 512×512 px (4×4 grid = 16 frames per animasi)
**Format:** PNG transparan

> Setiap token punya: idle animation, walk animation, celebrate animation

---

```
PROMPT token_merah (Karakter Komodo):
Cute cartoon game token character, small adorable Komodo dragon 
standing upright like a person, wearing red bandana and batik vest,
confident pose, big expressive eyes, chubby cartoon style, 
Indonesian game character, pixel art inspired but smooth,
idle animation pose, transparent background, 512x512px,
game character sprite sheet style, red color theme
```

```
**Ukuran sprite sheet:** 512×512 px (4×4 grid = 16 frames per animasi)
**Format:** PNG transparan

> Setiap token punya: idle animation, walk animation, celebrate animation
PROMPT token_biru (Karakter Pendekar):
Cute cartoon game token character, small adorable Indonesian 
warrior (pendekar) with blue traditional headband (ikat kepala),
batik sarong, holding small keris dagger, confident warrior pose,
big expressive eyes, chubby cartoon style, game character sprite,
transparent background, blue color theme
```

```
**Ukuran sprite sheet:** 512×512 px (4×4 grid = 16 frames per animasi)
**Format:** PNG transparan

> Setiap token punya: idle animation, walk animation, celebrate animation
PROMPT token_hijau (Karakter Petani):
Cute cartoon game token character, small adorable Indonesian farmer
wearing green traditional Javanese hat (caping), batik shirt, holding
small hoe, cheerful and hardworking pose, big expressive eyes,
chubby cartoon style, game character sprite, transparent background,
green color theme, rustic charm
```

```
**Ukuran sprite sheet:** 512×512 px (4×4 grid = 16 frames per animasi)
**Format:** PNG transparan

> Setiap token punya: idle animation, walk animation, celebrate animation
PROMPT token_kuning (Karakter Saudagar):
Cute cartoon game token character, small adorable Indonesian merchant 
(saudagar) wearing yellow traditional songkok hat, batik outfit, 
holding small money bag, businesslike but friendly pose, big 
expressive eyes, chubby cartoon style, game character sprite,
transparent background, yellow-gold color theme
```

---

### 🎲 3. DICE (Dadu 3D)

**Ukuran:** 256×256 px per face
**Format:** PNG transparan

```
PROMPT dice_3d_face_1.png through dice_3d_face_6.png:
3D cartoon game dice face showing [NUMBER] dots, white dice with 
red dots, glossy rounded cube face, subtle shadow on left and 
bottom edge, specular highlight on top-right, Indonesian-style 
decorative corner motif (batik pattern), cartoon game art style,
isolated on transparent background, 256x256px, high quality
```

*(Generate 6 kali, ganti [NUMBER] dengan 1-6)*

```
PROMPT dice_complete_3d.png:
3D cartoon game dice complete view showing isometric angle,
white glossy cube with red dots, multiple faces visible (top shows 
5, right shows 3, front shows 2), subtle drop shadow, shiny 
reflective surface, cartoon game art style, transparent background,
dramatic lighting, Indonesian game aesthetic
```

---

### 🏠 4. BANGUNAN (Rumah & Hotel)

**Ukuran:** 128×128 px masing-masing
**Format:** PNG transparan

```
PROMPT house_1.png:
Small cute 3D isometric Indonesian house (rumah), traditional 
Javanese joglo roof style in miniature, green roof, white walls,
small batik window decoration, single house game piece, cartoon 
game art style, vibrant colors, transparent background, 
128x128px, tile game asset
```

```
PROMPT house_4.png:
Small cute 3D isometric cluster of 4 Indonesian traditional houses,
stacked slightly behind each other showing density, green roofs,
white walls, cartoon game art style, vibrant colors, transparent
background, game board piece
```

```
PROMPT hotel.png:
Small cute 3D isometric luxury Indonesian hotel building,
modern architecture with traditional batik-inspired facade,
red roof (distinguishing from houses), "HOTEL" neon sign,
palm trees on sides, cartoon game art style, vibrant colors,
grand and impressive scale, transparent background
```

---

### 🎴 5. KARTU KESEMPATAN & DANA UMUM

**Ukuran:** 512×768 px (portrait card format)
**Format:** PNG

```
PROMPT card_chance_template.png:
Indonesian board game card template for "Kartu Kesempatan" 
(Chance Card), orange gradient background with gold geometric 
border, batik pattern corner decorations, bold "KARTU KESEMPATAN"
header, central area for card text, Indonesian rupiah coin 
decorations, question mark motif, cartoon game art style,
vintage Indonesian game card aesthetic, 512x768px
```

```
PROMPT card_community_template.png:
Indonesian board game card template for "Kartu Dana Umum"
(Community Chest Card), blue gradient background with silver 
geometric border, Indonesian flag motif corner decorations,
bold "KARTU DANA UMUM" header, treasure chest motif,
friendly community gathering illustration, cartoon game art style,
512x768px
```

---

### 💰 6. UI ELEMENTS

**Ukuran:** Bervariasi

```
PROMPT money_stack.png:
Cute cartoon stack of Indonesian Rupiah bills (IDR), 100rb notes
with Soekarno's portrait, held together with gold band, slight 
fan arrangement, green and red colors, cartoon game asset,
transparent background, money reward visual
```

```
PROMPT bankruptcy_banner.png:
Game over banner for bankruptcy in Indonesian board game, 
dramatic "BANGKRUT!" (Bankrupt in Indonesian) text, torn money 
effect, sad cartoon face, cracked texture, bold red and dark colors,
Indonesian game art style, emotional impact
```

```
PROMPT winner_crown.png:
Victory crown for winner in Indonesian board game,
golden royal crown with Indonesian national symbols (garuda motif),
sparkling gems, light rays, epic cartoon style, gold gradient,
"MENANG!" text below, celebration atmosphere, transparent background
```

```
PROMPT ui_money_panel.png:
HUD money display panel for Indonesian mobile game, 
elegant dark glass card with "IDR" currency label, 
gold border, Indonesian batik subtle pattern in background,
space for dynamic number display, premium mobile game UI style
```

---

### 🌅 7. BACKGROUND PARALLAX

**Ukuran:** 2048×1024 px (landscape)

```
PROMPT bg_sky_layer.png:
Wide panoramic Indonesian sky background layer for mobile game,
seamlessly tileable, vibrant blue sky with fluffy tropical clouds,
subtle rays of golden light, peaceful tropical atmosphere,
game background art, no foreground elements, 2048x1024px
```

```
PROMPT bg_mountains_layer.png:
Wide panoramic Indonesian mountain silhouette for game background,
seamlessly tileable, silhouette of volcanic mountains (like Merapi/
Bromo) in misty purple-blue hues, tropical forest at base,
layered depth effect, game background art, transparent top,
2048x512px, parallax layer
```

```
PROMPT bg_sea_layer.png:
Wide panoramic Indonesian ocean background layer, seamlessly 
tileable, crystal turquoise tropical sea with gentle waves,
traditional wooden prahu boats in distance, island silhouettes,
paradise atmosphere, game background art, 2048x512px
```

```
PROMPT bg_islands_layer.png:
Wide panoramic Indonesian island scenery foreground layer,
tropical island with palm trees, white sandy beach, lush jungle
hills, vibrant cartoon style, detailed tropical paradise,
game foreground background art, seamlessly tileable, 2048x512px
```

---

### ✨ 8. PARTICLE EFFECTS

**Ukuran:** 64×64 px masing-masing

```
PROMPT particle_coin.png:
Single Indonesian Rupiah coin particle effect, shiny gold coin 
with garuda emblem, cartoon style, glowing edge, transparent 
background, 64x64px, game particle asset
```

```
PROMPT particle_star.png:
Single sparkle star particle for game effects, golden four-point 
star with motion trails, glowing effect, cartoon style, 
transparent background, 64x64px, game VFX asset
```

```
PROMPT particle_money_rain.png:
Single paper money bill particle (IDR Rupiah), cartoon style,
slight motion blur suggesting falling, green-red colors,
transparent background, 64x64px, game particle asset
```

---

### 🃏 9. ONBOARDING ASSETS (Opsional, untuk layar onboarding)

```
PROMPT onboarding_illustration_board.png:
Beautiful hero illustration showing Indonesian Monopoly board game 
in 3D isometric view from above, vibrant colors, Indonesian landmarks
visible on tiles (Monas, Borobudur, Raja Ampat), cute cartoon 
characters playing around the board, festive atmosphere, detailed
game art, warm tropical lighting, 1024x1024px
```

```
PROMPT onboarding_illustration_multiplayer.png:
Cartoon illustration of 4 diverse Indonesian friends playing board 
game together, laughing and competing, diverse characters (various
ethnicities representing Indonesia), cozy living room with tropical
plant, warm lighting, inclusive and fun atmosphere, 1024x1024px
```

---

## 🔧 Panduan Implementasi Flame

### Phase 1: Setup Flame (1 minggu)
- [ ] Tambah dependency `flame`, `flame_tiled`, `flame_audio`
- [ ] Buat `MonopoliGame extends FlameGame`
- [ ] Integrate dengan Flutter via `GameWidget`
- [ ] Setup `FlameMultiBlocProvider` dengan Riverpod
- [ ] Port logic game engine yang ada (tidak perlu diubah)

### Phase 2: Board Isometrik (1 minggu)
- [ ] Buat `IsometricBoardComponent`
- [ ] Load tile assets ke `SpriteComponent`
- [ ] Implement tile tap detection dengan `TapCallbacks`
- [ ] Animate token movement dengan `MoveEffect`

### Phase 3: Character & Dice (1 minggu)
- [ ] Buat `PlayerTokenComponent` dengan `SpriteAnimation`
- [ ] Implement dice rolling physics dengan Flame effects
- [ ] Tambah particle effects (coin, confetti)
- [ ] Background parallax dengan `ParallaxComponent`

### Phase 4: Polish & Audio (3-4 hari)
- [ ] Integrate `FlameAudio` untuk spatial sound effects
- [ ] Tambah screen shake saat landing di tile penting
- [ ] Implement camera zoom/pan ke tile yang aktif
- [ ] Performance optimization dan testing

---

## 📐 Spesifikasi Teknis Asset

| Kategori | Format | DPI | Mode Warna | Ukuran Max |
|----------|--------|-----|-----------|------------|
| Board tiles | PNG | 144 | RGBA | 512×512 |
| Landmark props | PNG | 144 | RGBA | 256×128 |
| Token sprites | PNG | 144 | RGBA | 512×512 |
| Dice | PNG | 144 | RGBA | 256×256 |
| Buildings | PNG | 144 | RGBA | 128×128 |
| UI elements | PNG | 144 | RGBA | Bervariasi |
| Backgrounds | PNG | 72 | RGB | 2048×1024 |
| Particles | PNG | 72 | RGBA | 64×64 |
| Cards | PNG | 144 | RGBA | 512×768 |

**Catatan penting:**
- Semua sprite karakter harus **background transparan**
- Sprite sheet karakter: grid **4 kolom × 4 baris** (16 frame)
- Framerate animasi idle: **8 fps**
- Framerate animasi walk: **12 fps**
- Semua file **compress dengan TinyPNG** sebelum masuk repo

---

## 🎨 Panduan Style Guide

### Palet Warna Utama
```
Merah Indonesia : #C62828
Emas Premium   : #FFD700
Hijau Tropis   : #2E7D32
Biru Laut      : #1565C0
Oranye Batik   : #FF8F00
Putih Bersih   : #FFFDF0
Coklat Kayu    : #5D4037
```

### Typography (tidak berubah)
- Judul: **Baloo 2** (Bold, 800)
- Body: **Nunito** (Regular/SemiBold)
- Angka uang: **Baloo 2** (ExtraBold, kuning emas)

### Gaya Ilustrasi
- **Style:** 2.5D Isometric Cartoon
- **Outline:** Tebal, gelap, konsisten ~3px
- **Shading:** Cel shading (2-3 tone, tidak gradient halus)
- **Highlight:** Specular putih di pojok atas kiri
- **Shadow:** Drop shadow gelap di bawah setiap objek
- **Referensi:** Hay Day, Clash of Clans art style, tapi dengan tema Indonesia

---

## 📅 Timeline Revamp

| Minggu | Fokus | Deliverable |
|--------|-------|-------------|
| 1 | Asset generation + Flame setup | 50% assets siap, Flame terintegrasi |
| 2 | Board isometrik + tile art | Board baru tampil dengan tile baru |
| 3 | Token animasi + dice 3D | Karakter bergerak, dadu bouncing |
| 4 | Particles + background + audio | Full visual experience |
| 5 | Polish, bug fix, performance | Release candidate |

---

## ⚠️ Catatan Penting

1. **Game logic tidak berubah** — `GameEngine`, `GameState`, `Board`, semua model dart tetap dipakai
2. **Firebase/WebSocket tidak berubah** — hanya visual layer yang diganti
3. **Onboarding yang baru dibuat** — bisa pakai ilustrasi onboarding dari asset baru ini
4. **Test di mid-range device** — Flame lebih berat dari Flutter widget biasa, pastikan smooth di HP entry-level
5. **Asset copyright** — semua asset di-generate sendiri dengan AI, aman secara lisensi

---

*Dokumen ini dibuat: 25 Agustus 2026 | Branch: `feature/revamp-ui`*
