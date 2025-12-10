import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A singleton manager for playing sound effects in the app.
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Plays a success sound (e.g., when a transaction is saved).
  Future<void> playSuccess() async {
    try {
      // Using a system sound URL for demo purposes. Replace with asset path if needed.
      // For web, AssetSource may not work directly. Using UrlSource as fallback.
      await _player.play(AssetSource('sounds/success.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('SoundManager: Could not play success sound: $e');
    }
  }

  /// Plays a sound for expense addition.
  Future<void> playExpense() async {
    try {
      await _player.play(AssetSource('sounds/expense.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('SoundManager: Could not play expense sound: $e');
    }
  }

  /// Plays a sound for income addition.
  Future<void> playIncome() async {
    try {
      await _player.play(AssetSource('sounds/income.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('SoundManager: Could not play income sound: $e');
    }
  }

  /// Plays a sound when a goal is saved or completed.
  Future<void> playGoalComplete() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('SoundManager: Could not play goal complete sound: $e');
    }
  }

  /// Plays a sound when an item is deleted.
  Future<void> playDelete() async {
    try {
      await _player.play(AssetSource('sounds/delete.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('SoundManager: Could not play delete sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
