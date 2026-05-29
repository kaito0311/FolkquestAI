import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final controller = GameController(SharedPreferencesProgressStore(prefs));
  await controller.load();
  runApp(MainApp(controller: controller));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FolkQuest',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: FqaColors.gold),
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          home: FqaApp(controller: controller),
        );
      },
    );
  }
}

class FqaApp extends StatelessWidget {
  const FqaApp({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final Widget screen = switch (controller.view) {
      AppView.home => HomeScreen(controller: controller),
      AppView.story => StoryScreen(controller: controller),
      AppView.collection => CollectionScreen(controller: controller),
    };

    return Stack(
      children: [
        screen,
        if (controller.pauseVisible)
          PauseOverlay(
            onContinue: controller.hidePause,
            onRestart: controller.restartRun,
            onExit: controller.exitToHome,
            onUtility: (title) => _showPlaceholder(context, title),
          ),
      ],
    );
  }
}

void _showPlaceholder(BuildContext context, String title) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xff20150c),
      title: Text(title, style: const TextStyle(color: FqaColors.gold)),
      content: const Text(
        'Màn hình này sẽ được bổ sung khi có thiết kế chi tiết.',
        style: TextStyle(color: FqaColors.cream),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}

enum AppView { home, story, collection }

enum StoryNodeType { dialogue, options, karma, unlock, ending }

enum CollectionFilter { all, opened, locked }

class StoryNode {
  const StoryNode({
    required this.id,
    required this.title,
    required this.type,
    required this.text,
    this.speaker,
    this.nextId,
    this.choices = const [],
    this.karmaDelta = 0,
    this.reflectionTitle = '',
    this.unlockCollectibleId,
    this.endingId,
  });

  final String id;
  final String title;
  final StoryNodeType type;
  final String text;
  final String? speaker;
  final String? nextId;
  final List<StoryChoice> choices;
  final int karmaDelta;
  final String reflectionTitle;
  final String? unlockCollectibleId;
  final String? endingId;
}

class StoryChoice {
  const StoryChoice({
    required this.label,
    required this.nextId,
    this.karmaDelta = 0,
    this.unlockCollectibleIds = const [],
  });

  final String label;
  final String nextId;
  final int karmaDelta;
  final List<String> unlockCollectibleIds;
}

class Ending {
  const Ending({
    required this.id,
    required this.title,
    required this.karmaSummary,
  });

  final String id;
  final String title;
  final String karmaSummary;
}

class Collectible {
  const Collectible({
    required this.id,
    required this.name,
    required this.description,
    required this.assetName,
    this.initiallyUnlocked = false,
  });

  final String id;
  final String name;
  final String description;
  final String assetName;
  final bool initiallyUnlocked;
}

class GameSnapshot {
  const GameSnapshot({
    required this.currentNodeId,
    required this.karma,
    required this.selectedChoices,
    required this.unlockedCollectibles,
    this.completedEndingId,
  });

  final String currentNodeId;
  final int karma;
  final List<String> selectedChoices;
  final Set<String> unlockedCollectibles;
  final String? completedEndingId;

  Map<String, Object?> toJson() => {
    'currentNodeId': currentNodeId,
    'karma': karma,
    'selectedChoices': selectedChoices,
    'unlockedCollectibles': unlockedCollectibles.toList(),
    'completedEndingId': completedEndingId,
  };

