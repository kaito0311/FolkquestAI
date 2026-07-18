import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/models/app_view.dart';
import 'package:fqa/models/app_language.dart';
import 'package:fqa/models/auth_user.dart';
import 'package:fqa/models/bird_conversation_message.dart';
import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/models/story_transition_kind.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/services/auth_service.dart';
import 'package:fqa/services/bird_chat_service.dart';
import 'package:fqa/services/text_to_speech_service.dart';
import 'package:fqa/stores/progress_store.dart';

class GameController extends ChangeNotifier {
  static const birdChatReplyTimeout = Duration(seconds: 10);

  GameController(
    this.store, {
    AuthService? authService,
    BirdChatService? birdChatService,
    TextToSpeechService? textToSpeechService,
  }) : authService = authService ?? const NoopAuthService(),
       birdChatService = birdChatService ?? const LocalBirdChatService(),
       textToSpeechService =
           textToSpeechService ?? FlutterTextToSpeechService() {
    currentUser = this.authService.currentUser;
    _authSubscription = this.authService.authStateChanges.listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  final ProgressStore store;
  final AuthService authService;
  final BirdChatService birdChatService;
  final TextToSpeechService textToSpeechService;
  AppView view = AppView.home;
  String currentNodeId = StoryRepository.startNodeId;
  StoryTransitionKind storyTransition = StoryTransitionKind.homeToStory;
  int karma = 0;
  List<String> selectedChoices = [];
  Set<String> unlockedCollectibleIds = StoryRepository.initialUnlockedIds;
  Set<String> runUnlockedCollectibleIds = {};
  String? completedEndingId;
  int playCount = 0;
  bool pauseVisible = false;
  CollectionFilter collectionFilter = CollectionFilter.all;
  AppView? _returnView;
  AppView? _nestedUtilityReturnView;
  List<BirdConversationMessage> birdMessages = [];
  List<String> _pendingUnlockCollectibleIds = [];
  String? _nodeAfterPendingUnlocks;
  AuthUser? currentUser;
  bool authBusy = false;
  String? authError;
  bool birdResponsePending = false;
  DateTime? _streamingBirdMessageCreatedAt;
  String? birdChatError;
  AppTextSize textSize = AppTextSize.medium;
  double screenBrightness = 100;
  bool musicEnabled = true;
  double musicVolume = 20;
  AppLanguage language = AppLanguage.vietnamese;
  String? vietnameseVoiceName;
  String? englishVoiceName;
  List<TtsVoice> availableVoices = const [];
  double speechRate = 0.46;
  StreamSubscription<AuthUser?>? _authSubscription;

  bool get isSignedIn => currentUser != null;
  String get playerName {
    final displayName = currentUser?.displayName?.trim();
    return displayName == null || displayName.isEmpty
        ? 'Người chơi FolkQuest'
        : displayName;
  }

  double get textScaleFactor => textSize.scale;
  double get brightnessOverlayOpacity =>
      ((100 - screenBrightness) / 100 * 0.68).clamp(0.0, 0.68).toDouble();

  String get birdQuestion {
    for (final message in birdMessages.reversed) {
      if (message.isUser) return message.text;
    }
    return '';
  }

  StoryNode get currentNode =>
      StoryRepository.node(currentNodeId, language: language);

  Ending get currentEnding => StoryRepository.ending(
    completedEndingId ?? currentNode.endingId ?? '',
    language: language,
  );

  Future<void> load() async {
    final snapshot = await store.load();
    if (snapshot == null) return;
    _applySnapshot(snapshot);
  }

  String? get selectedVoiceName =>
      language == AppLanguage.english ? englishVoiceName : vietnameseVoiceName;

  Future<void> speakCurrentStoryText() => textToSpeechService.speak(
    currentNode.text,
    language: language,
    voiceName: selectedVoiceName,
    rate: speechRate,
  );

  Future<void> loadTtsVoices() async {
    availableVoices = await textToSpeechService.voicesFor(language);
    notifyListeners();
  }

  void setVoiceName(String? value) {
    if (language == AppLanguage.english) {
      englishVoiceName = value;
    } else {
      vietnameseVoiceName = value;
    }
    _persist();
    notifyListeners();
  }

  void resetVoiceNames() {
    vietnameseVoiceName = null;
    englishVoiceName = null;
    _persist();
    notifyListeners();
  }

  void setSpeechRate(double value) {
    speechRate = value.clamp(0.0, 2.0).toDouble();
    _persist();
    notifyListeners();
  }

  Future<void> stopSpeaking() => textToSpeechService.stop();

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
    } catch (error, stackTrace) {
      debugPrint('Google sign-in failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      authError = 'Không thể đăng nhập bằng Google. Vui lòng thử lại sau.';
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

  void setMusicEnabled(bool value) {
    musicEnabled = value;
    notifyListeners();
  }

  void setMusicVolume(double value) {
    musicVolume = value.clamp(0, 100).toDouble();
    notifyListeners();
  }

  void setLanguage(AppLanguage value) {
    if (language == value) return;
    language = value;
    _resetCurrentRun();
    unawaited(stopSpeaking());
    unawaited(loadTtsVoices());
    _persist();
    notifyListeners();
  }

  void _resetCurrentRun() {
    currentNodeId = StoryRepository.startNodeId;
    storyTransition = StoryTransitionKind.homeToStory;
    karma = 0;
    selectedChoices = [];
    runUnlockedCollectibleIds = {};
    completedEndingId = null;
    birdMessages = [];
    birdResponsePending = false;
    birdChatError = null;
    _pendingUnlockCollectibleIds = [];
    _nodeAfterPendingUnlocks = null;
    pauseVisible = false;
  }

  void _applySnapshot(GameSnapshot snapshot) {
    currentNodeId = StoryRepository.nodes.containsKey(snapshot.currentNodeId)
        ? snapshot.currentNodeId
        : StoryRepository.startNodeId;
    karma = snapshot.karma;
    language = snapshot.language;
    vietnameseVoiceName = snapshot.vietnameseVoiceName;
    englishVoiceName = snapshot.englishVoiceName;
    speechRate = snapshot.speechRate;
    selectedChoices = snapshot.selectedChoices;
    unlockedCollectibleIds = {
      ...StoryRepository.initialUnlockedIds,
      ...snapshot.unlockedCollectibles,
    };
    runUnlockedCollectibleIds = snapshot.runUnlockedCollectibles;
    completedEndingId = snapshot.completedEndingId;
    playCount = snapshot.playCount;
    if (playCount == 0 && _snapshotHasStartedRun(snapshot)) {
      playCount = 1;
    }
  }

  void startOrResume() {
    if (playCount == 0) {
      playCount = 1;
      _persist();
    }
    storyTransition = StoryTransitionKind.homeToStory;
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

  void openProfile() {
    _openUtility(AppView.profile);
  }

  void openTutorial() {
    _openUtility(AppView.tutorial);
  }

  void openInformation() {
    _nestedUtilityReturnView = view;
    view = AppView.information;
    pauseVisible = false;
    notifyListeners();
  }

  void closeUtility() {
    if (_nestedUtilityReturnView != null) {
      view = _nestedUtilityReturnView!;
      _nestedUtilityReturnView = null;
      pauseVisible = false;
      notifyListeners();
      return;
    }
    view = _returnView ?? AppView.home;
    _returnView = null;
    pauseVisible = false;
    notifyListeners();
  }

  void exitToHome() {
    view = AppView.home;
    _returnView = null;
    _nestedUtilityReturnView = null;
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
    birdResponsePending = false;
    birdChatError = null;
    view = AppView.birdChat;
    pauseVisible = false;
    notifyListeners();
  }

  Future<bool> submitBirdQuestion(String question) async {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) return false;
    if (birdResponsePending) return false;
    final replyTimer = Stopwatch()..start();
    debugPrint(
      'Bird chat submit: story="$currentNodeId", '
      'karma=$karma, question="$normalizedQuestion"',
    );
    birdChatError = null;
    birdMessages = [
      if (birdMessages.isEmpty)
        BirdConversationMessage(
          text: language == AppLanguage.english
              ? 'Ask anything that is still on your mind. We can look back at the story together.'
              : 'Con cứ hỏi điều còn băn khoăn. Ta sẽ cùng con nhìn lại câu chuyện.',
          isUser: false,
        ),
      ...birdMessages,
      BirdConversationMessage(text: normalizedQuestion, isUser: true),
    ];
    final streamingMessage = BirdConversationMessage(text: '', isUser: false);
    _streamingBirdMessageCreatedAt = streamingMessage.createdAt;
    birdMessages = [...birdMessages, streamingMessage];
    view = AppView.birdConversation;
    pauseVisible = false;
    notifyListeners();
    birdResponsePending = true;
    notifyListeners();

    try {
      final request = BirdChatRequest(
        question: normalizedQuestion,
        messages: birdMessages
            .where((message) => message.text.isNotEmpty)
            .toList(),
        karma: karma,
        storyTitle: currentNode.title,
        selectedChoices: selectedChoices,
        playerName: playerName,
        language: language,
      );
      await for (final reply
          in birdChatService
              .streamReply(request)
              .timeout(birdChatReplyTimeout)) {
        _replaceStreamingBirdMessage(reply);
      }
      debugPrint(
        'Bird chat reply received in ${replyTimer.elapsedMilliseconds}ms.',
      );
      if (_currentStreamingBirdMessage?.text.trim().isEmpty ?? true) {
        throw const BirdChatRemoteException('Chim Thần chưa kịp trả lời.');
      }
    } on BirdChatAuthRequiredException {
      debugPrint(
        'Bird chat auth required after ${replyTimer.elapsedMilliseconds}ms.',
      );
      _replaceStreamingBirdMessage(
        'Con cần đăng nhập để Chim Thần có thể trả lời.',
      );
      birdChatError = 'Vui lòng đăng nhập để hỏi Chim Thần.';
    } on TimeoutException {
      debugPrint(
        'Bird chat timed out after ${replyTimer.elapsedMilliseconds}ms.',
      );
      _replaceStreamingBirdMessage(
        'Chim Thần trả lời hơi lâu, con hãy thử hỏi lại sau. Hãy kiểm tra lại kết nối mạng của con nhé.',
      );
      birdChatError = 'Chim Thần phản hồi quá 15 giây.';
    } catch (error) {
      debugPrint(
        'Error during bird chat after ${replyTimer.elapsedMilliseconds}ms: '
        '$error',
      );
      _replaceStreamingBirdMessage('Chim Thần đang ở xa, con hãy thử lại sau.');
      birdChatError = 'Không thể kết nối với Chim Thần lúc này.';
    } finally {
      replyTimer.stop();
      _streamingBirdMessageCreatedAt = null;
      birdResponsePending = false;
      notifyListeners();
    }
    return true;
  }

  BirdConversationMessage? get _currentStreamingBirdMessage {
    final createdAt = _streamingBirdMessageCreatedAt;
    if (createdAt == null) return null;
    for (final message in birdMessages.reversed) {
      if (!message.isUser && message.createdAt == createdAt) return message;
    }
    return null;
  }

  void _replaceStreamingBirdMessage(String text) {
    final createdAt = _streamingBirdMessageCreatedAt;
    if (createdAt == null) return;
    birdMessages = birdMessages
        .map(
          (message) => !message.isUser && message.createdAt == createdAt
              ? BirdConversationMessage(
                  text: text,
                  isUser: false,
                  createdAt: createdAt,
                )
              : message,
        )
        .toList();
    notifyListeners();
  }

  void backFromBirdConversation() {
    view = AppView.birdChat;
    pauseVisible = false;
    notifyListeners();
  }

  void closeBirdChat() {
    view = AppView.story;
    birdResponsePending = false;
    birdChatError = null;
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
    final maxResultingKarma = choice.maxResultingKarma;
    if (maxResultingKarma != null && karma > maxResultingKarma) {
      karma = maxResultingKarma;
    }
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
    _resetCurrentRun();
    playCount += 1;
    view = AppView.story;
    _returnView = null;
    _nestedUtilityReturnView = null;
    _persist();
    notifyListeners();
  }

  bool isUnlocked(Collectible collectible) {
    return unlockedCollectibleIds.contains(collectible.id);
  }

  Iterable<Collectible> filteredCollectibles() {
    return StoryRepository.collectiblesFor(language).where((collectible) {
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
    _nestedUtilityReturnView = null;
    _returnView = switch (view) {
      AppView.settings ||
      AppView.information ||
      AppView.tutorial => _returnView ?? AppView.home,
      _ => view,
    };
    view = utilityView;
    pauseVisible = false;
    notifyListeners();
  }

  void _goToNode(String nodeId) {
    final next = StoryRepository.node(_resolveNodeId(nodeId));
    storyTransition = StoryTransitionKind.between(currentNode.type, next.type);
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
          playCount: playCount,
          language: language,
          vietnameseVoiceName: vietnameseVoiceName,
          englishVoiceName: englishVoiceName,
          speechRate: speechRate,
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
    unawaited(textToSpeechService.dispose());
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  bool _snapshotHasStartedRun(GameSnapshot snapshot) {
    return snapshot.currentNodeId != StoryRepository.startNodeId ||
        snapshot.selectedChoices.isNotEmpty ||
        snapshot.completedEndingId != null ||
        snapshot.runUnlockedCollectibles.isNotEmpty;
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
