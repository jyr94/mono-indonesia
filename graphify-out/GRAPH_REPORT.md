# Graph Report - monoindo  (2026-08-22)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1171 nodes · 1454 edges · 74 communities (60 shown, 14 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.84)
- Token cost: 2,763 input · 747 output

## Community Hubs (Navigation)
- Game Screen Animations
- Game Logic Engine
- Game State Synchronization
- Localization and UI Strings
- App Constants and Themes
- Player Model and State
- Home Screen UI
- Firebase Analytics Service
- Player Identity Management
- Audio and Sound Effects
- Lobby and Room Management
- Game Action Buttons
- Chat Messaging Service
- Unit and Engine Tests
- Dice Animation Logic
- Splash Screen and Loading
- Board Grid Rendering
- Game Session State
- Dice Widget UI
- Ad Integration Service
- WebSocket Server Logic
- User Profile Service
- App Screen States
- Room Data Model
- Trade Negotiation Dialog
- Join Room Screen
- Firebase Database Service
- Board and Property Logic
- Room Connection Service
- Property Data Model
- Chat Panel UI
- Auction System Logic
- App Entry Point
- Mortgage Management UI
- Web App Manifest
- Node.js Project Configuration
- Property Details View
- Dice Roll Logic
- Player Character UI
- Player Info Cards
- Localization and Screenshots
- Utility and Tile Logic
- Play Store Asset Scripts
- Stateless UI Components
- Player Avatar Badges
- Player Token Widget
- Firebase Configuration
- Tile Data Model
- Overlay and Button UI
- Turn Notification Banner
- Material Design Constants
- Project Documentation
- Localization Delegates
- Web Entry Assets
- Android Native Activity
- Custom UI Painters
- UI Design Assets
- Game Board Entities
- UI Layout Definitions
- Build Scripts
- Network Protocol Constants
- Vector Logo Assets
- Data Models Directory
- App Screens Directory
- Backend Services Directory
- Reusable Widgets Directory
- Mobile Join UI
- Marketing Key Art
- High Res Icon
- Maskable Web Icon
- Large Maskable Icon

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

### Community 0 - "Game Screen Animations"
Cohesion: 0.03
Nodes (70): GameState get, _animatedPosition, _animatePlayerMovement, _audio, _boardFocusForTile, build, _buildHouse, _buyProperty (+62 more)

### Community 1 - "Game Logic Engine"
Cohesion: 0.03
Nodes (69): board.dart, game_state.dart, acceptTrade, activeBidders, _applyCard, AuctionState, bids, board (+61 more)

### Community 2 - "Game State Synchronization"
Cohesion: 0.04
Nodes (53): _actionsSub, _actionTimestamps, auctionBid, auctionPass, _broadcastMessage, buildHouse, buyProperty, _convertMap (+45 more)

### Community 3 - "Localization and UI Strings"
Cohesion: 0.04
Nodes (51): appName, auction, backToMenu, backToMenuAction, bgm, buildHouse, buy, chat (+43 more)

### Community 4 - "App Constants and Themes"
Cohesion: 0.04
Nodes (46): accent, AppColors, appName, AppStrings, auction, batikBrown, batikGold, boardBackground (+38 more)

### Community 5 - "Player Model and State"
Cohesion: 0.05
Nodes (40): Animation, avatar_badge.dart, avatarColor, copyWith, doublesCount, fromJson, id, isBankrupt (+32 more)

### Community 6 - "Home Screen UI"
Cohesion: 0.06
Nodes (36): _animCtrl, build, _buildPlayerSetup, _characters, _colors, _colorVal, _controllers, _createRoom (+28 more)

### Community 7 - "Firebase Analytics Service"
Cohesion: 0.06
Nodes (32): FirebaseAnalytics, FirebaseAnalytics get, FirebaseAuth, _analytics, AnalyticsService, logAdWatched, logLogin, logMatchEnd (+24 more)

