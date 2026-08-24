# Task List: Monopoli Indonesia (MVP)

Berdasarkan PRD `PRD-Monopoli-Indonesia.md` — estimasi 4–6 minggu untuk solo developer.

---

## Week 0 — Project Setup & Architecture

- [x] **W0.1** Scaffold Flutter project (Android + Web target)
- [x] **W0.2** Setup folder structure (`lib/`, `server/`, `assets/`)
- [x] **W0.3** Add dependencies (`socket_io_client`, `firebase_core`, `provider`/`riverpod`, dll)
- [x] **W0.4** Design board data model (24 properties + 2 utilities + special tiles)
- [x] **W0.5** Create board UI prototype (static board dengan landmark Indonesia)
- [x] **W0.6** Decide backend approach (Node.js WebSocket vs Firebase) dan dokumentasikan keputusan
- [x] **W0.7** Setup Git repo + `.gitignore` + README + PRD

---

## Week 1 — Core Board Logic & Single-Player Flow

- [x] **W1.1** Implement Player model (name, money, position, properties, status)
- [x] **W1.2** Implement Property/Tile model (name, type, price, rent, owner, houses)
- [x] **W1.3** Implement Board model (tile list, player positions, start/go logic)
- [x] **W1.4** Implement DiceRoll logic (2 dice, doubles detection)
- [x] **W1.5** Implement TurnManager (current player, actions available, end turn)
- [x] **W1.6** Implement buy property action
- [x] **W1.7** Implement pay rent action
- [x] **W1.8** Implement build house action (when player owns full color set)
- [x] **W1.9** Implement basic auction flow (when player declines to buy)
- [x] **W1.10** Implement bankrupt detection & elimination
- [x] **W1.11** Implement Go salary ($200 on passing/landing)
- [x] **W1.12** Implement special tiles (Chance, Community Chest, Tax, Jail, Free Parking, Go To Jail)

---

## Week 2 — Local UI & Game Screen

- [x] **W2.1** Build GameScreen dengan board widget (scrollable/zoomable)
- [x] **W2.2** Build player token widgets on board
- [x] **W2.3** Build dice roll UI dengan animasi
- [x] **W2.4** Build action panel (Buy, Build, Auction, End Turn buttons)
- [x] **W2.5** Build player info sidebar/cards (name, money, properties owned)
- [x] **W2.6** Build property detail popup (ketika landing di tile)
- [x] **W2.7** Build auction dialog UI
- [x] **W2.8** Wire single-player flow end-to-end (local 2-player hot-seat test)

---

## Week 3 — Networking & Multiplayer Backend (Firebase RTDB)

> **Architecture Change:** Switched from Node.js WebSocket server to Firebase Realtime Database.
> Host player acts as authoritative game engine, state synced via RTDB listeners.
> Free Spark plan supports up to 100 concurrent connections.

- [x] **W3.1** Setup Firebase RTDB (`firebase_database` dep, Firebase init in `main.dart`)
- [x] **W3.2** Implement RoomService (create room, join room, leave room, 6-char room code)
- [x] **W3.3** Implement authoritative GameState sync (host writes state, clients listen via RTDB)
- [x] **W3.4** Implement dice roll & validation (host-side via GameEngine)
- [x] **W3.5** Implement turn management (60s timer via RTDB `turnDeadline`, auto-skip)
- [x] **W3.6** Implement action validation (buy/rent/auction/build via RTDB actions queue)
- [x] **W3.7** Implement rate-limiting & anti-cheat (500ms window, turn validation, RTDB security rules)
- [x] **W3.8** Define RTDB path protocol (`rooms/{code}/gameState`, `rooms/{code}/actions/{id}`)

---

## Week 4 — Multiplayer Client Integration & Lobby

- [x] **W4.1** Implement multiplayer client via `GameSyncService` (Firebase RTDB)
- [x] **W4.2** Build HomeScreen (Play local, Create Room, Join Room + player name input)
- [x] **W4.3** Build LobbyScreen (real-time player list, room code, copy code, start button for host)
- [x] **W4.4** Build JoinRoomScreen (enter room code, Firebase join validation)
- [x] **W4.5** Implement room code generation (6-char, copy-to-clipboard)
- [x] **W4.6** Sync game state from RTDB to all clients (real-time board/player updates)
- [x] **W4.7** Implement reconnection handling (RTDB listeners auto-reconnect, presence tracking)
- [x] **W4.8** GameScreen supports both local and multiplayer modes (via `GameSyncService`)

---

## Week 5 — Monetization, Auth, Analytics & Polish

- [x] **W5.1** Implement Guest login (Firebase Auth anonymous)
- [x] **W5.2** Implement optional Google Sign-In
- [x] **W5.3** Implement user profile persistence (Firestore)
- [x] **W5.4** Integrate AdMob rewarded ads (extra roll, small coin reward)
- [x] **W5.5** Integrate AdMob interstitials (after match, menu transitions — frequency cap)
- [x] **W5.6** Integrate Firebase Analytics (key events: `login`, `match_start`, `match_end`, `ad_watched`)
- [x] **W5.7** Integrate Firebase Crashlytics
- [x] **W5.8** Implement in-room chat (preset messages + emoji)
- [x] **W5.9** Localization — Bahasa Indonesia default + English fallback
- [x] **W5.10** UI polish — ilustrasi landmark Indonesia, aksen batik, warna hangat
- [x] **W5.11** Audio — background music (gamelan fusion), dice/sfx sounds
- [x] **W5.12** Onboarding tutorial (3-step: roll, buy, build)

---

## Week 6 — Testing, Bugfix & Deployment Prep

- [x] **W6.1** End-to-end multiplayer testing (2, 3, 4 player matches)
- [x] **W6.2** Edge case testing (bankrupt, disconnect, timeout, all properties owned)
- [x] **W6.3** Web PWA testing (Chrome, mobile browser, install prompt)
- [x] **W6.4** Android APK/AAB build & test on physical device
- [x] **W6.5** Performance optimization (web asset size, lazy loading)
- [x] **W6.6** Setup Firebase Hosting untuk PWA deployment
- [x] **W6.7** Setup DigitalOcean droplet atau Firebase backend untuk production
- [x] **W6.8** Budget monitoring setup (Firebase budget alerts)
- [x] **W6.9** Write deployment notes + README
- [x] **W6.10** Final staging release (APK + PWA URL)

---

## Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| Week 0 | 7 | Project setup, scaffold, architecture decision |
| Week 1 | 12 | Core game logic (models, actions, special tiles) |
| Week 2 | 8 | Local UI (board, dice, action panel, popups) |
| Week 3 | 8 | WebSocket server (room, game state, anti-cheat) |
| Week 4 | 8 | Multiplayer client (lobby, sync, reconnection) |
| Week 5 | 12 | Auth, ads, analytics, chat, localization, polish |
| Week 6 | 10 | Testing, deployment, staging release |
| **Total** | **65** | |

**Priority:** 41 High · 19 Medium · 5 Low

---

## Phase 2 (Post-MVP Backlog)

Fitur yang ditunda sesuai PRD:

- [ ] Trading antar pemain (terperinci)
- [ ] AI auction bot
- [ ] Leaderboard global
- [ ] Friends system & spectate mode
- [ ] IAP cosmetic (skin dice, board theme)
- [ ] Persistent chat history
- [ ] Multiple board themes

---

_Update checklist ini saat task selesai. Centang `[x]` untuk menandai selesai._
