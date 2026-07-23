import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fqa/app/main_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/app_view.dart';
import 'package:fqa/models/auth_user.dart';
import 'package:fqa/models/bird_conversation_message.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/services/bird_chat_service.dart';
import 'package:fqa/services/text_to_speech_service.dart';
import 'package:fqa/stores/memory_progress_store.dart';
import 'package:fqa/widgets/collection/collectible_card.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_transitions.dart';

Future<GameController> _controller({BirdChatService? birdChatService}) async {
  final controller = GameController(
    MemoryProgressStore(),
    birdChatService: birdChatService,
    textToSpeechService: const NoopTextToSpeechService(),
  );
  await controller.load();
  return controller;
}

Future<void> _pumpApp(
  WidgetTester tester,
  GameController controller, {
  Size surfaceSize = const Size(426, 899),
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MainApp(controller: controller, enableBackgroundMusic: false),
  );
  await tester.pump();
}

Future<void> _settleTransitions(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 420));
  await tester.pump();
}

void _expectNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  expect(exception, isNull);
}

class _DelayedBirdChatService implements BirdChatService {
  final completer = Completer<String>();

  @override
  Future<String> reply(BirdChatRequest request) => completer.future;

  @override
  Stream<String> streamReply(BirdChatRequest request) async* {
    yield await completer.future;
  }
}