### Community 8 - "Player Identity Management"
Cohesion: 0.06
Nodes (30): constants/app_constants.dart, IconData, getInstance, _instance, playerId, PlayerIdentity, playerName, updateName (+22 more)

### Community 9 - "Audio and Sound Effects"
Cohesion: 0.07
Nodes (29): AudioService, _bgmEnabled, dispose, initialize, _initialized, _instance, _nextPlayer, _play (+21 more)

### Community 10 - "Lobby and Room Management"
Cohesion: 0.08
Nodes (25): _avatarColor, _avatarIcon, build, _codeCtrl, _copyCode, createState, dispose, initState (+17 more)

### Community 11 - "Game Action Buttons"
Cohesion: 0.08
Nodes (25): _anim, build, color, createState, _ctrl, dispose, GameActionButton, _GameActionButtonState (+17 more)

### Community 12 - "Chat Messaging Service"
Cohesion: 0.08
Nodes (24): ChatMessage, _chatSub, _convertMap, dispose, _fb, fromJson, isPreset, message (+16 more)

### Community 13 - "Unit and Engine Tests"
Cohesion: 0.11
Nodes (23): package:flutter_test/flutter_test.dart, package:monopoli_indonesia/models/board.dart, package:monopoli_indonesia/models/dice.dart, package:monopoli_indonesia/models/game_engine.dart, package:monopoli_indonesia/models/game_state.dart, package:monopoli_indonesia/models/player.dart, package:monopoli_indonesia/models/property.dart, package:monopoli_indonesia/models/tile.dart (+15 more)

### Community 14 - "Dice Animation Logic"
Cohesion: 0.08
Nodes (23): dart:async, _animatedDie, build, _build2DDie, createState, didUpdateWidget, _die1, _die2 (+15 more)

### Community 15 - "Splash Screen and Loading"
Cohesion: 0.08
Nodes (22): Enhancement: Monopoli Indonesia Production Ready, _bgCtrl, _bgOpacity, build, _buildDiceParticles, _buildGlowCircle, _buildLoader, _buildLogo (+14 more)

### Community 16 - "Board Grid Rendering"
Cohesion: 0.08
Nodes (23): board, boardSize, build, _buildBoardGrid, _buildCenter, _buildHouseIndicator, _buildTile, _buildTileArtwork (+15 more)

### Community 17 - "Game Session State"
Cohesion: 0.09
Nodes (22): dice.dart, canStart, chatMessages, copyWith, currentPlayer, currentPlayerIndex, fromJson, GameState (+14 more)

### Community 18 - "Dice Widget UI"
Cohesion: 0.09
Nodes (22): int?, _bounceAnim, _bounceController, build, _buildDieFace, _buildDots, createState, didUpdateWidget (+14 more)

### Community 19 - "Ad Integration Service"
Cohesion: 0.09
Nodes (22): InterstitialAd?, adsEnabled, AdService, dispose, initialize, _initialized, _interstitialAd, _interstitialAdUnitId (+14 more)

### Community 20 - "WebSocket Server Logic"
Cohesion: 0.13
Nodes (7): broadcast(), handleConnection(), handleMessage(), roomManager, wss, RoomManager, Room

### Community 21 - "User Profile Service"
Cohesion: 0.09
Nodes (21): auth_service.dart, CollectionReference get, DateTime?, FirebaseFirestore, _authService, createOrUpdateProfile, displayName, _firestore (+13 more)

### Community 22 - "App Screen States"
Cohesion: 0.16
Nodes (21): GameScreen, _GameScreenState, JoinRoomScreen, _JoinRoomScreenState, LobbyScreen, _LobbyScreenState, SplashScreen, _SplashScreenState (+13 more)

### Community 23 - "Room Data Model"
Cohesion: 0.10
Nodes (19): code, connected, fromJson, getPlayer, hostId, id, isFinished, isFull (+11 more)

