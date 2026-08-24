# Graph Report - monoindo  (2026-08-22)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1171 nodes · 1454 edges · 74 communities (60 shown, 14 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- game_screen.dart
- game_engine.dart
- game_sync_service.dart
- app_localizations.dart
- app_constants.dart
- player_status_card.dart
- home_screen.dart
- auth_service.dart
- onboarding_overlay.dart
- audio_service.dart
- lobby_screen.dart
- bottom_action_bar.dart
- chat_service.dart
- game_engine_test.dart
- dice_result_panel.dart
- splash_screen.dart
- board_widget.dart
- game_state.dart
- animated_dice_widget.dart
- ad_service.dart
- RoomManager
- profile_service.dart
- State
- room_model.dart
- trade_dialog.dart
- join_room_screen.dart
- firebase_service.dart
- board.dart
- room_service.dart
- property.dart
- chat_panel.dart
- auction_dialog.dart
- main.dart
- mortgage_sheet.dart
- manifest.json
- package.json
- property_detail_sheet.dart
- dice.dart
- player_character.dart
- player_info_card.dart
- playstore_screenshot_app.dart
- bool get
- prepare_playstore_assets.py
- StatelessWidget
- avatar_badge.dart
- player_token_widget.dart
- firebase_options.dart
- String?
- SingleTickerProviderStateMixin
- turn_banner.dart
- package:flutter/material.dart
- PRD: Monopoli Indonesia
- AppLocalizations
- index.html
- MainActivity.kt
- CustomPainter
- Desain UI Monopoli Indonesia
- Tile
- UI: Home Menu
- build.sh
- protocol.js
- App Logo SVG
- lib/models/
- lib/screens/
- lib/services/
- lib/widgets/
- UI: Join Room Screen (Phone)
- Key Art: Monopoli Indonesia
- Logo: Icon 512px
- Logo: Maskable Icon 192px
- Logo: Maskable Icon 512px

## God Nodes (most connected - your core abstractions)
1. `RoomManager` - 8 edges
2. `Room` - 8 edges
3. `main()` - 6 edges
4. `GameEngine` - 6 edges
5. `Tile` - 6 edges
6. `Board` - 5 edges
7. `AppLocalizations` - 5 edges
8. `handleConnection()` - 4 edges
9. `cover()` - 4 edges
10. `feature_graphic()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Gameplay Screenshot` --semantically_similar_to--> `Desain UI Monopoli Indonesia`  [EXTRACTED] [semantically similar]
  playstore/assets/phone-01-gameplay-1080x1920.jpg → desain.md
- `Game Modes Screenshot` --semantically_similar_to--> `Desain UI Monopoli Indonesia`  [EXTRACTED] [semantically similar]
  playstore/assets/phone-02-modes-1080x1920.jpg → desain.md
- `PRD: Monopoli Indonesia` --references--> `Node.js WebSocket Server`  [EXTRACTED]
  PRD-Monopoli-Indonesia.md → docs/architecture-decision.md
- `PRD: Monopoli Indonesia` --references--> `Task List: Monopoli Indonesia (MVP)`  [EXTRACTED]
  PRD-Monopoli-Indonesia.md → TASK-Monopoli-Indonesia.md
- `Monopoli Indonesia README` --references--> `PRD: Monopoli Indonesia`  [EXTRACTED]
  README.md → PRD-Monopoli-Indonesia.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Firebase Tech Stack** — firebase_rtdb, lib_services, lib_models, pubspec [EXTRACTED 0.95]
- **Game UI Flow** — playstore_raw_home, playstore_raw_join, playstore_raw_game [INFERRED 0.85]
- **UI/UX Design to Implementation** — desain, lib_screens, lib_widgets, playstore_phone_01_gameplay [INFERRED 0.85]

## Communities (74 total, 14 thin omitted)

### Community 0 - "game_screen.dart"
Cohesion: 0.03
Nodes (70): GameState get, _animatedPosition, _animatePlayerMovement, _audio, _boardFocusForTile, build, _buildHouse, _buyProperty (+62 more)

### Community 1 - "game_engine.dart"
Cohesion: 0.03
Nodes (69): board.dart, game_state.dart, acceptTrade, activeBidders, _applyCard, AuctionState, bids, board (+61 more)

