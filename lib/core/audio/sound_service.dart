import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Next-Gen Masterpiece Original Audio & SFX Engine for LUDO1
/// Compliant with Section 4 of Master Specification:
/// - App Opening / Start: Warm acoustic chime arpeggio
/// - Dice Roll: Realistic wooden/resin tumbling rattle + haptic
/// - Token Hop & Step: Soft tactile click
/// - Safe Cell Entry: Gilded celestial bell chime
/// - Token Capture: Celebratory pop with cheer + heavy impact
/// - Victory / Match End: Grand fanfare
/// - Notification / Message: Soft pleasant ping
/// - Coin Rewards: Crisp metal clink
class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  AudioPlayer? _player;
  bool soundEnabled = true;
  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool hapticEnabled = true;
  double volume = 0.8;

  AudioPlayer? _getPlayer() {
    try {
      return _player ??= AudioPlayer();
    } catch (_) {
      return null;
    }
  }

  void toggleMute() {
    soundEnabled = !soundEnabled;
    if (!soundEnabled) {
      try {
        _player?.stop();
      } catch (_) {}
    }
  }

  void playDiceRoll() {
    if (hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    _playSound('dice_roll.wav');
  }

  void playTokenMove() {
    if (hapticEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSound('token_move.wav');
  }

  void playSafeCellEntry() {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _playSound('safe_cell.wav');
  }

  void playTokenCapture() {
    if (hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
    _playSound('capture.wav');
  }

  void playTokenHome() {
    if (hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
    _playSound('token_home.wav');
  }

  void playVictory() {
    if (hapticEnabled) {
      HapticFeedback.vibrate();
    }
    _playSound('victory.wav');
  }

  void playGameStart() {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _playSound('start_chime.wav');
  }

  void playNotification() {
    if (hapticEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSound('ping.wav');
  }

  void playCoinClink() {
    if (hapticEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSound('coin.wav');
  }

  void playReaction() {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _playSound('ping.wav');
  }

  Future<void> _playSound(String fileName) async {
    if (!soundEnabled || !sfxEnabled) return;
    try {
      final p = _getPlayer();
      if (p != null) {
        await p.play(AssetSource('audio/$fileName'), volume: volume);
      }
    } catch (_) {
      // Silently catch in test / headless environments if audio device is unavailable
    }
  }

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
  }
}
