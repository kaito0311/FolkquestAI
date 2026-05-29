import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node_type.dart';

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