### Community 2 - "game_sync_service.dart"
Cohesion: 0.04
Nodes (53): _actionsSub, _actionTimestamps, auctionBid, auctionPass, _broadcastMessage, buildHouse, buyProperty, _convertMap (+45 more)

### Community 3 - "app_localizations.dart"
Cohesion: 0.04
Nodes (51): appName, auction, backToMenu, backToMenuAction, bgm, buildHouse, buy, chat (+43 more)

### Community 4 - "app_constants.dart"
Cohesion: 0.04
Nodes (46): accent, AppColors, appName, AppStrings, auction, batikBrown, batikGold, boardBackground (+38 more)

### Community 5 - "player_status_card.dart"
Cohesion: 0.05
Nodes (40): Animation, avatar_badge.dart, avatarColor, copyWith, doublesCount, fromJson, id, isBankrupt (+32 more)

### Community 6 - "home_screen.dart"
Cohesion: 0.06
Nodes (36): _animCtrl, build, _buildPlayerSetup, _characters, _colors, _colorVal, _controllers, _createRoom (+28 more)

### Community 7 - "auth_service.dart"
Cohesion: 0.06
Nodes (32): FirebaseAnalytics, FirebaseAnalytics get, FirebaseAuth, _analytics, AnalyticsService, logAdWatched, logLogin, logMatchEnd (+24 more)

### Community 8 - "onboarding_overlay.dart"
Cohesion: 0.06
Nodes (30): constants/app_constants.dart, IconData, getInstance, _instance, playerId, PlayerIdentity, playerName, updateName (+22 more)

### Community 9 - "audio_service.dart"
Cohesion: 0.07
Nodes (29): AudioService, _bgmEnabled, dispose, initialize, _initialized, _instance, _nextPlayer, _play (+21 more)

### Community 10 - "lobby_screen.dart"
Cohesion: 0.08
Nodes (25): _avatarColor, _avatarIcon, build, _codeCtrl, _copyCode, createState, dispose, initState (+17 more)

### Community 11 - "bottom_action_bar.dart"
Cohesion: 0.08
Nodes (25): _anim, build, color, createState, _ctrl, dispose, GameActionButton, _GameActionButtonState (+17 more)

### Community 12 - "chat_service.dart"
Cohesion: 0.08
Nodes (24): ChatMessage, _chatSub, _convertMap, dispose, _fb, fromJson, isPreset, message (+16 more)

### Community 13 - "game_engine_test.dart"
Cohesion: 0.11
Nodes (23): package:flutter_test/flutter_test.dart, package:monopoli_indonesia/models/board.dart, package:monopoli_indonesia/models/dice.dart, package:monopoli_indonesia/models/game_engine.dart, package:monopoli_indonesia/models/game_state.dart, package:monopoli_indonesia/models/player.dart, package:monopoli_indonesia/models/property.dart, package:monopoli_indonesia/models/tile.dart (+15 more)

### Community 14 - "dice_result_panel.dart"
Cohesion: 0.08
Nodes (23): dart:async, _animatedDie, build, _build2DDie, createState, didUpdateWidget, _die1, _die2 (+15 more)

### Community 15 - "splash_screen.dart"
Cohesion: 0.08
Nodes (22): Enhancement: Monopoli Indonesia Production Ready, _bgCtrl, _bgOpacity, build, _buildDiceParticles, _buildGlowCircle, _buildLoader, _buildLogo (+14 more)

### Community 16 - "board_widget.dart"
Cohesion: 0.08
Nodes (23): board, boardSize, build, _buildBoardGrid, _buildCenter, _buildHouseIndicator, _buildTile, _buildTileArtwork (+15 more)

### Community 17 - "game_state.dart"
Cohesion: 0.09
Nodes (22): dice.dart, canStart, chatMessages, copyWith, currentPlayer, currentPlayerIndex, fromJson, GameState (+14 more)

### Community 18 - "animated_dice_widget.dart"
Cohesion: 0.09
Nodes (22): int?, _bounceAnim, _bounceController, build, _buildDieFace, _buildDots, createState, didUpdateWidget (+14 more)

### Community 19 - "ad_service.dart"
Cohesion: 0.09
Nodes (22): InterstitialAd?, adsEnabled, AdService, dispose, initialize, _initialized, _interstitialAd, _interstitialAdUnitId (+14 more)

