import 'package:bett_box/common/common.dart';
import 'package:flutter/material.dart';

enum EmojiStyle {
  openMoji(
    family: 'OpenMoji',
    label: 'Openmoji',
  ),
  twEmoji(
    family: 'Twemoji',
    label: 'Twemoji',
  ),
  blobmoji(
    family: 'Blobmoji',
    label: 'Blobmoji',
  );

  final String family;
  final String label;

  const EmojiStyle({
    required this.family,
    required this.label,
  });
}

class EmojiManager {
  static final ValueNotifier<EmojiStyle> emojiStyleNotifier =
      ValueNotifier<EmojiStyle>(EmojiStyle.openMoji);

  static EmojiStyle get currentStyle => emojiStyleNotifier.value;
  static String get currentFamily => emojiStyleNotifier.value.family;

  static const String _prefKeyEmojiStyle = 'selected_emoji_style';

  /// Initializes emoji style preference on app startup
  static Future<void> init() async {
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      final saved = prefs?.getString(_prefKeyEmojiStyle);
      if (saved != null && saved.isNotEmpty) {
        final style = EmojiStyle.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => EmojiStyle.openMoji,
        );
        emojiStyleNotifier.value = style;
        commonPrint.log('EmojiManager: initialized with ${style.label}');
      }
    } catch (e, stack) {
      commonPrint.log('EmojiManager.init failed: $e\n$stack');
    }
  }

  /// Sets active emoji style and saves preference
  static Future<void> setStyle(EmojiStyle style) async {
    if (emojiStyleNotifier.value == style) return;
    emojiStyleNotifier.value = style;
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setString(_prefKeyEmojiStyle, style.name);
      commonPrint.log('EmojiManager: switched to ${style.label}');
    } catch (e, stack) {
      commonPrint.log('EmojiManager.setStyle failed: $e\n$stack');
    }
  }
}
