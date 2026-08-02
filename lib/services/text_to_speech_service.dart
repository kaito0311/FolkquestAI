import 'package:flutter_tts/flutter_tts.dart';

import 'package:fqa/models/app_language.dart';

abstract class TextToSpeechService {
  Future<void> speak(
    String text, {
    required AppLanguage language,
    String? voiceName,
    required double rate,
  });
  Future<List<TtsVoice>> voicesFor(AppLanguage language);
  Future<void> stop();
  Future<void> dispose();
}

class FlutterTextToSpeechService implements TextToSpeechService {
  FlutterTextToSpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(
    String text, {
    required AppLanguage language,
    String? voiceName,
    required double rate,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    await _tts.stop();
    await _tts.setLanguage(language == AppLanguage.english ? 'en-US' : 'vi-VN');
    if (voiceName != null) {
      await _tts.setVoice({
        'name': voiceName,
        'locale': language == AppLanguage.english ? 'en-US' : 'vi-VN',
      });
    }
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.speak(normalized);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> dispose() => _tts.stop();

  @override
  Future<List<TtsVoice>> voicesFor(AppLanguage language) async {
    final localePrefix = language == AppLanguage.english ? 'en' : 'vi';
    final voices = await _tts.getVoices;
    return (voices as List<dynamic>)
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (voice) => TtsVoice(
            voice['name']?.toString() ?? '',
            voice['locale']?.toString() ?? '',
          ),
        )
        .where(
          (voice) =>
              voice.name.isNotEmpty &&
              voice.locale.toLowerCase().startsWith(localePrefix),
        )
        .toList();
  }
}

class NoopTextToSpeechService implements TextToSpeechService {
  const NoopTextToSpeechService();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> speak(
    String text, {
    required AppLanguage language,
    String? voiceName,
    required double rate,
  }) async {}

  @override
  Future<List<TtsVoice>> voicesFor(AppLanguage language) async => const [];

  @override
  Future<void> stop() async {}
}

class TtsVoice {
  const TtsVoice(this.name, this.locale);
  final String name;
  final String locale;
}
