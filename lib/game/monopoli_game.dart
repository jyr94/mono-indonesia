import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/game_engine.dart';
import '../models/player.dart';
import 'components/board_component.dart';
import 'components/player_token_component.dart';
import 'components/dice_component.dart';
import 'components/particle_manager.dart';
import 'components/background_component.dart';

/// Root Flame game for Monopoli Indonesia.
/// Handles the visual game world — all game logic stays in [GameEngine].
class MonopoliGame extends FlameGame with ScaleDetector {
  // ── Game state reference (owned by Flutter, shared here) ─────────────────
  GameEngine engine;
  final String localPlayerId;
  final VoidCallback onStateUpdated;

  // ── Core components ───────────────────────────────────────────────────────
  late BoardComponent _board;
  late DiceComponent _dice;
  late ParticleManager _particles;
  late BackgroundComponent _background;

  /// Map playerId → token component
  final Map<String, PlayerTokenComponent> _tokens = {};

  // ── Callbacks to Flutter HUD ───────────────────────────────────────────────
  Function(int tileIndex)? onTileTap;

  // ── Animation state ────────────────────────────────────────────────────────
  bool _isAnimatingMove = false;

  MonopoliGame({
    required this.engine,
    required this.localPlayerId,
    required this.onStateUpdated,
  });

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup camera — centered on world origin
    camera.viewfinder.anchor = Anchor.center;

    // 1. Background parallax (sky, mountains, sea)
    _background = BackgroundComponent();
    world.add(_background);

    // 2. Board
    _board = BoardComponent(
      engine: engine,
      onTileTap: (idx) => onTileTap?.call(idx),
    );
    world.add(_board);

    // 3. Player tokens
    _rebuildTokens();

    // 4. Dice
    _dice = DiceComponent();
    world.add(_dice);

    // 5. Particle manager
    _particles = ParticleManager();
    world.add(_particles);

    // Fit board to screen on first load
    _fitBoard();
  }

  /// Auto-zoom the camera so the board always fills the visible area.
  /// Called on load and whenever the screen is resized.
  void _fitBoard() {
    // Board physical side is 720. We want it to fill the screen with just a tiny margin.
    const boardWorldSize = 720.0;
    final shortest = size.x < size.y ? size.x : size.y;
    
    // Calculate zoom to fit the board with a small 12px margin on each side (24px total)
    // For desktop (landscape), we can give it more breathing room.
    final padding = size.x < size.y ? 24.0 : 64.0;
    
    camera.viewfinder.zoom = (shortest - padding) / boardWorldSize;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Re-fit whenever screen size changes (rotate, resize Chrome window, etc.)
    _fitBoard();
  }

  double _startZoom = 1.0;

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    if (_isAnimatingMove) return;

    // Handle Pan
    final delta = info.delta.global / camera.viewfinder.zoom;
    camera.viewfinder.position -= delta;

    // Handle Zoom
    if (info.scale.global.x != 1.0 || info.scale.global.y != 1.0) {
      final newZoom = _startZoom * info.scale.global.length / 1.414;
      camera.viewfinder.zoom = newZoom.clamp(0.4, 2.5); // Min and Max zoom bounds
    }

    // Constrain camera position to board bounds
    final pos = camera.viewfinder.position;
    final maxPan = 400.0;
    if (pos.x < -maxPan) pos.x = -maxPan;
    if (pos.x > maxPan) pos.x = maxPan;
    if (pos.y < -maxPan) pos.y = -maxPan;
    if (pos.y > maxPan) pos.y = maxPan;
  }

  // ── Public API called from Flutter ────────────────────────────────────────

  /// Call this when [GameEngine] state has changed (from Flutter setState).
  void syncFromEngine(GameEngine newEngine) {
    engine = newEngine;
    _board.refresh(engine);
    _syncTokenPositions();
  }

  /// Trigger a dice roll animation then call [onDone].
  Future<void> animateDiceRoll(int die1, int die2,
      {required VoidCallback onDone}) async {
    await _dice.rollAnimation(die1, die2);
    
    // Screen shake when dice hit
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(10, 10),
        EffectController(
          duration: 0.04,
          reverseDuration: 0.04,
          repeatCount: 3,
          curve: Curves.bounceOut,
        ),
      ),
    );
    
    onDone();
  }

  /// Animate token for [playerId] from [from] to [to] tile.
  Future<void> animatePlayerMove(
      String playerId, int from, int to) async {
    if (_isAnimatingMove) return;
    _isAnimatingMove = true;
    final token = _tokens[playerId];
    if (token != null) {
      final positions = _board.pathPositions(from, to);
      
      // Zoom in smoothly before moving
      final baseZoom = camera.viewfinder.zoom;
      camera.follow(token, maxSpeed: 1000); // follow smoothly
      
      camera.viewfinder.add(
        ScaleEffect.to(
          Vector2.all(baseZoom * 1.5), 
          EffectController(duration: 0.6, curve: Curves.easeInOut),
        ),
      );
      
      // Wait for zoom to settle a bit
      await Future.delayed(const Duration(milliseconds: 400));

      // Walk path slowly
      await token.walkPath(positions);

      // Stop following and move camera back to the center of the board, and restore original zoom.
      camera.stop();
      camera.viewfinder.add(
        ScaleEffect.to(
          Vector2.all(baseZoom),
          EffectController(duration: 0.5, curve: Curves.easeInOut),
        ),
      );
      camera.viewfinder.add(
        MoveEffect.to(
          _board.center,
          EffectController(duration: 0.5, curve: Curves.easeInOut),
        ),
      );
      // Wait for zoom out and pan to finish
      await Future.delayed(const Duration(milliseconds: 600));
    }
    _isAnimatingMove = false;
    onStateUpdated();
  }

  /// Trigger coin rain particles at board center.
  void spawnCoinRain() => _particles.spawnCoinRain(_board.center);

  /// Trigger confetti explosion.
  void spawnConfetti() => _particles.spawnConfetti(_board.center);

  /// Trigger building-place particle at tile position.
  void spawnBuildEffect(int tileIndex) {
    final pos = _board.tileWorldPosition(tileIndex);
    _particles.spawnBuildEffect(pos);
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _rebuildTokens() {
    // Remove old tokens
    for (final t in _tokens.values) {
      t.removeFromParent();
    }
    _tokens.clear();

    // Add token per player
    for (int i = 0; i < engine.gameState.players.length; i++) {
      final player = engine.gameState.players[i];
      if (player.isBankrupt) continue;
      final token = PlayerTokenComponent(
        player: player,
        tilePosition: _board.tileWorldPosition(player.position),
        playerIndex: i,
      );
      _tokens[player.id] = token;
      world.add(token);
    }
  }

  void _syncTokenPositions() {
    for (final player in engine.gameState.players) {
      final token = _tokens[player.id];
      if (token == null) continue;
      if (player.isBankrupt) {
        token.removeFromParent();
        _tokens.remove(player.id);
        continue;
      }
      final targetPos = _board.tileWorldPosition(player.position);
      token.snapToPosition(targetPos);
    }
  }
}