### Community 20 - "RoomManager"
Cohesion: 0.13
Nodes (7): broadcast(), handleConnection(), handleMessage(), roomManager, wss, RoomManager, Room

### Community 21 - "profile_service.dart"
Cohesion: 0.09
Nodes (21): auth_service.dart, CollectionReference get, DateTime?, FirebaseFirestore, _authService, createOrUpdateProfile, displayName, _firestore (+13 more)

### Community 22 - "State"
Cohesion: 0.16
Nodes (21): GameScreen, _GameScreenState, JoinRoomScreen, _JoinRoomScreenState, LobbyScreen, _LobbyScreenState, SplashScreen, _SplashScreenState (+13 more)

### Community 23 - "room_model.dart"
Cohesion: 0.10
Nodes (19): code, connected, fromJson, getPlayer, hostId, id, isFinished, isFull (+11 more)

### Community 24 - "trade_dialog.dart"
Cohesion: 0.11
Nodes (18): build, _cashCtrl, createState, dispose, engine, initState, _offeredTiles, onTap (+10 more)

### Community 25 - "join_room_screen.dart"
Cohesion: 0.11
Nodes (17): AnimationController, _bgCtrl, build, _codeController, createState, dispose, initState, _joinRoom (+9 more)

### Community 26 - "firebase_service.dart"
Cohesion: 0.11
Nodes (17): DatabaseReference get, FirebaseDatabase, FirebaseDatabase get, actionsRef, _database, FirebaseService, gameStateRef, _instance (+9 more)

### Community 27 - "board.dart"
Cohesion: 0.11
Nodes (17): Board, colorGroupSize, countUtilitiesOwned, createIndonesianBoard, getAllPropertiesOwnedBy, getAllUtilitiesOwnedBy, getPropertiesByColor, getProperty (+9 more)

### Community 28 - "room_service.dart"
Cohesion: 0.12
Nodes (15): firebase_service.dart, _convertMap, createRoom, deleteRoom, _fb, gameStateStream, generateRoomCode, joinRoom (+7 more)

### Community 29 - "property.dart"
Cohesion: 0.12
Nodes (15): baseRent, color, copyWith, houseCost, houses, isMortgaged, isOwned, owner (+7 more)

### Community 30 - "chat_panel.dart"
Cohesion: 0.13
Nodes (15): ChatService, build, ChatPanel, _ChatPanelState, chatService, _controller, createState, currentUserId (+7 more)

### Community 31 - "auction_dialog.dart"
Cohesion: 0.14
Nodes (13): AuctionState? get, GameEngine get, GameEngine, auction, build, _buildBidButton, createState, engine (+5 more)

### Community 32 - "main.dart"
Cohesion: 0.14
Nodes (13): firebase_options.dart, l10n/app_localizations.dart, build, initializeApp, main, models/player.dart, package:firebase_crashlytics/firebase_crashlytics.dart, package:google_fonts/google_fonts.dart (+5 more)

### Community 33 - "mortgage_sheet.dart"
Cohesion: 0.14
Nodes (13): build, _buildRow, canAct, createState, engine, index, isMortgaged, onChanged (+5 more)

### Community 34 - "manifest.json"
Cohesion: 0.14
Nodes (13): entertainment, games, background_color, categories, description, display, icons, name (+5 more)

### Community 35 - "package.json"
Cohesion: 0.14
Nodes (13): dependencies, uuid, ws, description, main, name, scripts, dev (+5 more)

### Community 36 - "property_detail_sheet.dart"
Cohesion: 0.15
Nodes (12): board, build, _buildHeader, _buildInfoRow, _buildPropertyDetails, _buildRentRow, _buildSpecialInfo, _buildTypeBadge (+4 more)

### Community 37 - "dice.dart"
Cohesion: 0.17
Nodes (11): dart:math, int get, DiceRoll, die1, die2, fromJson, isDoubles, roll (+3 more)

### Community 38 - "player_character.dart"
Cohesion: 0.17
Nodes (11): avatarColorValue, build, characterIcon, characterName, characterTypeFromColor, color, highlighted, PlayerCharacterType (+3 more)

### Community 39 - "player_info_card.dart"
Cohesion: 0.18
Nodes (10): board, build, _getPlayerColor, isCurrentPlayer, onTap, _ownedProperties, player, List (+2 more)

