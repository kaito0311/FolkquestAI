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
    expect(find.text('Chia gia tài'), findsOneWidget);

    controller.exitToHome();
    await tester.pump();
    await tester.tap(find.text('Bộ sưu tập'));
    await tester.pump();
    expect(controller.view, AppView.collection);
    expect(find.text('Bộ sưu tập'), findsOneWidget);
  });

  testWidgets('discussion continue advances to options', (tester) async {
    final controller = await _controller();
    controller.startOrResume();
    await _pumpApp(tester, controller);

    await tester.tap(find.byKey(const ValueKey('icon_Tiếp tục')));
    await tester.pump();

    expect(controller.currentNode.type, StoryNodeType.options);
    expect(find.text('Nhận cây khế'), findsOneWidget);
  });

  testWidgets('option choice changes karma and records selected choice', (
    tester,
  ) async {
    final controller = await _controller();
    controller.startOrResume();
    controller.advance();
    await _pumpApp(tester, controller);

    await tester.tap(find.text('Nhận cây khế'));
    await tester.pump();

    expect(controller.karma, 1);
    expect(controller.selectedChoices, contains('Nhận cây khế'));
    expect(controller.unlockedCollectibleIds, contains('starfruit'));
    expect(controller.currentNode.id, 'bag_choice');
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

      controller.currentNodeId = 'feather_unlock';
      await tester.pump();
      _expectNoOverflow(tester);

      controller.openCollection();
      await tester.pump();
      _expectNoOverflow(tester);
    });
  }
}
