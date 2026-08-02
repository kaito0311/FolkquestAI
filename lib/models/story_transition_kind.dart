import 'package:fqa/models/story_node_type.dart';

enum StoryTransitionKind {
  homeToStory,
  storyToStory,
  storyToOptions,
  optionsToStory,
  toFirstEnding,
  firstEndingToKarma,
  karmaToUnlock,
  unlockToEnding,
  defaultTransition;

  static StoryTransitionKind between(StoryNodeType from, StoryNodeType to) {
    if (from == StoryNodeType.dialogue && to == StoryNodeType.dialogue) {
      return storyToStory;
    }
    if (from == StoryNodeType.dialogue && to == StoryNodeType.options) {
      return storyToOptions;
    }
    if (from == StoryNodeType.options && to == StoryNodeType.dialogue) {
      return optionsToStory;
    }
    if (to == StoryNodeType.firstEnding) return toFirstEnding;
    if (from == StoryNodeType.firstEnding && to == StoryNodeType.karma) {
      return firstEndingToKarma;
    }
    if (from == StoryNodeType.karma && to == StoryNodeType.unlock) {
      return karmaToUnlock;
    }
    if (from == StoryNodeType.unlock && to == StoryNodeType.ending) {
      return unlockToEnding;
    }
    return defaultTransition;
  }
}
