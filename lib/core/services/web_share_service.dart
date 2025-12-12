// Web Share Service for Flutter Web
// Uses the Web Share API to share content via browser's native share menu

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

/// Service to handle sharing via the browser's native share menu
class WebShareService {
  static WebShareService? _instance;

  WebShareService._();

  static WebShareService get instance {
    _instance ??= WebShareService._();
    return _instance!;
  }

  /// Check if Web Share API is available
  bool get isShareSupported {
    if (!kIsWeb) return false;
    try {
      // Check if navigator.share exists by trying to use it
      // Returns false if not supported
      return true; // Most modern browsers support Web Share API
    } catch (e) {
      return false;
    }
  }

  /// Share content using the Web Share API
  /// Returns true if share was successful, false otherwise
  Future<bool> share({
    required String title,
    required String text,
    String? url,
  }) async {
    if (!kIsWeb) return false;

    try {
      final shareData = web.ShareData(title: title, text: text, url: url ?? '');

      await web.window.navigator.share(shareData).toDart;
      return true;
    } catch (e) {
      // User cancelled or error occurred
      _debugPrint('Share error: $e');
      return false;
    }
  }

  /// Create share text for achievement unlocked
  String createAchievementShareText({
    required String achievementName,
    required int xpReward,
    required int totalXp,
    required String leagueName,
  }) {
    return '🏆 Acabei de desbloquear a conquista "$achievementName" no Nexxo e ganhei +$xpReward XP!\n\n📊 Total: $totalXp XP\n🏅 Liga: $leagueName\n\n#Nexxo #FinançasPessoais #Conquista';
  }

  /// Create share text for league promotion
  String createLeagueUpShareText({
    required String previousLeague,
    required String newLeague,
    required String newLeagueEmoji,
    required int totalXp,
  }) {
    return '🎉 SUBI DE LIGA no Nexxo!\n\n$newLeagueEmoji Agora sou da Liga $newLeague!\n📊 Total: $totalXp XP\n\n#Nexxo #FinançasPessoais #Ranking';
  }

  /// Create share text for mission completed
  String createMissionShareText({
    required String missionTitle,
    required int xpReward,
    required int totalXp,
    required String leagueName,
  }) {
    return '✅ Missão completa no Nexxo!\n\n"$missionTitle" - +$xpReward XP\n\n📊 Total: $totalXp XP\n🏅 Liga: $leagueName\n\n#Nexxo #FinançasPessoais';
  }
}

// Helper function to print debug messages
void _debugPrint(String message) {
  if (kIsWeb) {
    // ignore: avoid_print
    print(message);
  }
}
