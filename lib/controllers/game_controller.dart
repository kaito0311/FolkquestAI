import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/models/app_view.dart';
import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/stores/progress_store.dart';

class GameController extends ChangeNotifier {
  GameController(this.store);

  final ProgressStore store;
  AppView view = AppView.home;
  String currentNodeId = StoryRepository.startNodeId;
  int karma = 0;
  List<String> selectedChoices = [];
  Set<String> unlockedCollectibleIds = StoryRepository.initialUnlockedIds;
  String? completedEndingId;
  bool pauseVisible = false;
  CollectionFilter collectionFilter = CollectionFilter.all;
  AppView? _returnView;
  String birdQuestion = '';

  StoryNode get currentNode => StoryRepository.node(currentNodeId);

  Ending get currentEnding =>
      StoryRepository.endings[completedEndingId ?? currentNode.endingId] ??
      StoryRepository.endings.values.first;

  Future<void> load() async {
    final snapshot = await store.load();
    if (snapshot == null) return;
    currentNodeId = StoryRepository.nodes.containsKey(snapshot.currentNodeId)
        ? snapshot.currentNodeId
        : StoryRepository.startNodeId;
    karma = snapshot.karma;
    selectedChoices = snapshot.selectedChoices;
    unlockedCollectibleIds = {
      ...StoryRepository.initialUnlockedIds,
      ...snapshot.unlockedCollectibles,
    };
    completedEndingId = snapshot.completedEndingId;
  }

  void startOrResume() {
    view = AppView.story;
    pauseVisible = false;
    notifyListeners();
  }

  void openCollection([CollectionFilter filter = CollectionFilter.all]) {
    _returnView = view == AppView.collection ? _returnView : view;
    view = AppView.collection;
    collectionFilter = filter;
    pauseVisible = false;
    notifyListeners();
  }

  void closeCollection() {
    view = _returnView ?? AppView.home;
    _returnView = null;
    pauseVisible = false;
    notifyListeners();
  }

  void openSettings() {
    _openUtility(AppView.settings);
  }

  void openTutorial() {
    _openUtility(AppView.tutorial);
  }

  void closeUtility() {
    view = _returnView ?? AppView.home;
    _returnView = null;
    pauseVisible = false;
    notifyListeners();
  }

  void exitToHome() {
    view = AppView.home;
    _returnView = null;
    pauseVisible = false;
    notifyListeners();
  }

  void showPause() {
    pauseVisible = true;
    notifyListeners();
  }

  void hidePause() {
    pauseVisible = false;
    notifyListeners();
  }

  void advance() {
    final nextId = currentNode.nextId;
    if (nextId == null) return;
    _goToNode(nextId);
  }

  void openBirdChat() {
    birdQuestion = '';
    view = AppView.birdChat;
    pauseVisible = false;
    notifyListeners();
  }

  void submitBirdQuestion(String question) {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) return;
    birdQuestion = normalizedQuestion;
    view = AppView.birdConversation;
    pauseVisible = false;
    notifyListeners();
  }

  void backFromBirdConversation() {
    view = AppView.birdChat;
    pauseVisible = false;
    notifyListeners();
  }

  void closeBirdChat() {
    view = AppView.story;
    pauseVisible = false;
    notifyListeners();
  }

  void choose(StoryChoice choice) {
    karma += choice.karmaDelta;
    selectedChoices = [...selectedChoices, choice.label];
    unlockedCollectibleIds = {
      ...unlockedCollectibleIds,
      ...choice.unlockCollectibleIds,
    };
    _goToNode(choice.nextId);
  }

  void continueFromUnlock({bool openCollectionFirst = false}) {
    final collectibleId = currentNode.unlockCollectibleId;
    if (collectibleId != null) {
      unlockedCollectibleIds = {...unlockedCollectibleIds, collectibleId};
    }
    if (openCollectionFirst) {
      openCollection(CollectionFilter.opened);
    } else {
      advance();
    }
    _persist();
  }

  void restartRun() {
    currentNodeId = StoryRepository.startNodeId;
    karma = 0;
    selectedChoices = [];
    completedEndingId = null;
    view = AppView.story;
    _returnView = null;
    birdQuestion = '';
    pauseVisible = false;
    _persist();
    notifyListeners();
  }

  bool isUnlocked(Collectible collectible) {
    return unlockedCollectibleIds.contains(collectible.id);
  }

  Iterable<Collectible> filteredCollectibles() {
    return StoryRepository.collectibles.where((collectible) {
      return switch (collectionFilter) {
        CollectionFilter.all => true,
        CollectionFilter.opened => isUnlocked(collectible),
        CollectionFilter.locked => !isUnlocked(collectible),
      };
    });
  }

  void setCollectionFilter(CollectionFilter filter) {
    collectionFilter = filter;
    notifyListeners();
  }

  void _openUtility(AppView utilityView) {
    _returnView = switch (view) {
      AppView.settings || AppView.tutorial => _returnView ?? AppView.home,
      _ => view,
    };
    view = utilityView;
    pauseVisible = false;
    notifyListeners();
  }

  void _goToNode(String nodeId) {
    final next = StoryRepository.node(_resolveNodeId(nodeId));
    currentNodeId = next.id;
    if (next.type == StoryNodeType.karma) {
      karma += next.karmaDelta;
    }
    if (next.type == StoryNodeType.unlock && next.unlockCollectibleId != null) {
      unlockedCollectibleIds = {
        ...unlockedCollectibleIds,
        next.unlockCollectibleId!,
      };
    }
    if (next.type == StoryNodeType.ending) {
      completedEndingId = next.endingId;
    }
    _persist();
    notifyListeners();
  }

  void _persist() {
    unawaited(
      store.save(
        GameSnapshot(
          currentNodeId: currentNodeId,
          karma: karma,
          selectedChoices: selectedChoices,
          unlockedCollectibles: unlockedCollectibleIds,
          completedEndingId: completedEndingId,
        ),
      ),
    );
  }

  String _resolveNodeId(String nodeId) {
    var resolvedId = nodeId;
    final visitedIds = <String>{};
    while (visitedIds.add(resolvedId)) {
      final node = StoryRepository.node(resolvedId);
      final routes = node.karmaRoutes;
      if (routes.isEmpty) return resolvedId;
      final route = routes.firstWhere(
        (candidate) => candidate.matches(karma),
        orElse: () => routes.last,
      );
      resolvedId = route.nextId;
    }
    return StoryRepository.startNodeId;
  }
}