void main() {
  testWidgets('image button keeps callback after press feedback', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FqaImageButton(label: 'Tap me', onPressed: () => taps++),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('transition durations respect reduced motion', (tester) async {
    late Duration duration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            duration = FqaTransitions.durationFor(
              context,
              FqaTransitions.appViewDuration,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(duration, Duration.zero);
  });

  testWidgets('home buttons route to story collection and profile', (
    tester,
  ) async {
    final controller = await _controller();
    await _pumpApp(tester, controller);

    expect(find.text('FolkQuest'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.story);
    expect(find.text('Mở đầu truyện'), findsOneWidget);

    controller.exitToHome();
    await _settleTransitions(tester);
    await tester.tap(find.text('Bộ sưu tập'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.collection);
    expect(find.text('Bộ sưu tập'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    await tester.tap(find.text('Hồ sơ'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.profile);
    expect(find.text('Hồ sơ'), findsOneWidget);
  });

  testWidgets('collection back returns to the previous screen', (tester) async {
    final controller = await _controller();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Bộ sưu tập'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.collection);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.home);

    controller.currentNodeId = 'feather_unlock';
    controller.startOrResume();
    await _settleTransitions(tester);

    await tester.tap(find.text('Xem bộ sưu tập'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.collection);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.story);
    expect(controller.currentNodeId, 'feather_unlock');
  });

  testWidgets('discussion continue advances to inheritance options', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.byKey(const ValueKey('icon_Tiếp tục')));
    await _settleTransitions(tester);
    expect(controller.currentNode.id, 'father_passes_away');

    await tester.tap(find.byKey(const ValueKey('icon_Tiếp tục')));
    await _settleTransitions(tester);

    expect(controller.currentNode.type, StoryNodeType.options);
    expect(find.text('Chấp nhận cây khế'), findsOneWidget);
  });

  testWidgets('option choice changes karma and records selected choice', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    controller.advance();
    controller.advance();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Chấp nhận cây khế'));
    await tester.pump();

    expect(controller.karma, 1);
    expect(controller.selectedChoices, contains('Chấp nhận cây khế'));
    expect(controller.unlockedCollectibleIds, contains('starfruit'));
    expect(controller.currentNode.id, 'accept_starfruit_tree');

    controller.currentNodeId = 'keep_tree_reflection';
    controller.advance();
    await tester.pump();

    expect(controller.currentNode.type, StoryNodeType.unlock);
    expect(controller.currentNode.id, 'starfruit_unlock');

    controller.continueFromUnlock();
    await tester.pump();

    expect(controller.currentNode.id, 'keep_tree_summary');
  });

  testWidgets('fair share choice unlocks the scale collectible', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    controller.advance();
    controller.advance();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Yêu cầu chia công bằng'));
    await tester.pump();

    final collectible = StoryRepository.collectibles.firstWhere(
      (collectible) => collectible.id == 'half',
    );
    expect(controller.unlockedCollectibleIds, contains('half'));
    expect(controller.currentNode.id, 'inheritance_argument');
    expect(collectible.name, 'Cán cân công bằng');
    expect(collectible.assetName, 'collectibles/item_fair_share_scale.png');
  });

  test('karma check routes to no promise when karma is low', () async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'gentle_complaint'
      ..karma = -2;

    controller.advance();

    expect(controller.currentNode.id, 'no_promise_ending');
    expect(controller.currentNode.type, StoryNodeType.firstEnding);
  });

  test(
    'karma check routes to bird promise when karma is above threshold',
    () async {
      final controller = await _controller();
      controller
        ..currentNodeId = 'chase_bird'
        ..karma = -1;

      controller.advance();

      expect(controller.currentNode.id, 'bird_promise');
      expect(controller.currentNode.type, StoryNodeType.dialogue);
    },
  );

  testWidgets('choosing three-span bag unlocks bag, gold, and feather', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'choose_bag'
      ..karma = 2;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('May túi 3 gang'));
    await tester.pump();

    expect(controller.karma, 3);
    expect(controller.unlockedCollectibleIds, contains('bag3'));
    expect(controller.unlockedCollectibleIds, contains('gold'));
    expect(controller.currentNode.id, 'gold_island');

    controller.currentNodeId = 'enough_reflection';
    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'bag3_unlock');

    controller.continueFromUnlock();
    await tester.pump();

    expect(controller.currentNode.id, 'gold_unlock');

    controller.continueFromUnlock();
    await tester.pump();

    expect(controller.currentNode.id, 'feather_unlock');
    expect(controller.unlockedCollectibleIds, contains('feather'));

    controller.continueFromUnlock();
    await tester.pump();

    expect(controller.currentNode.id, 'enough_ending');
  });

  testWidgets('choosing twelve-span bag reaches player bad ending', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'choose_bag'
      ..karma = 2;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('May túi 12 gang'));
    await tester.pump();

    expect(controller.karma, -1);
    expect(controller.unlockedCollectibleIds, contains('bag12'));
    expect(controller.currentNode.id, 'gold_island_large');

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'player_bad_ending');
    expect(controller.currentNode.type, StoryNodeType.firstEnding);

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'player_bad_reflection');

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'bag12_unlock');

    controller.continueFromUnlock();
    await tester.pump();

    expect(controller.currentNode.id, 'player_bad_summary');
  });

  test('twelve-span bag preserves karma below its result ceiling', () async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'choose_bag'
      ..karma = -2;

    final choice = controller.currentNode.choices.firstWhere(
      (choice) => choice.unlockCollectibleIds.contains('bag12'),
    );
    controller.choose(choice);

    expect(controller.karma, -3);
  });

  test(
    'previously unlocked collectible still shows unlock screen in run',
    () async {
      final controller = await _controller();
      controller
        ..currentNodeId = 'choose_bag'
        ..unlockedCollectibleIds = {'bag12'};

      final choice = controller.currentNode.choices.firstWhere(
        (choice) => choice.unlockCollectibleIds.contains('bag12'),
      );
      controller.choose(choice);

      expect(controller.unlockedCollectibleIds, contains('bag12'));
      expect(controller.currentNode.id, 'gold_island_large');

      controller.currentNodeId = 'player_bad_reflection';
      controller.advance();

      expect(controller.currentNode.id, 'bag12_unlock');
      expect(controller.currentNode.type, StoryNodeType.unlock);
    },
  );

  testWidgets('brother exchange path reaches first ending before karma', (
    tester,
  ) async {
    final controller = await _controller();
    controller.currentNodeId = 'player_decides_exchange';
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Đồng ý đổi cây khế'));
    await tester.pump();

    expect(controller.currentNode.id, 'brother_greed_cutscene');

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'brother_bad_ending');
    expect(controller.currentNode.type, StoryNodeType.dialogue);

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'brother_bad_first_ending');
    expect(controller.currentNode.type, StoryNodeType.firstEnding);
    expect(controller.currentNode.background, 'backgrounds/ending_bg.png');

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'brother_bad_reflection');
    expect(controller.currentNode.type, StoryNodeType.karma);

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'brother_bad_summary');
    expect(controller.currentNode.endingId, 'brother_bad');
  });

  testWidgets('keep tree path reaches first ending before karma reflection', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'player_decides_exchange'
      ..karma = 2;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Không đồng ý đổi cây khế'));
    await tester.pump();

    expect(controller.currentNode.type, StoryNodeType.dialogue);
    expect(controller.currentNode.id, 'keep_tree_ending');
    expect(find.text('Giữ lấy cây khế'), findsOneWidget);

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'keep_tree_first_ending');
    expect(controller.currentNode.type, StoryNodeType.firstEnding);
    expect(
      controller.currentNode.background,
      'backgrounds/first_positive_ending_bg.png',
    );

    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'keep_tree_reflection');
    expect(controller.currentNode.type, StoryNodeType.karma);
    expect(find.text('Hỏi Chim Thần'), findsOneWidget);
  });

  testWidgets('karma screen opens bird chat and submits typed question', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = 3;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Hỏi Chim Thần'));
    await tester.pump();

    expect(controller.view, AppView.birdChat);
    expect(find.text('Chim Thần'), findsOneWidget);

    const question = 'Vì sao phải là túi ba gang?';
    await tester.enterText(
      find.byKey(const ValueKey('bird_message_input')),
      question,
    );
    await tester.tap(find.byKey(const ValueKey('bird_send')));
    await tester.pump();

    expect(controller.view, AppView.birdConversation);
    expect(controller.birdQuestion, question);
    expect(find.text(question), findsOneWidget);

    const followUp = 'Con muốn hỏi thêm.';
    await tester.enterText(
      find.byKey(const ValueKey('bird_followup_input')),
      followUp,
    );
    await tester.tap(find.byKey(const ValueKey('bird_followup_send')));
    await tester.pumpAndSettle();

    expect(controller.birdMessages.length, 5);
    expect(controller.birdQuestion, followUp);
    expect(find.text(question), findsOneWidget);
    expect(find.text(followUp), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('button_Tiếp tục câu chuyện')));
    await tester.pump();

    expect(controller.view, AppView.story);
    expect(controller.currentNodeId, 'enough_reflection');
    expect(find.text('Hỏi Chim Thần'), findsOneWidget);
  });

  testWidgets('bird follow-up input clears while response is pending', (
    tester,
  ) async {
    final birdChatService = _DelayedBirdChatService();
    final controller = await _controller(birdChatService: birdChatService);
    controller
      ..currentNodeId = 'enough_reflection'
      ..view = AppView.birdConversation
      ..birdMessages = [
        BirdConversationMessage(text: 'Opening answer', isUser: false),
      ];
    await _pumpApp(tester, controller);

    const followUp = 'What do you know?';
    await tester.enterText(
      find.byKey(const ValueKey('bird_followup_input')),
      followUp,
    );
    await tester.tap(find.byKey(const ValueKey('bird_followup_send')));
    await tester.pump();

    final input = tester.widget<TextField>(
      find.byKey(const ValueKey('bird_followup_input')),
    );
    expect(input.controller?.text, isEmpty);
    expect(controller.birdResponsePending, isTrue);
    expect(find.text(followUp), findsOneWidget);

    birdChatService.completer.complete('A **patient** answer.');
    await tester.pumpAndSettle();

    expect(controller.birdResponsePending, isFalse);
    expect(find.text('A patient answer.', findRichText: true), findsOneWidget);
    expect(
      find.text('A **patient** answer.', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('bird initial input does not clear after disposal', (
    tester,
  ) async {
    final birdChatService = _DelayedBirdChatService();
    final controller = await _controller(birdChatService: birdChatService);
    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = 3;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Hỏi Chim Thần'));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('bird_message_input')),
      'Hello bird',
    );
    await tester.tap(find.byKey(const ValueKey('bird_send')));
    await tester.pump();

    expect(controller.view, AppView.birdConversation);
    expect(find.byKey(const ValueKey('bird_message_input')), findsNothing);

    birdChatService.completer.complete('Hello child.');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hello child.', findRichText: true), findsOneWidget);
  });

  testWidgets('bird reply times out after five seconds', (tester) async {
    final birdChatService = _DelayedBirdChatService();
    final controller = await _controller(birdChatService: birdChatService);
    controller
      ..currentNodeId = 'enough_reflection'
      ..view = AppView.birdConversation
      ..birdMessages = [
        BirdConversationMessage(text: 'Opening answer', isUser: false),
      ];
    await _pumpApp(tester, controller);

    await tester.enterText(
      find.byKey(const ValueKey('bird_followup_input')),
      'Are you there?',
    );
    await tester.tap(find.byKey(const ValueKey('bird_followup_send')));
    await tester.pump();

    expect(controller.birdResponsePending, isTrue);

    await tester.pump(GameController.birdChatReplyTimeout);
    await tester.pump();

    expect(controller.birdResponsePending, isFalse);
    expect(controller.birdChatError, 'Chim Thần phản hồi quá 5 giây.');
    expect(
      find.text(
        'Chim Thần trả lời hơi lâu, con hãy thử hỏi lại sau. Hãy kiểm tra lại kết nối mạng của con nhé.',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('karma screen uses score-specific badge variants', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = -3;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    var badge = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('karma_badge_image')),
    );
    var background = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('fqa_scaffold_background_image')),
    );
    var score = tester.widget<Text>(
      find.byKey(const ValueKey('karma_score_text')),
    );
    expect(background.assetName, 'backgrounds/karma_bg_negative.png');
    expect(badge.assetName, 'panels/karma_badge_negative.png');
    expect(score.data, '-3');
    expect(score.style?.color, const Color(0xffe0554c));

    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = 0;
    controller.startOrResume();
    await tester.pump();

    badge = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('karma_badge_image')),
    );
    background = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('fqa_scaffold_background_image')),
    );
    score = tester.widget<Text>(find.byKey(const ValueKey('karma_score_text')));
    expect(background.assetName, 'backgrounds/karma_bg_neutral.png');
    expect(badge.assetName, 'panels/karma_badge_neutral.png');
    expect(score.data, '0');
    expect(score.style?.color, const Color(0xfff5e8c8));
    expect(find.text('Người đã biết dừng lại.'), findsNothing);

    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = 3;
    controller.startOrResume();
    await tester.pump();

    badge = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('karma_badge_image')),
    );
    background = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('fqa_scaffold_background_image')),
    );
    score = tester.widget<Text>(find.byKey(const ValueKey('karma_score_text')));
    expect(background.assetName, 'backgrounds/karma_bg.png');
    expect(badge.assetName, 'panels/karma_badge.png');
    expect(score.data, '+3');
  });

  testWidgets('bird preset question opens conversation', (tester) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_reflection'
      ..karma = 3;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Hỏi Chim Thần'));
    await tester.pump();

    const question = 'Vì sao phải là túi ba gang?';
    await tester.tap(find.byKey(const ValueKey('bird_preset_$question')));
    await tester.pump();

    expect(controller.view, AppView.birdConversation);
    expect(controller.birdQuestion, question);
    expect(find.text(question), findsOneWidget);
  });

  testWidgets('home guide and settings icons open real screens', (
    tester,
  ) async {
    final controller = await _controller();
    await _pumpApp(tester, controller);

    await tester.tap(find.byKey(const ValueKey('icon_Hướng dẫn')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.tutorial);
    expect(find.text('HƯỚNG DẪN'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.home);

    await tester.tap(find.byKey(const ValueKey('icon_Cài đặt')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.settings);
    expect(find.text('Cài đặt'), findsOneWidget);

    await tester.tap(find.text('GIỚI THIỆU ỨNG DỤNG'));
    await _settleTransitions(tester);
    expect(controller.view, AppView.information);
    expect(find.text('THÔNG TIN'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.settings);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.home);
  });

  testWidgets('settings controls are interactive', (tester) async {
    final controller = await _controller();
    controller.openSettings();
    await _pumpApp(tester, controller);

    final musicSwitchFinder = find.byKey(
      const ValueKey('setting_music_switch'),
    );
    expect(musicSwitchFinder, findsOneWidget);
    expect(
      tester.widget<Semantics>(musicSwitchFinder).properties.toggled,
      isTrue,
    );

    await tester.tap(musicSwitchFinder);
    await tester.pump();
    expect(controller.musicEnabled, isFalse);
    expect(
      tester.widget<Semantics>(musicSwitchFinder).properties.toggled,
      isFalse,
    );

    await tester.tap(musicSwitchFinder);
    await tester.pump();
    expect(controller.musicEnabled, isTrue);

    expect(find.byType(Slider), findsNWidgets(3));

    final speechRateSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('setting_slider_Tốc độ đọc')),
    );
    expect(speechRateSlider.value, 0);
    speechRateSlider.onChanged?.call(1);
    await tester.pump();
    expect(controller.speechRateMultiplier, 2);
    expect(controller.speechRate, 1);

    final musicSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('setting_slider_Âm lượng nhạc nền')),
    );
    musicSlider.onChanged?.call(35);
    await tester.pump();
    expect(controller.musicVolume, 35);

    expect(
      find.byKey(const ValueKey('setting_text_size_small')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('setting_text_size_medium')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('setting_text_size_large')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('setting_text_size_large')));
    await tester.pump();
    final largeText = tester.widget<Text>(find.text('Lớn'));
    expect(largeText.style?.fontWeight, FontWeight.w800);
    expect(controller.textSize, AppTextSize.large);

    final brightnessSlider = find
        .byKey(const ValueKey('setting_slider_Độ sáng màn hình'))
        .evaluate()
        .map((element) => element.widget)
        .whereType<Slider>()
        .single;
    brightnessSlider.onChanged?.call(40);
    await tester.pump();
    expect(controller.screenBrightness, 40);
    expect(controller.brightnessOverlayOpacity, greaterThan(0));
  });

  testWidgets('home auth icon becomes logout when signed in', (tester) async {
    final controller = await _controller();
    controller.currentUser = const AuthUser(uid: 'uid', email: 'a@b.com');
    await _pumpApp(tester, controller);

    expect(find.byKey(const ValueKey('icon_Đăng xuất')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Đăng xuất')));
    await tester.pump();

    expect(controller.isSignedIn, isFalse);
    expect(find.byKey(const ValueKey('icon_Đăng nhập')), findsOneWidget);
  });

  testWidgets('pause profile settings and help open real screens from story', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    await _pumpApp(tester, controller);

    controller.showPause();
    await _settleTransitions(tester);
    await tester.tap(find.byKey(const ValueKey('icon_Hồ sơ')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.profile);
    expect(controller.pauseVisible, isFalse);
    expect(find.text('Hồ sơ'), findsOneWidget);
    expect(find.text('Lượt chơi'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.story);

    controller.showPause();
    await _settleTransitions(tester);
    await tester.tap(find.byKey(const ValueKey('icon_Cài đặt')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.settings);
    expect(controller.pauseVisible, isFalse);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.story);

    controller.showPause();
    await _settleTransitions(tester);
    await tester.tap(find.byKey(const ValueKey('icon_Trợ giúp')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.tutorial);
    expect(controller.pauseVisible, isFalse);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.story);
  });

  testWidgets('profile reset clears game data after confirmation', (
    tester,
  ) async {
    final store = MemoryProgressStore();
    final controller =
        GameController(
            store,
            textToSpeechService: const NoopTextToSpeechService(),
          )
          ..currentNodeId = 'enough_reflection'
          ..karma = 4
          ..selectedChoices = ['keep_tree', 'small_bag']
          ..unlockedCollectibleIds = {'bag3', 'gold'}
          ..runUnlockedCollectibleIds = {'bag3'}
          ..completedEndingId = 'enough'
          ..playCount = 3;
    controller.openProfile();
    await _pumpApp(tester, controller);

    final resetButton = find.byKey(const ValueKey('profile_reset_game_data'));
    expect(resetButton, findsOneWidget);

    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    expect(find.text('Đặt lại toàn bộ tiến trình?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile_reset_cancel')));
    await tester.pumpAndSettle();
    expect(controller.playCount, 3);
    expect(controller.unlockedCollectibleIds, {'bag3', 'gold'});

    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile_reset_confirm')));
    await tester.pumpAndSettle();

    expect(controller.view, AppView.profile);
    expect(controller.currentNodeId, StoryRepository.startNodeId);
    expect(controller.karma, 0);
    expect(controller.selectedChoices, isEmpty);
    expect(controller.unlockedCollectibleIds, isEmpty);
    expect(controller.runUnlockedCollectibleIds, isEmpty);
    expect(controller.completedEndingId, isNull);
    expect(controller.playCount, 0);
    expect(store.snapshot?.playCount, 0);
    expect(store.snapshot?.unlockedCollectibles, isEmpty);
    expect(find.text('Đã đặt lại dữ liệu chơi.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await _settleTransitions(tester);
    expect(controller.view, AppView.home);
  });

  testWidgets('unlock collectible adds item to persisted state', (
    tester,
  ) async {
    final store = MemoryProgressStore();
    final controller = GameController(store);
    await controller.load();
    controller.currentNodeId = 'feather_unlock';
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();

    expect(controller.unlockedCollectibleIds, contains('feather'));
    expect(controller.runUnlockedCollectibleIds, contains('feather'));
    expect(store.snapshot?.unlockedCollectibles, contains('feather'));
    expect(store.snapshot?.runUnlockedCollectibles, contains('feather'));
  });

  testWidgets('karma and unlock continuation buttons share bottom position', (
    tester,
  ) async {
    final controller = await _controller();
    controller.currentNodeId = 'enough_reflection';
    controller.startOrResume();
    await _pumpApp(tester, controller);

    final karmaButtonBottom = tester
        .getBottomRight(find.byKey(const ValueKey('button_Tiếp tục')))
        .dy;

    controller.currentNodeId = 'feather_unlock';
    controller.startOrResume();
    await _settleTransitions(tester);

    final unlockButtonBottom = tester
        .getBottomRight(find.byKey(const ValueKey('button_Tiếp tục')))
        .dy;
    expect(unlockButtonBottom, closeTo(karmaButtonBottom, 0.1));
  });

  testWidgets('final ending shows collectibles unlocked in current run only', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'player_bad_summary'
      ..completedEndingId = 'player_bad'
      ..unlockedCollectibleIds = {'bag3', 'starfruit', 'bag12'}
      ..runUnlockedCollectibleIds = {'bag12'};
    controller.startOrResume();
    await _pumpApp(tester, controller);

    expect(find.byKey(const ValueKey('ending_unlocked_bag12')), findsOneWidget);
    expect(find.byKey(const ValueKey('ending_unlocked_bag3')), findsNothing);
    expect(
      find.byKey(const ValueKey('ending_unlocked_starfruit')),
      findsNothing,
    );
  });

  testWidgets('final ending scrolls horizontally through all unlocked items', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_ending'
      ..completedEndingId = 'enough'
      ..runUnlockedCollectibleIds = {
        'bag3',
        'starfruit',
        'gold',
        'feather',
        'bag12',
        'half',
      };
    controller.startOrResume();
    await _pumpApp(tester, controller);

    final scroll = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('ending_unlocked_scroll')),
    );
    expect(scroll.scrollDirection, Axis.horizontal);
    expect(find.byKey(const ValueKey('ending_unlocked_half')), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('ending_unlocked_scroll')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('ending_unlocked_half')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('final ending cover matches first ending background', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'player_bad_summary'
      ..completedEndingId = 'player_bad';
    controller.startOrResume();
    await _pumpApp(tester, controller);

    final cover = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('final_ending_cover_image')),
    );
    expect(cover.assetName, 'backgrounds/011_player_bad_ending.png');
    expect(cover.alignment, const Alignment(0, -0.25));
  });

  testWidgets('final ending uses a red score pill for negative karma', (
    tester,
  ) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_ending'
      ..completedEndingId = 'enough'
      ..karma = 1;
    controller.startOrResume();
    await _pumpApp(tester, controller);

    var scoreImage = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('final_ending_karma_score_image')),
    );
    expect(scoreImage.assetName, 'panels/karma_score_pill.png');

    controller.karma = -1;
    controller.notifyListeners();
    await _settleTransitions(tester);

    scoreImage = tester.widget<FqaAssetImage>(
      find.byKey(const ValueKey('final_ending_karma_score_image')),
    );
    expect(scoreImage.assetName, 'panels/red_score.png');
  });

  testWidgets('final restart clears current run state', (tester) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_ending'
      ..completedEndingId = 'enough'
      ..karma = 3
      ..runUnlockedCollectibleIds = {'bag3'}
      ..selectedChoices = ['Nhận cây khế'];
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Chơi lại'));
    await tester.pump();

    expect(controller.currentNodeId, StoryRepository.startNodeId);
    expect(controller.karma, 0);
    expect(controller.selectedChoices, isEmpty);
    expect(controller.runUnlockedCollectibleIds, isEmpty);
    expect(controller.playCount, 2);
    expect(controller.view, AppView.story);
  });

  testWidgets('collection filters show all opened and locked items', (
    tester,
  ) async {
    final controller = await _controller();
    controller.unlockedCollectibleIds = {'bag3', 'starfruit'};
    controller.openCollection();
    await _pumpApp(tester, controller);

    expect(find.byType(CollectibleCard), findsNWidgets(6));

    await tester.tap(find.byKey(const ValueKey('filter_Đã mở')));
    await tester.pump();
    expect(controller.collectionFilter, CollectionFilter.opened);
    expect(find.byType(CollectibleCard), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('filter_Chưa mở')));
    await tester.pump();
    expect(controller.collectionFilter, CollectionFilter.locked);
    expect(find.byType(CollectibleCard), findsNWidgets(4));
  });

  testWidgets('collection shows a message when a filter has no items', (
    tester,
  ) async {
    final controller = await _controller();
    controller.openCollection();
    await _pumpApp(tester, controller);

    controller.setCollectionFilter(CollectionFilter.opened);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('collection_empty_state')),
      findsOneWidget,
    );
  });

  for (final surfaceSize in [
    const Size(426, 899),
    const Size(430, 932),
    const Size(390, 844),
    const Size(360, 800),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1366, 768),
  ]) {
    testWidgets('key screens fit at $surfaceSize', (tester) async {
      final controller = await _controller();
      await _pumpApp(tester, controller, surfaceSize: surfaceSize);
      _expectNoOverflow(tester);

      controller.startOrResume();
      controller.advance();
      await tester.pump();
      _expectNoOverflow(tester);

      controller
        ..currentNodeId = 'enough_ending'
        ..completedEndingId = null
        ..karma = 3
        ..selectedChoices = [
          'Nhận cây khế',
          'Chọn túi ba gang',
          'Không lấy thêm vàng',
        ];
      await tester.pump();
      _expectNoOverflow(tester);

      controller.completedEndingId = 'enough';
      await tester.pump();
      _expectNoOverflow(tester);

      controller
        ..completedEndingId = null
        ..currentNodeId = 'enough_reflection';
      controller.startOrResume();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.openBirdChat();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.submitBirdQuestion('Vì sao phải là túi ba gang?');
      await tester.pump();
      _expectNoOverflow(tester);

      controller.closeBirdChat();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.currentNodeId = 'feather_unlock';
      await tester.pump();
      _expectNoOverflow(tester);

      controller.openCollection();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.openSettings();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.openInformation();
      await tester.pump();
      _expectNoOverflow(tester);

      controller.closeUtility();
      controller.openTutorial();
      await tester.pump();
      _expectNoOverflow(tester);
    });
  }
}