  static GameSnapshot fromJson(Map<String, Object?> json) {
    return GameSnapshot(
      currentNodeId:
          json['currentNodeId'] as String? ?? StoryRepository.startNodeId,
      karma: json['karma'] as int? ?? 0,
      selectedChoices: (json['selectedChoices'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      unlockedCollectibles:
          (json['unlockedCollectibles'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toSet(),
      completedEndingId: json['completedEndingId'] as String?,
    );
  }
}

abstract class ProgressStore {
  Future<GameSnapshot?> load();
  Future<void> save(GameSnapshot snapshot);
}

class SharedPreferencesProgressStore implements ProgressStore {
  const SharedPreferencesProgressStore(this.prefs);

  static const _key = 'fqa_game_state';

  final SharedPreferences prefs;

  @override
  Future<GameSnapshot?> load() async {
    final value = prefs.getString(_key);
    if (value == null) return null;
    return GameSnapshot.fromJson(jsonDecode(value) as Map<String, Object?>);
  }

  @override
  Future<void> save(GameSnapshot snapshot) {
    return prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }
}

class MemoryProgressStore implements ProgressStore {
  GameSnapshot? snapshot;

  @override
  Future<GameSnapshot?> load() async => snapshot;

  @override
  Future<void> save(GameSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

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
    view = AppView.collection;
    collectionFilter = filter;
    pauseVisible = false;
    notifyListeners();
  }

  void exitToHome() {
    view = AppView.home;
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

  void _goToNode(String nodeId) {
    final next = StoryRepository.node(nodeId);
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
}

class StoryRepository {
  static const startNodeId = 'inheritance_intro';

  static const collectibles = [
    Collectible(
      id: 'bag3',
      name: 'Túi ba gang',
      description: 'Biểu tượng của sự vừa đủ.',
      assetName: 'collectibles/item_bag3.png',
    ),
    Collectible(
      id: 'starfruit',
      name: 'Cây khế',
      description: 'Gia tài nhỏ mở ra con đường mới.',
      assetName: 'collectibles/item_starfruit.png',
    ),
    Collectible(
      id: 'gold',
      name: 'Vàng',
      description: 'Phần thưởng thử lòng người.',
      assetName: 'collectibles/item_gold.png',
    ),
    Collectible(
      id: 'feather',
      name: 'Lông chim thần',
      description: 'Biểu tượng của cơ duyên và lòng tốt được đền đáp.',
      assetName: 'collectibles/item_feather.png',
    ),
    Collectible(
      id: 'bag12',
      name: 'Túi 12 gang',
      description: 'Lời nhắc về lòng tham.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'half',
      name: 'Nửa tài sản',
      description: 'Một khả năng khác trong cuộc chia gia tài.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery1',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery2',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery3',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
  ];

  static Set<String> get initialUnlockedIds => collectibles
      .where((collectible) => collectible.initiallyUnlocked)
      .map((collectible) => collectible.id)
      .toSet();

  static const endings = {
    'enough': Ending(
      id: 'enough',
      title: 'Con đường biết đủ',
      karmaSummary: 'Người đã biết dừng lại.',
    ),
    'fairness': Ending(
      id: 'fairness',
      title: 'Con đường công bằng',
      karmaSummary: 'Người đã chọn nói điều cần nói.',
    ),
    'leaving': Ending(
      id: 'leaving',
      title: 'Con đường tự lập',
      karmaSummary: 'Người đã rời đi để giữ lòng bình yên.',
    ),
  };

  static const nodes = {
    // Placeholder story data: replace these nodes with the final script later.
    'inheritance_intro': StoryNode(
      id: 'inheritance_intro',
      title: 'Chia gia tài',
      type: StoryNodeType.dialogue,
      speaker: 'Người anh',
      text:
          'Từ nay, chú hãy ra ở riêng. Ta chia cho chú cây khế sau nhà, còn ruộng vườn ta giữ lại.',
      nextId: 'inheritance_choice',
    ),
    'inheritance_choice': StoryNode(
      id: 'inheritance_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Người em',
      text:
          'Người em nên đáp lại thế nào trước lời chia gia tài của người anh?',
      choices: [
        StoryChoice(
          label: 'Nhận cây khế',
          nextId: 'bag_choice',
          karmaDelta: 1,
          unlockCollectibleIds: ['starfruit'],
        ),
        StoryChoice(
          label: 'Xin chia lại',
          nextId: 'fairness_reflection',
          karmaDelta: 0,
          unlockCollectibleIds: ['half'],
        ),
        StoryChoice(
          label: 'Rời đi',
          nextId: 'leaving_reflection',
          karmaDelta: -1,
        ),
      ],
    ),
    'bag_choice': StoryNode(
      id: 'bag_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Chim thần',
      text: 'Chim thần hứa trả vàng và bảo người em chuẩn bị một chiếc túi.',
      choices: [
        StoryChoice(
          label: 'Chọn túi ba gang',
          nextId: 'gold_choice',
          karmaDelta: 1,
          unlockCollectibleIds: ['bag3', 'feather'],
        ),
        StoryChoice(
          label: 'Chọn túi 12 gang',
          nextId: 'greed_reflection',
          karmaDelta: -2,
          unlockCollectibleIds: ['bag12'],
        ),
      ],
    ),
    'gold_choice': StoryNode(
      id: 'gold_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Người em',
      text:
          'Đứng trước kho vàng, người em cần quyết định có lấy thêm hay không.',
      choices: [
        StoryChoice(
          label: 'Không lấy thêm vàng',
          nextId: 'enough_reflection',
          karmaDelta: 1,
          unlockCollectibleIds: ['gold'],
        ),
        StoryChoice(
          label: 'Lấy thêm một ít',
          nextId: 'greed_reflection',
          karmaDelta: -1,
          unlockCollectibleIds: ['gold'],
        ),
      ],
    ),
    'enough_reflection': StoryNode(
      id: 'enough_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Điều khó nhất trên đời không phải là kiếm được, mà là biết đủ.',
      nextId: 'feather_unlock',
      karmaDelta: 1,
      reflectionTitle: 'Người đã biết dừng lại.',
    ),
    'fairness_reflection': StoryNode(
      id: 'fairness_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Có những lúc công bằng bắt đầu bằng một lời nói bình tĩnh.',
      nextId: 'fairness_ending',
      karmaDelta: 1,
      reflectionTitle: 'Người đã giữ tiếng nói của mình.',
    ),
    'leaving_reflection': StoryNode(
      id: 'leaving_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Rời đi không phải lúc nào cũng là thua cuộc.',
      nextId: 'leaving_ending',
      karmaDelta: 0,
      reflectionTitle: 'Người đã chọn bình yên.',
    ),
    'greed_reflection': StoryNode(
      id: 'greed_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text:
          'Khi chiếc túi lớn hơn điều cần thiết, đường về cũng trở nên nặng hơn.',
      nextId: 'enough_ending',
      karmaDelta: -1,
      reflectionTitle: 'Người đã nhìn thấy giới hạn.',
    ),
    'feather_unlock': StoryNode(
      id: 'feather_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Biểu tượng của cơ duyên, phần thưởng và lòng tốt được đền đáp.',
      nextId: 'enough_ending',
      unlockCollectibleId: 'feather',
    ),
    'enough_ending': StoryNode(
      id: 'enough_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường biết đủ',
      endingId: 'enough',
    ),
    'fairness_ending': StoryNode(
      id: 'fairness_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường công bằng',
      endingId: 'fairness',
    ),
    'leaving_ending': StoryNode(
      id: 'leaving_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường tự lập',
      endingId: 'leaving',
    ),
  };

  static StoryNode node(String id) => nodes[id] ?? nodes[startNodeId]!;
}

class FqaColors {
  static const gold = Color(0xffffd36b);
  static const cream = Color(0xfffff0bd);
  static const parchment = Color(0xffead8af);
  static const brown = Color(0xff1b120c);
}

class FqaAssets {
  static const base = 'assets/images/figma';
  static String image(String name) => '$base/$name';
}

class FqaScaffold extends StatelessWidget {
  const FqaScaffold({
    required this.background,
    required this.child,
    this.overlay,
    super.key,
  });

  final String background;
  final Widget child;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FqaColors.brown,
      body: Center(
        child: AspectRatio(
          aspectRatio: 426 / 899,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FqaAssetImage(
                      background,
                      fit: BoxFit.cover,
                      fallback: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff36210f),
                              Color(0xff19100b),
                              Color(0xff090705),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ?overlay,
                    child,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FqaAssetImage extends StatelessWidget {
  const FqaAssetImage(
    this.assetName, {
    this.fit = BoxFit.contain,
    this.fallback,
    super.key,
  });

  final String assetName;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      FqaAssets.image(assetName),
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff33200f),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff8b6a2e)),
              ),
            );
      },
    );
  }
}

class FqaImageButton extends StatelessWidget {
  const FqaImageButton({
    required this.label,
    required this.onPressed,
    this.assetName = 'buttons/primary_button.png',
    this.width = 300,
    this.height = 80,
    this.fontSize = 22,
    this.letterSpacing,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final String assetName;
  final double width;
  final double height;
  final double fontSize;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        key: ValueKey('button_$label'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: FqaColors.cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            FqaAssetImage(assetName, fit: BoxFit.fill),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FqaColors.cream,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  height: 1.2,
                  letterSpacing: letterSpacing,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/home_bg.png',
      child: Stack(
        children: [
          const Positioned(
            top: 116,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'FolkQuest',
                  style: TextStyle(
                    color: Color(0xffffe8a6),
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.15,
                    height: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '· Ăn khế trả vàng ·',
                  style: TextStyle(
                    color: FqaColors.cream,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 502,
            left: 0,
            right: 0,
            child: Column(
              children: [
                FqaImageButton(
                  label: 'Bắt đầu',
                  onPressed: controller.startOrResume,
                ),
                const SizedBox(height: 16),
                FqaImageButton(
                  label: 'Bộ sưu tập',
                  onPressed: controller.openCollection,
                ),
                const SizedBox(height: 16),
                FqaImageButton(
                  label: 'Thành tích',
                  onPressed: () => _showPlaceholder(context, 'Thành tích'),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 27,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UtilityIcon(
                  assetName: 'icons/guide_icon.png',
                  semanticLabel: 'Hướng dẫn',
                  onTap: () => _showPlaceholder(context, 'Hướng dẫn'),
                ),
                const SizedBox(width: 24),
                UtilityIcon(
                  assetName: 'icons/settings_icon.png',
                  semanticLabel: 'Cài đặt',
                  onTap: () => _showPlaceholder(context, 'Cài đặt'),
                ),
                const SizedBox(width: 24),
                UtilityIcon(
                  assetName: 'icons/login_icon.png',
                  semanticLabel: 'Đăng nhập',
                  onTap: () => _showPlaceholder(context, 'Đăng nhập'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    return switch (node.type) {
      StoryNodeType.dialogue => DiscussionScreen(controller: controller),
      StoryNodeType.options => OptionsScreen(controller: controller),
      StoryNodeType.karma => KarmaReflectionScreen(controller: controller),
      StoryNodeType.unlock => UnlockCollectibleScreen(controller: controller),
      StoryNodeType.ending => FinalEndingScreen(controller: controller),
    };
  }
}

class StoryTopBar extends StatelessWidget {
  const StoryTopBar({
    required this.title,
    required this.onBack,
    required this.onPause,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      left: 12,
      right: 12,
      height: 128,
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: 'Quay lại',
              size: 48,
              onTap: onBack,
            ),
          ),
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 240,
                height: 127,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const FqaAssetImage('panels/title_plaque.png'),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: FqaColors.cream,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: UtilityIcon(
              assetName: 'icons/pause_icon.png',
              semanticLabel: 'Tạm dừng',
              size: 48,
              onTap: onPause,
            ),
          ),
        ],
      ),
    );
  }
}

class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    return FqaScaffold(
      background: 'backgrounds/story_bg.png',
      child: Stack(
        children: [
          StoryTopBar(
            title: node.title,
            onBack: controller.exitToHome,
            onPause: controller.showPause,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 49,
            child: StoryDialoguePanel(
              speaker: node.speaker ?? '',
              text: node.text,
              onContinue: controller.advance,
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({required this.controller, super.key});

  final GameController controller;

  static const _choiceButtonAssets = [
    'buttons/choice_button_blue.png',
    'buttons/choice_button_brown.png',
    'buttons/choice_button_green.png',
  ];

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    return FqaScaffold(
      background: 'backgrounds/options_bg.png',
      child: Stack(
        children: [
          StoryTopBar(
            title: node.title,
            onBack: controller.exitToHome,
            onPause: controller.showPause,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 464,
            child: StoryPromptPanel(
              speaker: node.speaker ?? '',
              text: node.text,
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            top: 628,
            child: Column(
              children: [
                for (final entry in node.choices.asMap().entries) ...[
                  if (entry.key > 0) const SizedBox(height: 12),
                  FqaImageButton(
                    label: entry.value.label,
                    width: 362,
                    height: 60,
                    fontSize: 18,
                    letterSpacing: 0.45,
                    assetName:
                        _choiceButtonAssets[entry.key %
                            _choiceButtonAssets.length],
                    onPressed: () => controller.choose(entry.value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryPromptPanel extends StatelessWidget {
  const StoryPromptPanel({
    required this.speaker,
    required this.text,
    super.key,
  });

  final String speaker;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 24,
            top: 14,
            height: 138,
            child: FqaAssetImage(
              'panels/choice_panel.png',
              fit: BoxFit.fill,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xcc2b1a0d),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xff8b6a2e), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 46,
            right: 46,
            top: 58,
            child: Text(
              text,
              style: const TextStyle(
                color: FqaColors.cream,
                fontSize: 17,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SpeakerTag(speaker: speaker),
        ],
      ),
    );
  }
}

class StoryDialoguePanel extends StatelessWidget {
  const StoryDialoguePanel({
    required this.speaker,
    required this.text,
    required this.onContinue,
    super.key,
  });

  final String speaker;
  final String text;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 40,
            top: 13,
            height: 179,
            child: FqaAssetImage(
              'panels/dialog_panel.png',
              fit: BoxFit.fill,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xdd2a1a0d),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xff8b6a2e), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 44,
            right: 88,
            top: 64,
            child: Text(
              text,
              key: const ValueKey('story_dialogue_text'),
              style: const TextStyle(
                color: FqaColors.cream,
                fontSize: 17,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SpeakerTag(speaker: speaker),
          Positioned(
            right: 48,
            bottom: 38,
            child: Transform.rotate(
              angle: 3.14159,
              child: UtilityIcon(
                assetName: 'icons/back_icon.png',
                semanticLabel: 'Tiếp tục',
                size: 40,
                onTap: onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeakerTag extends StatelessWidget {
  const SpeakerTag({required this.speaker, super.key});

  final String speaker;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      top: 0,
      width: 150,
      height: 35,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage('panels/speaker_tag.png', fit: BoxFit.fill),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                speaker,
                style: const TextStyle(
                  color: FqaColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KarmaReflectionScreen extends StatelessWidget {
  const KarmaReflectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    final sign = controller.karma >= 0 ? '+' : '';
    return FqaScaffold(
      background: 'backgrounds/karma_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x55080706)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 37,
            right: 37,
            top: 56,
            height: 101,
            child: Stack(
              fit: StackFit.expand,
              children: const [
                FqaAssetImage('panels/karma_title.png'),
                Center(
                  child: Text(
                    'Nghiệp Lực',
                    style: TextStyle(
                      color: Color(0xfff7e4b0),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 180,
            child: Column(
              children: [
                SizedBox(
                  width: 224,
                  height: 102,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FqaAssetImage('panels/karma_badge.png'),
                      Center(
                        child: Text(
                          '$sign${controller.karma}',
                          style: const TextStyle(
                            color: FqaColors.gold,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  node.reflectionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xfff2d39a),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: Text(
                    node.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xfff0d7a4),
                      fontSize: 16,
                      height: 1.78,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 94,
            right: 94,
            bottom: 61,
            child: FqaImageButton(
              label: 'Tiếp tục',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/small_button.png',
              onPressed: controller.advance,
            ),
          ),
        ],
      ),
    );
  }
}

class UnlockCollectibleScreen extends StatelessWidget {
  const UnlockCollectibleScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final collectible = StoryRepository.collectibles.firstWhere(
      (item) => item.id == controller.currentNode.unlockCollectibleId,
      orElse: () => StoryRepository.collectibles.first,
    );
    return FqaScaffold(
      background: 'backgrounds/unlock_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xbb070504)),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 39,
            child: Text(
              'Đã mở khóa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff4d88f),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.44,
              ),
            ),
          ),
          Positioned(
            left: 109,
            right: 109,
            top: 106,
            height: 208,
            child: FqaAssetImage(
              collectible.assetName,
              fallback: const Icon(
                Icons.auto_awesome,
                color: FqaColors.gold,
                size: 120,
              ),
            ),
          ),
          Positioned(
            left: 40,
            right: 40,
            top: 338,
            child: Text(
              collectible.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xffefcf86),
                fontSize: 30,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: 84,
            right: 84,
            top: 399,
            child: Text(
              collectible.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xffe7d3a2),
                fontSize: 16,
                height: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 94,
            right: 94,
            bottom: 31,
            child: Column(
              children: [
                FqaImageButton(
                  label: 'Xem bộ sưu tập',
                  width: 238,
                  height: 56,
                  fontSize: 19,
                  assetName: 'buttons/unlock_button.png',
                  onPressed: () =>
                      controller.continueFromUnlock(openCollectionFirst: true),
                ),
                const SizedBox(height: 14),
                FqaImageButton(
                  label: 'Tiếp tục',
                  width: 238,
                  height: 56,
                  fontSize: 19,
                  assetName: 'buttons/unlock_button.png',
                  onPressed: controller.continueFromUnlock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinalEndingScreen extends StatelessWidget {
  const FinalEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ending = controller.currentEnding;
    final opened = StoryRepository.collectibles
        .where(controller.isUnlocked)
        .take(3)
        .toList(growable: false);
    return FqaScaffold(
      background: 'backgrounds/ending_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xdd080604)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Kết cục của bạn',
              style: TextStyle(
                color: Color(0xffd9b86d),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ending.title,
              key: const ValueKey('ending_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xfff5da92),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 350,
                height: 175,
                child: FqaAssetImage(
                  'backgrounds/ending_image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Nghiệp lực',
                  style: TextStyle(
                    color: Color(0xffd7b66f),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FqaAssetImage('panels/karma_score_pill.png'),
                      Center(
                        child: Text(
                          controller.karma >= 0
                              ? '+${controller.karma}'
                              : '${controller.karma}',
                          style: const TextStyle(
                            color: Color(0xffefd98d),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            SectionTitle('Những lựa chọn chính'),
            const SizedBox(height: 6),
            SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final choice in controller.selectedChoices.take(3))
                    ChoiceBullet(choice),
                  if (controller.selectedChoices.isEmpty)
                    const ChoiceBullet('Chưa có lựa chọn'),
                ],
              ),
            ),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            const SectionTitle('Cổ vật đã mở khóa'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in opened)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: FqaAssetImage(item.assetName),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            FqaImageButton(
              label: 'Chơi lại',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/ending_button.png',
              onPressed: controller.restartRun,
            ),
            const SizedBox(height: 14),
            FqaImageButton(
              label: 'Về menu chính',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/ending_button.png',
              onPressed: controller.exitToHome,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffd7b66f),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.08,
        ),
      ),
    );
  }
}

class ChoiceBullet extends StatelessWidget {
  const ChoiceBullet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text(
            '•',
            style: TextStyle(color: Color(0xffddb45d), fontSize: 16),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: FqaColors.parchment,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredCollectibles().toList(growable: false);
    return FqaScaffold(
      background: 'backgrounds/collection_bg.png',
      overlay: const FqaAssetImage(
        'backgrounds/collection_overlay.png',
        fit: BoxFit.cover,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 49,
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: 'Quay lại',
              size: 40,
              onTap: controller.exitToHome,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 52,
            child: Text(
              'Bộ sưu tập',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff0dca0),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.76,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 122,
            bottom: 172,
            child: CollectibleGrid(controller: controller, items: items),
          ),
          Positioned(
            left: 63,
            right: 63,
            bottom: 172,
            height: 66,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xe61d140b),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff7a5a28)),
              ),
              child: const Center(
                child: Text(
                  'Thu thập để khám phá\ncâu chuyện và ý nghĩa ẩn giấu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffecdba8),
                    fontSize: 12,
                    height: 1.65,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 33,
            right: 33,
            bottom: 25,
            height: 76,
            child: CollectionNavigation(controller: controller),
          ),
        ],
      ),
    );
  }
}

class CollectibleGrid extends StatelessWidget {
  const CollectibleGrid({
    required this.controller,
    required this.items,
    super.key,
  });

  final GameController controller;
  final List<Collectible> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 126 / 170,
      children: [
        for (final collectible in items)
          CollectibleCard(
            collectible: collectible,
            unlocked: controller.isUnlocked(collectible),
          ),
      ],
    );
  }
}

class CollectibleCard extends StatelessWidget {
  const CollectibleCard({
    required this.collectible,
    required this.unlocked,
    super.key,
  });

  final Collectible collectible;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final visibleName = unlocked ? collectible.name : '???';
    return SizedBox(
      key: ValueKey('collectible_${collectible.id}'),
      width: 126,
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xfff5e8c8), Color(0xffe5d29a)],
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.28,
                          child: FqaAssetImage(
                            collectible.assetName,
                            fallback: Icon(
                              unlocked ? Icons.auto_awesome : Icons.lock,
                              color: const Color(0xff6a481d),
                              size: 46,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 46,
                    color: const Color(0xff1c150a),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      visibleName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xffe1ce97),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FqaAssetImage('panels/card_frame.png', fit: BoxFit.fill),
        ],
      ),
    );
  }
}

class CollectionNavigation extends StatelessWidget {
  const CollectionNavigation({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const FqaAssetImage('navigation/nav_bar.png', fit: BoxFit.fill),
        Row(
          children: [
            CollectionTab(
              label: 'Tất cả',
              assetName: 'navigation/nav_all.png',
              selected: controller.collectionFilter == CollectionFilter.all,
              onTap: () => controller.setCollectionFilter(CollectionFilter.all),
            ),
            CollectionTab(
              label: 'Đã mở',
              assetName: 'navigation/nav_open.png',
              selected: controller.collectionFilter == CollectionFilter.opened,
              onTap: () =>
                  controller.setCollectionFilter(CollectionFilter.opened),
            ),
            CollectionTab(
              label: 'Chưa mở',
              assetName: 'navigation/nav_locked.png',
              selected: controller.collectionFilter == CollectionFilter.locked,
              onTap: () =>
                  controller.setCollectionFilter(CollectionFilter.locked),
            ),
          ],
        ),
      ],
    );
  }
}

class CollectionTab extends StatelessWidget {
  const CollectionTab({
    required this.label,
    required this.assetName,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final String assetName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        key: ValueKey('filter_$label'),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: FqaAssetImage(
                assetName,
                fallback: Icon(
                  selected ? Icons.auto_awesome : Icons.lock_open,
                  color: selected ? FqaColors.gold : const Color(0xffc8ad6b),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xfff0dc9d)
                    : const Color(0xffc8ad6b),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onContinue,
    required this.onRestart,
    required this.onExit,
    required this.onUtility,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final ValueChanged<String> onUtility;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: SizedBox(
          width: 340,
          height: 477,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: FqaAssetImage(
                  'panels/pause_panel.png',
                  fit: BoxFit.fill,
                  fallback: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xff25170c),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -16,
                right: -16,
                child: UtilityIcon(
                  assetName: 'icons/close_icon.png',
                  semanticLabel: 'Đóng',
                  size: 56,
                  onTap: onContinue,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
                  child: Column(
                    children: [
                      const Text(
                        'Tạm dừng',
                        style: TextStyle(
                          color: FqaColors.cream,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 160,
                        height: 1,
                        color: const Color(0xff8b6a2e),
                      ),
                      const SizedBox(height: 16),
                      FqaImageButton(
                        label: 'Tiếp tục',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onContinue,
                      ),
                      const SizedBox(height: 8),
                      FqaImageButton(
                        label: 'Chơi lại',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onRestart,
                      ),
                      const SizedBox(height: 8),
                      FqaImageButton(
                        label: 'Thoát',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onExit,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UtilityIcon(
                            assetName: 'icons/profile_icon.png',
                            semanticLabel: 'Hồ sơ',
                            size: 48,
                            onTap: () => onUtility('Hồ sơ'),
                          ),
                          const SizedBox(width: 20),
                          UtilityIcon(
                            assetName: 'icons/settings_icon.png',
                            semanticLabel: 'Cài đặt',
                            size: 48,
                            onTap: () => onUtility('Cài đặt'),
                          ),
                          const SizedBox(width: 20),
                          UtilityIcon(
                            assetName: 'icons/help_icon.png',
                            semanticLabel: 'Trợ giúp',
                            size: 48,
                            onTap: () => onUtility('Trợ giúp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UtilityIcon extends StatelessWidget {
  const UtilityIcon({
    required this.assetName,
    required this.semanticLabel,
    required this.onTap,
    this.size = 56,
    super.key,
  });

  final String assetName;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: InkWell(
        key: ValueKey('icon_$semanticLabel'),
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: FqaAssetImage(
            assetName,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff2d1b0d),
                border: Border.all(color: const Color(0xff8b6a2e)),
              ),
              child: Center(
                child: Icon(
                  semanticLabel == 'Quay lại'
                      ? Icons.arrow_back
                      : semanticLabel == 'Tạm dừng'
                      ? Icons.pause
                      : semanticLabel == 'Đóng'
                      ? Icons.close
                      : Icons.auto_awesome,
                  color: FqaColors.gold,
                  size: size * 0.48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
