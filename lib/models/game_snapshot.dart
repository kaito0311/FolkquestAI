import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/models/app_language.dart';

class GameSnapshot {
  const GameSnapshot({
    required this.currentNodeId,
    required this.karma,
    required this.selectedChoices,
    required this.unlockedCollectibles,
    this.runUnlockedCollectibles = const {},
    this.completedEndingId,
    this.playCount = 0,
    this.language = AppLanguage.vietnamese,
    this.vietnameseVoiceName,
    this.englishVoiceName,
    this.speechRate = 0.46,
  });

  final String currentNodeId;
  final int karma;
  final List<String> selectedChoices;
  final Set<String> unlockedCollectibles;
  final Set<String> runUnlockedCollectibles;
  final String? completedEndingId;
  final int playCount;
  final AppLanguage language;
  final String? vietnameseVoiceName;
  final String? englishVoiceName;
  final double speechRate;

  Map<String, Object?> toJson() => {
    'currentNodeId': currentNodeId,
    'karma': karma,
    'selectedChoices': selectedChoices,
    'unlockedCollectibles': unlockedCollectibles.toList(),
    'runUnlockedCollectibles': runUnlockedCollectibles.toList(),
    'completedEndingId': completedEndingId,
    'playCount': playCount,
    'language': language.languageCode,
    'vietnameseVoiceName': vietnameseVoiceName,
    'englishVoiceName': englishVoiceName,
    'speechRate': speechRate,
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
      runUnlockedCollectibles:
          (json['runUnlockedCollectibles'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toSet(),
      completedEndingId: json['completedEndingId'] as String?,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      language: AppLanguage.fromLanguageCode(json['language'] as String?),
      vietnameseVoiceName: json['vietnameseVoiceName'] as String?,
      englishVoiceName: json['englishVoiceName'] as String?,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.46,
    );
  }
}
