import 'package:flutter_test/flutter_test.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/app_language.dart';
import 'package:fqa/services/text_to_speech_service.dart';
import 'package:fqa/stores/memory_progress_store.dart';

void main() {
  test('1x speech speed maps to the plugin normal rate', () async {
    final tts = _RecordingTextToSpeechService();
    final controller = GameController(
      MemoryProgressStore(),
      textToSpeechService: tts,
    );

    controller.setSpeechRateMultiplier(1);
    await controller.speakCurrentStoryText();

    expect(controller.speechRateMultiplier, 1);
    expect(tts.lastRate, GameController.normalSpeechRate);
  });

  test('2x speech speed maps to twice the plugin normal rate', () async {
    final tts = _RecordingTextToSpeechService();
    final controller = GameController(
      MemoryProgressStore(),
      textToSpeechService: tts,
    );

    controller.setSpeechRateMultiplier(2);
    await controller.speakCurrentStoryText();

    expect(controller.speechRateMultiplier, 2);
    expect(tts.lastRate, 1);
  });

  test('web rate uses the Web Speech normal scale', () {
    expect(ttsPlatformSpeechRate(0.5, isWeb: true), 1);
    expect(ttsPlatformSpeechRate(1, isWeb: true), 2);
    expect(ttsPlatformSpeechRate(0.5, isWeb: false), 0.5);
  });

  test('speech slider keeps 1x in the visual center', () {
    final controller = GameController(
      MemoryProgressStore(),
      textToSpeechService: const NoopTextToSpeechService(),
    );

    expect(controller.speechRateSliderPosition, 0);

    controller.setSpeechRateSliderPosition(-1);
    expect(controller.speechRateMultiplier, 0.5);

    controller.setSpeechRateSliderPosition(0);
    expect(controller.speechRateMultiplier, 1);

    controller.setSpeechRateSliderPosition(1);
    expect(controller.speechRateMultiplier, 2);
  });
}

class _RecordingTextToSpeechService implements TextToSpeechService {
  double? lastRate;

  @override
  Future<void> speak(
    String text, {
    required AppLanguage language,
    String? voiceName,
    required double rate,
  }) async {
    lastRate = rate;
  }

  @override
  Future<List<TtsVoice>> voicesFor(AppLanguage language) async => const [];

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
