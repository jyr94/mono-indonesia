import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final List<AudioPlayer> _sfxPlayers = List.generate(4, (_) => AudioPlayer());
  int _nextPlayer = 0;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  bool _initialized = false;
  double _sfxVolume = 0.8;

  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> initialize() async {
    if (_initialized) return;
    for (final player in _sfxPlayers) {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
    }
    _initialized = true;
  }

  void _play(String asset, {double volume = 1}) {
    if (!_sfxEnabled) return;
    final player = _sfxPlayers[_nextPlayer];
    _nextPlayer = (_nextPlayer + 1) % _sfxPlayers.length;
    unawaited(
      player
          .stop()
          .then(
            (_) => player.play(
              AssetSource('audio/$asset'),
              volume: (_sfxVolume * volume).clamp(0, 1),
            ),
          )
          .catchError((Object error) {
            debugPrint('Audio gagal diputar ($asset): $error');
          }),
    );
  }

  void playBgm() {
    // BGM sengaja belum diaktifkan sampai loop gamelan yang cocok tersedia.
  }

  void stopBgm() {}

  void playDiceRoll() => _play('sfx_dice_roll.ogg');
  void playDiceLand() => _play('sfx_dice_land.ogg', volume: 0.9);
  void playCashRegister() => _play('sfx_cash.ogg');
  void playBuildHouse() => _play('sfx_build.ogg', volume: 0.85);
  void playJail() => _play('sfx_jail.ogg');
  void playWin() => _play('sfx_win.ogg');
  void playCard() => _play('sfx_card.ogg', volume: 0.85);
  void playStep() => _play('sfx_step.ogg', volume: 0.55);
  void playTurn() => _play('sfx_turn.ogg', volume: 0.8);
  void playClick() => _play('sfx_click.ogg', volume: 0.65);

  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    if (_bgmEnabled) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  void toggleSfx() => _sfxEnabled = !_sfxEnabled;

  void setBgmVolume(double volume) {
    // Disimpan untuk API settings; BGM belum diaktifkan.
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0, 1);
  }

  Future<void> dispose() async {
    for (final player in _sfxPlayers) {
      await player.dispose();
    }
  }
}
