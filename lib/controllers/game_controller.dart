import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/models/app_view.dart';
import 'package:fqa/models/auth_user.dart';
import 'package:fqa/models/bird_conversation_message.dart';
import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/services/auth_service.dart';
import 'package:fqa/stores/progress_store.dart';

class GameController extends ChangeNotifier {
  GameController(this.store, {AuthService? authService})
    : authService = authService ?? const NoopAuthService() {
    currentUser = this.authService.currentUser;
    _authSubscription = this.authService.authStateChanges.listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  final ProgressStore store;
  final AuthService authService;
  AppView view = AppView.home;
  String currentNodeId = StoryRepository.startNodeId;
  int karma = 0;
  List<String> selectedChoices = [];
  Set<String> unlockedCollectibleIds = StoryRepository.initialUnlockedIds;
  Set<String> runUnlockedCollectibleIds = {};
  String? completedEndingId;
  bool pauseVisible = false;
  CollectionFilter collectionFilter = CollectionFilter.all;
  AppView? _returnView;
  List<BirdConversationMessage> birdMessages = [];
  List<String> _pendingUnlockCollectibleIds = [];
  String? _nodeAfterPendingUnlocks;
  AuthUser? currentUser;
  bool authBusy = false;
  String? authError;
  AppTextSize textSize = AppTextSize.medium;
  double screenBrightness = 100;
  StreamSubscription<AuthUser?>? _authSubscription;

  bool get isSignedIn => currentUser != null;
  double get textScaleFactor => textSize.scale;
  double get brightnessOverlayOpacity =>
      ((100 - screenBrightness) / 100 * 0.68).clamp(0.0, 0.68).toDouble();

  String get birdQuestion {
    for (final message in birdMessages.reversed) {
      if (message.isUser) return message.text;
    }
    return '';
  }

  StoryNode get currentNode => StoryRepository.node(currentNodeId);

  Ending get currentEnding =>
      StoryRepository.endings[completedEndingId ?? currentNode.endingId] ??
      StoryRepository.endings.values.first;

  Future<void> load() async {
    final snapshot = await store.load();
    if (snapshot == null) return;
    _applySnapshot(snapshot);
  }

  Future<void> signInWithGoogle() async {
    if (authBusy) return;
    authBusy = true;
    authError = null;
    notifyListeners();
    try {
      final user = await authService.signInWithGoogle();
      currentUser = user ?? authService.currentUser;
      final snapshot = await store.load();
      if (snapshot != null) {
        _applySnapshot(snapshot);
        _persist();
      }
    } catch (error) {
      authError = 'Không thể đăng nhập bằng Google. Vui lòng thử lại.';
    } finally {
      authBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (authBusy) return;
    authBusy = true;
    authError = null;
    notifyListeners();
    try {
      await authService.signOut();
      currentUser = authService.currentUser;
    } catch (error) {
      authError = 'Không thể đăng xuất. Vui lòng thử lại.';
    } finally {
      authBusy = false;
      notifyListeners();
    }
  }

  void clearAuthError() {
    authError = null;
    notifyListeners();
  }

  void setTextSize(AppTextSize value) {
    textSize = value;
    notifyListeners();
  }

  void setScreenBrightness(double value) {
    screenBrightness = value.clamp(0, 100).toDouble();
    notifyListeners();
  }

  void _applySnapshot(GameSnapshot snapshot) {
    currentNodeId = StoryRepository.nodes.containsKey(snapshot.currentNodeId)
        ? snapshot.currentNodeId
        : StoryRepository.startNodeId;
    karma = snapshot.karma;
    selectedChoices = snapshot.selectedChoices;
    unlockedCollectibleIds = {
      ...StoryRepository.initialUnlockedIds,
      ...snapshot.unlockedCollectibles,
    };
    runUnlockedCollectibleIds = snapshot.runUnlockedCollectibles;
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
    if (currentNode.type == StoryNodeType.karma &&
        _pendingUnlockCollectibleIds.isNotEmpty) {
      _nodeAfterPendingUnlocks = nextId;
      _goToNextPendingUnlock();
      return;
    }
    _goToNode(nextId);
  }

  void openBirdChat() {
    birdMessages = [];
    view = AppView.birdChat;
    pauseVisible = false;
    notifyListeners();
  }

  bool submitBirdQuestion(String question) {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) return false;
    final nextMessages = [
      if (birdMessages.isEmpty)
        BirdConversationMessage(
          text:
              'Con cứ hỏi điều còn băn khoăn. Ta sẽ cùng con nhìn lại câu chuyện.',
          isUser: false,
        ),
      ...birdMessages,
      BirdConversationMessage(text: normalizedQuestion, isUser: true),
      BirdConversationMessage(
        text:
            'Khi lòng tham lớn hơn sự biết đủ, con người dễ đánh mất những gì mình đang có.',
        isUser: false,
      ),
    ];
    birdMessages = nextMessages;
    view = AppView.birdConversation;
    pauseVisible = false;
    notifyListeners();
    return true;
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

  void continueBirdConversationToKarma() {
    view = AppView.story;
    pauseVisible = false;
    notifyListeners();
  }

  void choose(StoryChoice choice) {
    karma += choice.karmaDelta;
    selectedChoices = [...selectedChoices, choice.label];
    _pendingUnlockCollectibleIds = [
      ..._pendingUnlockCollectibleIds,
      ...choice.unlockCollectibleIds,
    ];
    unlockedCollectibleIds = {
      ...unlockedCollectibleIds,
      ...choice.unlockCollectibleIds,
    };
    runUnlockedCollectibleIds = {
      ...runUnlockedCollectibleIds,
      ...choice.unlockCollectibleIds,
    };
    _goToNode(choice.nextId);
  }

  void continueFromUnlock({bool openCollectionFirst = false}) {
    final collectibleId = currentNode.unlockCollectibleId;
    if (collectibleId != null) {
      unlockedCollectibleIds = {...unlockedCollectibleIds, collectibleId};
      runUnlockedCollectibleIds = {...runUnlockedCollectibleIds, collectibleId};
    }
    if (openCollectionFirst) {
      openCollection(CollectionFilter.opened);
    } else if (_nodeAfterPendingUnlocks != null) {
      if (_pendingUnlockCollectibleIds.isNotEmpty) {
        _goToNextPendingUnlock();
      } else {
        final nextId = _nodeAfterPendingUnlocks;
        _nodeAfterPendingUnlocks = null;
        _goToNode(nextId!);
      }
    } else {
      advance();
    }
    _persist();
  }

  void restartRun() {
    currentNodeId = StoryRepository.startNodeId;
    karma = 0;
    selectedChoices = [];
    runUnlockedCollectibleIds = {};
    completedEndingId = null;
    view = AppView.story;
    _returnView = null;
    birdMessages = [];
    _pendingUnlockCollectibleIds = [];
    _nodeAfterPendingUnlocks = null;
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
      runUnlockedCollectibleIds = {
        ...runUnlockedCollectibleIds,
        next.unlockCollectibleId!,
      };
    }
    if (next.type == StoryNodeType.ending) {
      completedEndingId = next.endingId;
    }
    _persist();
    notifyListeners();
  }

  void _goToNextPendingUnlock() {
    final collectibleId = _pendingUnlockCollectibleIds.first;
    _pendingUnlockCollectibleIds = _pendingUnlockCollectibleIds
        .skip(1)
        .toList();
    _goToNode(StoryRepository.unlockNodeIdForCollectible(collectibleId));
  }

  void _persist() {
    unawaited(
      store.save(
        GameSnapshot(
          currentNodeId: currentNodeId,
          karma: karma,
          selectedChoices: selectedChoices,
          unlockedCollectibles: unlockedCollectibleIds,
          runUnlockedCollectibles: runUnlockedCollectibleIds,
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

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}

enum AppTextSize {
  small('Nhỏ', 0.9),
  medium('Trung bình', 1),
  large('Lớn', 1.12);

  const AppTextSize(this.label, this.scale);

  final String label;
  final double scale;
}
