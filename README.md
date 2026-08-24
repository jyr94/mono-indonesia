# Monopoli Indonesia

Game monopoli digital bertema Indonesia — playable di Android dan Web (PWA) menggunakan Flutter, multiplayer real-time via Firebase Realtime Database.

## Tech Stack

- **Client:** Flutter 3.x (Android + Web PWA)
- **Backend:** Firebase Realtime Database (host-authoritative)
- **Auth:** Firebase Auth (Guest anonymous + Google Sign-In)
- **Database:** Firestore (user profiles) + RTDB (game state, rooms, chat)
- **Analytics:** Firebase Analytics + Crashlytics
- **Ads:** Google AdMob (rewarded + interstitial)
- **Hosting:** Firebase Hosting (PWA)

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.12+
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- A Firebase project (create at https://console.firebase.google.com)

### Firebase Setup

```bash
# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure

# This generates lib/firebase_options.dart
```

### Run Flutter App

```bash
flutter pub get

# Web (development)
flutter run -d chrome

# Android (emulator or device)
flutter run -d android
```

### Build for Production

```bash
# Use the build script
chmod +x scripts/build.sh
./scripts/build.sh

# Or build individually:
flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

## Deployment

### Web PWA (Firebase Hosting)

```bash
# Build web
flutter build web --release --base-href /

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

The PWA will be available at `https://monopoli-indonesia.web.app`

### Android (Google Play)

1. Build AAB: `flutter build appbundle --release`
2. Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console
3. Or build APK for direct distribution: `flutter build apk --release --split-per-abi`

### Firebase Backend

Firebase services are serverless — no separate deployment needed:
- **RTDB**: Game state sync, rooms, chat
- **Firestore**: User profiles
- **Auth**: Anonymous + Google
- **Analytics + Crashlytics**: Automatic

Update `database.rules.json` for production security:
```bash
firebase deploy --only database
```

## Project Structure

```
monoindo/
├── lib/
│   ├── models/          # Player, Board, Property, GameState, GameEngine
│   ├── screens/         # Home, Game, Lobby, JoinRoom
│   ├── widgets/         # BoardWidget, AnimatedDice, PlayerInfoCard, ChatPanel, Onboarding
│   ├── services/        # Firebase, Auth, Profile, AdService, Analytics, Chat, Audio, GameSync
│   ├── l10n/            # Localization (id + en)
│   └── constants/       # AppColors, AppStrings
├── server/              # Legacy Node.js WebSocket server (replaced by Firebase RTDB)
├── test/                # Unit + integration tests (33 tests)
├── web/                 # PWA config (manifest.json, index.html)
├── scripts/             # Build scripts
├── docs/                # Architecture decisions, budget monitoring
├── firebase.json        # Firebase Hosting config
├── database.rules.json  # RTDB security rules
└── PRD-Monopoli-Indonesia.md
```

## Game Features (MVP)

- Board bertema Indonesia (16 properti + 2 utilitas + 6 special tiles)
- Multiplayer 2–4 pemain online (turn-based, host-authoritative)
- Lobby + room code (6 karakter)
- Dice roll, buy, rent, auction, build houses
- Chat preset + emoji (8 pesan preset)
- Guest login + Google Sign-In
- AdMob rewarded + interstitial ads
- Firebase Analytics + Crashlytics
- Onboarding tutorial (3 langkah)
- Localization: Bahasa Indonesia + English

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/game_engine_test.dart
flutter test test/multiplayer_edge_case_test.dart

# Analyze code
flutter analyze
```

## Architecture

Backend menggunakan **Firebase Realtime Database** (host-authoritative):
- Host player menjalankan `GameEngine` secara lokal
- State disinkronisasi ke RTDB → semua client listen via `onValue`
- Non-host players mengirim aksi via RTDB `actions/` queue
- Host memproses aksi dan menulis state baru
- Rate limiting (500ms window, 5 actions max)
- Turn timer 60 detik via `turnDeadline`

Lihat [docs/architecture-decision.md](docs/architecture-decision.md) untuk detail.

## Budget

Lihat [docs/BUDGET-MONITORING.md](docs/BUDGET-MONITORING.md) untuk setup alert Firebase costs.

## License

Private project.
