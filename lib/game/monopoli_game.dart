import 'dart:async';
import 'package:flame/game.dart';
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
class MonopoliGame extends FlameGame {
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

    // Setup camera
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
      await token.walkPath(positions);
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
