import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fqa/app/main_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/app_view.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/stores/memory_progress_store.dart';
import 'package:fqa/widgets/collection/collectible_card.dart';

Future<GameController> _controller() async {
  final controller = GameController(MemoryProgressStore());
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
  await tester.pumpWidget(MainApp(controller: controller));
  await tester.pump();
}

void _expectNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  expect(exception, isNull);
}

void main() {
  testWidgets('home buttons route to story and collection', (tester) async {
    final controller = await _controller();
    await _pumpApp(tester, controller);

    expect(find.text('FolkQuest'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(controller.view, AppView.story);
    expect(find.text('Mở đầu truyện'), findsOneWidget);

    controller.exitToHome();
    await tester.pump();
    await tester.tap(find.text('Bộ sưu tập'));
    await tester.pump();
    expect(controller.view, AppView.collection);
    expect(find.text('Bộ sưu tập'), findsOneWidget);
  });

  testWidgets('collection back returns to the previous screen', (tester) async {
    final controller = await _controller();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Bộ sưu tập'));
    await tester.pump();
    expect(controller.view, AppView.collection);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
    expect(controller.view, AppView.home);

    controller.currentNodeId = 'feather_unlock';
    controller.startOrResume();
    await tester.pump();

    await tester.tap(find.text('Xem bộ sưu tập'));
    await tester.pump();
    expect(controller.view, AppView.collection);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
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
    await tester.pump();
    expect(controller.currentNode.id, 'father_passes_away');

    await tester.tap(find.byKey(const ValueKey('icon_Tiếp tục')));
    await tester.pump();

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

  testWidgets('choosing three-span bag unlocks bag and feather', (
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
    expect(controller.currentNode.id, 'gold_island');

    controller.currentNodeId = 'enough_reflection';
    controller.advance();
    await tester.pump();

    expect(controller.currentNode.id, 'bag3_unlock');

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
    controller.currentNodeId = 'choose_bag';
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

  testWidgets('brother exchange path reaches brother bad ending', (
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
  });

  testWidgets('keep tree path shows dialogue before karma reflection', (
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

    expect(controller.view, AppView.collection);
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
    await tester.pump();
    expect(controller.view, AppView.tutorial);
    expect(find.text('HƯỚNG DẪN'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
    expect(controller.view, AppView.home);

    await tester.tap(find.byKey(const ValueKey('icon_Cài đặt')));
    await tester.pump();
    expect(controller.view, AppView.settings);
    expect(find.text('Cài đặt'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
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
    expect(
      tester.widget<Semantics>(musicSwitchFinder).properties.toggled,
      isFalse,
    );

    expect(find.byType(Slider), findsNWidgets(2));
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
  });

  testWidgets('pause settings and help open real screens from story', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    await _pumpApp(tester, controller);

    controller.showPause();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('icon_Cài đặt')));
    await tester.pump();
    expect(controller.view, AppView.settings);
    expect(controller.pauseVisible, isFalse);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
    expect(controller.view, AppView.story);

    controller.showPause();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('icon_Trợ giúp')));
    await tester.pump();
    expect(controller.view, AppView.tutorial);
    expect(controller.pauseVisible, isFalse);

    await tester.tap(find.byKey(const ValueKey('icon_Quay lại')));
    await tester.pump();
    expect(controller.view, AppView.story);
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
    expect(store.snapshot?.unlockedCollectibles, contains('feather'));
  });

  testWidgets('final restart clears current run state', (tester) async {
    final controller = await _controller();
    controller
      ..currentNodeId = 'enough_ending'
      ..completedEndingId = 'enough'
      ..karma = 3
      ..selectedChoices = ['Nhận cây khế'];
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Chơi lại'));
    await tester.pump();

    expect(controller.currentNodeId, StoryRepository.startNodeId);
    expect(controller.karma, 0);
    expect(controller.selectedChoices, isEmpty);
    expect(controller.view, AppView.story);
  });

  testWidgets('collection filters show all opened and locked items', (
    tester,
  ) async {
    final controller = await _controller();
    controller.unlockedCollectibleIds = {'bag3', 'starfruit'};
    controller.openCollection();
    await _pumpApp(tester, controller);

    expect(find.byType(CollectibleCard), findsNWidgets(9));

    await tester.tap(find.byKey(const ValueKey('filter_Đã mở')));
    await tester.pump();
    expect(controller.collectionFilter, CollectionFilter.opened);
    expect(find.byType(CollectibleCard), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('filter_Chưa mở')));
    await tester.pump();
    expect(controller.collectionFilter, CollectionFilter.locked);
    expect(find.byType(CollectibleCard), findsNWidgets(7));
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

      controller.closeUtility();
      controller.openTutorial();
      await tester.pump();
      _expectNoOverflow(tester);
    });
  }
}
