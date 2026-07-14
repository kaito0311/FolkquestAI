import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/screens/story/discussion_screen.dart';
import 'package:fqa/screens/story/final_ending_screen.dart';
import 'package:fqa/screens/story/first_ending_screen.dart';
import 'package:fqa/screens/story/karma_reflection_screen.dart';
import 'package:fqa/screens/story/options_screen.dart';
import 'package:fqa/screens/story/unlock_collectible_screen.dart';
import 'package:fqa/widgets/fqa_transitions.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    final screen = switch (node.type) {
      StoryNodeType.dialogue => DiscussionScreen(controller: controller),
      StoryNodeType.options => OptionsScreen(controller: controller),
      StoryNodeType.firstEnding => FirstEndingScreen(controller: controller),
      StoryNodeType.karma => KarmaReflectionScreen(controller: controller),
      StoryNodeType.unlock => UnlockCollectibleScreen(controller: controller),
      StoryNodeType.ending => FinalEndingScreen(controller: controller),
    };
    return AnimatedSwitcher(
      duration: FqaTransitions.durationFor(
        context,
        FqaTransitions.storyNodeDuration,
      ),
      switchInCurve: FqaTransitions.curve,
      switchOutCurve: FqaTransitions.curve,
      transitionBuilder: (child, animation) =>
          FqaTransitions.storyNodeTransition(
            controller.storyTransition,
            child,
            animation,
          ),
      child: KeyedSubtree(key: ValueKey(node.id), child: screen),
    );
  }
}