### Community 40 - "playstore_screenshot_app.dart"
Cohesion: 0.20
Nodes (9): package:flutter_localizations/flutter_localizations.dart, package:monopoli_indonesia/l10n/app_localizations.dart, package:monopoli_indonesia/screens/game_screen.dart, package:monopoli_indonesia/screens/home_screen.dart, build, fallback, main, screen (+1 more)

### Community 41 - "bool get"
Cohesion: 0.22
Nodes (8): bool get, calculateRent, copyWith, isMortgaged, isOwned, owner, price, tile.dart

### Community 42 - "prepare_playstore_assets.py"
Cohesion: 0.50
Nodes (8): Image, Path, app_icon(), cover(), feature_graphic(), launcher_icons(), main(), screenshot()

### Community 43 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): MonopoliApp, BoardWidget, BottomActionBar, PlayerCharacter, PlayerInfoCard, PropertyDetailSheet, _TileChip, StatelessWidget (+1 more)

### Community 44 - "avatar_badge.dart"
Cohesion: 0.22
Nodes (8): AvatarBadge, avatarColor, build, color, isOnline, name, size, player_character.dart

### Community 45 - "player_token_widget.dart"
Cohesion: 0.22
Nodes (8): avatarColor, build, color, isCurrentPlayer, isMoving, playerName, PlayerTokenWidget, size

### Community 46 - "firebase_options.dart"
Cohesion: 0.29
Nodes (6): android, DefaultFirebaseOptions, web, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart, static const FirebaseOptions

### Community 47 - "String?"
Cohesion: 0.29
Nodes (6): description, index, name, TileType, type, String?

### Community 48 - "SingleTickerProviderStateMixin"
Cohesion: 0.29
Nodes (7): ConfettiOverlay, _ConfettiOverlayState, _GameButton, _GameButtonState, HomeScreen, _HomeScreenState, SingleTickerProviderStateMixin

### Community 49 - "turn_banner.dart"
Cohesion: 0.29
Nodes (6): build, _formatTime, isMyTurn, playerName, timeRemaining, TurnBanner

### Community 50 - "package:flutter/material.dart"
Cohesion: 0.40
Nodes (4): Color, package:flutter/material.dart, package:monopoli_indonesia/constants/app_constants.dart, main

### Community 51 - "PRD: Monopoli Indonesia"
Cohesion: 0.40
Nodes (5): Firebase Realtime Database, Node.js WebSocket Server, PRD: Monopoli Indonesia, Monopoli Indonesia README, Task List: Monopoli Indonesia (MVP)

### Community 52 - "AppLocalizations"
Cohesion: 0.67
Nodes (4): AppLocalizations, AppLocalizationsDelegate, of, LocalizationsDelegate

### Community 55 - "CustomPainter"
Cohesion: 0.67
Nodes (3): CustomPainter, _ConfettiPainter, BatikBackgroundPainter

### Community 56 - "Desain UI Monopoli Indonesia"
Cohesion: 0.67
Nodes (3): Desain UI Monopoli Indonesia, Gameplay Screenshot, Game Modes Screenshot

### Community 57 - "Tile"
Cohesion: 0.67
Nodes (3): Property, Tile, Utility

### Community 58 - "UI: Home Menu"
Cohesion: 0.67
Nodes (3): UI: Game Board, UI: Home Menu, UI: Join Room Dialog

## Knowledge Gaps
- **860 isolated node(s):** `_animatedPosition`, `_animatePlayerMovement`, `_audio`, `_boardFocusForTile`, `build` (+855 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthService` connect `auth_service.dart` to `profile_service.dart`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `GameEngine` connect `auction_dialog.dart` to `game_screen.dart`, `game_engine.dart`, `game_sync_service.dart`, `mortgage_sheet.dart`, `trade_dialog.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `PlayerIdentity` connect `onboarding_overlay.dart` to `home_screen.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `_animatedPosition`, `_animatePlayerMovement`, `_audio` to the rest of the system?**
  _860 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `game_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.028169014084507043 - nodes in this community are weakly interconnected._
- **Should `game_engine.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02857142857142857 - nodes in this community are weakly interconnected._
- **Should `game_sync_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._