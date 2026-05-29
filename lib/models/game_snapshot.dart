import 'package:fqa/repositories/story_repository.dart';

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