### Community 24 - "Trade Negotiation Dialog"
Cohesion: 0.11
Nodes (18): build, _cashCtrl, createState, dispose, engine, initState, _offeredTiles, onTap (+10 more)

### Community 25 - "Join Room Screen"
Cohesion: 0.11
Nodes (17): AnimationController, _bgCtrl, build, _codeController, createState, dispose, initState, _joinRoom (+9 more)

### Community 26 - "Firebase Database Service"
Cohesion: 0.11
Nodes (17): DatabaseReference get, FirebaseDatabase, FirebaseDatabase get, actionsRef, _database, FirebaseService, gameStateRef, _instance (+9 more)

### Community 27 - "Board and Property Logic"
Cohesion: 0.11
Nodes (17): Board, colorGroupSize, countUtilitiesOwned, createIndonesianBoard, getAllPropertiesOwnedBy, getAllUtilitiesOwnedBy, getPropertiesByColor, getProperty (+9 more)

### Community 28 - "Room Connection Service"
Cohesion: 0.12
Nodes (15): firebase_service.dart, _convertMap, createRoom, deleteRoom, _fb, gameStateStream, generateRoomCode, joinRoom (+7 more)

### Community 29 - "Property Data Model"
Cohesion: 0.12
Nodes (15): baseRent, color, copyWith, houseCost, houses, isMortgaged, isOwned, owner (+7 more)

### Community 30 - "Chat Panel UI"
Cohesion: 0.13
Nodes (15): ChatService, build, ChatPanel, _ChatPanelState, chatService, _controller, createState, currentUserId (+7 more)

### Community 31 - "Auction System Logic"
Cohesion: 0.14
Nodes (13): AuctionState? get, GameEngine get, GameEngine, auction, build, _buildBidButton, createState, engine (+5 more)

### Community 32 - "App Entry Point"
Cohesion: 0.14
Nodes (13): firebase_options.dart, l10n/app_localizations.dart, build, initializeApp, main, models/player.dart, package:firebase_crashlytics/firebase_crashlytics.dart, package:google_fonts/google_fonts.dart (+5 more)

### Community 33 - "Mortgage Management UI"
Cohesion: 0.14
Nodes (13): build, _buildRow, canAct, createState, engine, index, isMortgaged, onChanged (+5 more)

### Community 34 - "Web App Manifest"
Cohesion: 0.14
Nodes (13): entertainment, games, background_color, categories, description, display, icons, name (+5 more)

### Community 35 - "Node.js Project Configuration"
Cohesion: 0.14
Nodes (13): dependencies, uuid, ws, description, main, name, scripts, dev (+5 more)

### Community 36 - "Property Details View"
Cohesion: 0.15
Nodes (12): board, build, _buildHeader, _buildInfoRow, _buildPropertyDetails, _buildRentRow, _buildSpecialInfo, _buildTypeBadge (+4 more)

### Community 37 - "Dice Roll Logic"
Cohesion: 0.17
Nodes (11): dart:math, int get, DiceRoll, die1, die2, fromJson, isDoubles, roll (+3 more)

### Community 38 - "Player Character UI"
Cohesion: 0.17
Nodes (11): avatarColorValue, build, characterIcon, characterName, characterTypeFromColor, color, highlighted, PlayerCharacterType (+3 more)

### Community 39 - "Player Info Cards"
Cohesion: 0.18
Nodes (10): board, build, _getPlayerColor, isCurrentPlayer, onTap, _ownedProperties, player, List (+2 more)

### Community 40 - "Localization and Screenshots"
Cohesion: 0.20
Nodes (9): package:flutter_localizations/flutter_localizations.dart, package:monopoli_indonesia/l10n/app_localizations.dart, package:monopoli_indonesia/screens/game_screen.dart, package:monopoli_indonesia/screens/home_screen.dart, build, fallback, main, screen (+1 more)

### Community 41 - "Utility and Tile Logic"
Cohesion: 0.22
Nodes (8): bool get, calculateRent, copyWith, isMortgaged, isOwned, owner, price, tile.dart

