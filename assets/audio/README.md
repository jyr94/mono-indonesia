# Audio Assets

Efek suara aktif berasal dari paket audio Kenney berlisensi CC0:

- `sfx_dice_roll.ogg` — suara dadu dikocok
- `sfx_dice_land.ogg` — dadu mendarat
- `sfx_step.ogg` — langkah pion
- `sfx_cash.ogg` — transaksi properti
- `sfx_build.ogg` — membangun rumah
- `sfx_jail.ogg` — masuk penjara
- `sfx_card.ogg` — kartu kesempatan/dana umum
- `sfx_turn.ogg` — pergantian giliran
- `sfx_win.ogg` — kemenangan
- `sfx_click.ogg` — tombol UI

Sumber: https://kenney.nl/assets
Lisensi: Creative Commons CC0 (`LICENSE_KENNEY_CC0.txt`)

## Background Music

BGM belum diaktifkan. Gunakan loop musik Indonesia yang lisensinya jelas
sebelum distribusi publik.

---

# Audio Assets Guide

## Required Audio Files

Place these files in `assets/audio/`:

### Background Music
- `bgm_gamelan.mp3` — Gamelan fusion loop (2-3 minutes, seamless loop)
  - Style: Modern gamelan with electronic beats
  - Tempo: 90-110 BPM, relaxed but engaging
  - Sources: royalty-free gamelan samples from freesound.org, Pixabay Music

### Sound Effects
- `sfx_dice_roll.mp3` — Dice shaking and rolling (~1 second)
  - Two dice rattling on a wooden surface
- `sfx_cash.mp3` — Cash register / coin sound (~0.5 seconds)
  - Ka-ching! For buying properties and receiving rent
- `sfx_build.mp3` — Hammer / construction sound (~0.8 seconds)
  - Building houses on properties
- `sfx_jail.mp3` — Metal door slam (~1 second)
  - Going to jail sound effect
- `sfx_win.mp3` — Victory fanfare (~2 seconds)
  - Triumphant ending jingle
- `sfx_card.mp3` — Card flip (~0.3 seconds)
  - Drawing Chance or Community Chest cards

## Free Audio Sources

1. **Freesound.org** — CC0/CC-BY sound effects
2. **Pixabay Music** — Royalty-free music
3. **Mixkit.co** — Free sound effects
4. **Zapsplat.com** — Free with attribution

## Audio Specifications

- Format: MP3 (128-192 kbps) for web, WAV for better quality
- Sample Rate: 44.1 kHz
- Channels: Stereo for BGM, Mono for SFX
- Normalize all audio to -3 dB peak

## Placeholder Approach

Until real audio files are added, the `AudioService` class
uses debug logging as stubs. When files are ready:

1. Add files to `assets/audio/`
2. Uncomment the `audioplayers` dependency in pubspec.yaml
3. Update `AudioService` to use `AudioPlayer().play(AssetSource('audio/file.mp3'))`
