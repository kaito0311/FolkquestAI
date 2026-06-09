import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node_type.dart';

class StoryNode {
  const StoryNode({
    required this.id,
    required this.title,
    required this.type,
    required this.text,
    this.speaker,
    this.background,
    this.coverAlignmentX = 0,
    this.coverAlignmentY = 0,
    this.nextId,
    this.choices = const [],
    this.karmaRoutes = const [],
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
  final String? background;
  final double coverAlignmentX;
  final double coverAlignmentY;
  final String? nextId;
  final List<StoryChoice> choices;
  final List<KarmaRoute> karmaRoutes;
  final int karmaDelta;
  final String reflectionTitle;
  final String? unlockCollectibleId;
  final String? endingId;
}

class KarmaRoute {
  const KarmaRoute({required this.nextId, this.minKarma, this.maxKarma});

  final String nextId;
  final int? minKarma;
  final int? maxKarma;

  bool matches(int karma) {
    final aboveMinimum = minKarma == null || karma >= minKarma!;
    final belowMaximum = maxKarma == null || karma <= maxKarma!;
    return aboveMinimum && belowMaximum;
  }
}