### Community 42 - "Play Store Asset Scripts"
Cohesion: 0.50
Nodes (8): Image, Path, app_icon(), cover(), feature_graphic(), launcher_icons(), main(), screenshot()

### Community 43 - "Stateless UI Components"
Cohesion: 0.22
Nodes (9): MonopoliApp, BoardWidget, BottomActionBar, PlayerCharacter, PlayerInfoCard, PropertyDetailSheet, _TileChip, StatelessWidget (+1 more)

### Community 44 - "Player Avatar Badges"
Cohesion: 0.22
Nodes (8): AvatarBadge, avatarColor, build, color, isOnline, name, size, player_character.dart

### Community 45 - "Player Token Widget"
Cohesion: 0.22
Nodes (8): avatarColor, build, color, isCurrentPlayer, isMoving, playerName, PlayerTokenWidget, size

### Community 46 - "Firebase Configuration"
Cohesion: 0.29
Nodes (6): android, DefaultFirebaseOptions, web, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart, static const FirebaseOptions

### Community 47 - "Tile Data Model"
Cohesion: 0.29
Nodes (6): description, index, name, TileType, type, String?

### Community 48 - "Overlay and Button UI"
Cohesion: 0.29
Nodes (7): ConfettiOverlay, _ConfettiOverlayState, _GameButton, _GameButtonState, HomeScreen, _HomeScreenState, SingleTickerProviderStateMixin

### Community 49 - "Turn Notification Banner"
Cohesion: 0.29
Nodes (6): build, _formatTime, isMyTurn, playerName, timeRemaining, TurnBanner

### Community 50 - "Material Design Constants"
Cohesion: 0.40
Nodes (4): Color, package:flutter/material.dart, package:monopoli_indonesia/constants/app_constants.dart, main

### Community 51 - "Project Documentation"
Cohesion: 0.40
Nodes (5): Firebase Realtime Database, Node.js WebSocket Server, PRD: Monopoli Indonesia, Monopoli Indonesia README, Task List: Monopoli Indonesia (MVP)

### Community 52 - "Localization Delegates"
Cohesion: 0.67
Nodes (4): AppLocalizations, AppLocalizationsDelegate, of, LocalizationsDelegate

### Community 55 - "Custom UI Painters"
Cohesion: 0.67
Nodes (3): CustomPainter, _ConfettiPainter, BatikBackgroundPainter

### Community 56 - "UI Design Assets"
Cohesion: 0.67
Nodes (3): Desain UI Monopoli Indonesia, Gameplay Screenshot, Game Modes Screenshot

### Community 57 - "Game Board Entities"
Cohesion: 0.67
Nodes (3): Property, Tile, Utility

### Community 58 - "UI Layout Definitions"
Cohesion: 0.67
Nodes (3): UI: Game Board, UI: Home Menu, UI: Join Room Dialog

## Knowledge Gaps
- **860 isolated node(s):** `_animatedPosition`, `_animatePlayerMovement`, `_audio`, `_boardFocusForTile`, `build` (+855 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthService` connect `Firebase Analytics Service` to `User Profile Service`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `GameEngine` connect `Auction System Logic` to `Game Screen Animations`, `Game Logic Engine`, `Game State Synchronization`, `Mortgage Management UI`, `Trade Negotiation Dialog`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `FirebaseService` connect `Firebase Database Service` to `Game State Synchronization`, `Chat Messaging Service`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `_animatedPosition`, `_animatePlayerMovement`, `_audio` to the rest of the system?**
  _860 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Game Screen Animations` be split into smaller, more focused modules?**
  _Cohesion score 0.028169014084507043 - nodes in this community are weakly interconnected._
- **Should `Game Logic Engine` be split into smaller, more focused modules?**
  _Cohesion score 0.02857142857142857 - nodes in this community are weakly interconnected._
- **Should `Game State Synchronization` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._