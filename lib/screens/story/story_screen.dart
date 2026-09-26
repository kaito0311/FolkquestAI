import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_assets.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/models/story_transition_kind.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/screens/story/discussion_screen.dart';
import 'package:fqa/screens/story/final_ending_screen.dart';
import 'package:fqa/screens/story/first_ending_screen.dart';
import 'package:fqa/screens/story/karma_reflection_screen.dart';
import 'package:fqa/screens/story/options_screen.dart';
import 'package:fqa/screens/story/unlock_collectible_screen.dart';
import 'package:fqa/widgets/fqa_transitions.dart';
import 'package:fqa/widgets/story_top_bar.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  String? _preparedNodeId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheStoryBackgrounds();
  }

  @override
  void didUpdateWidget(covariant StoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _precacheStoryBackgrounds();
  }

  void _precacheStoryBackgrounds() {
    final node = widget.controller.currentNode;
    if (_preparedNodeId == node.id) return;
    _preparedNodeId = node.id;

    final assetNames = <String>{};
    void addBackgroundForNodeId(String? nodeId) {
      if (nodeId == null) return;
      final candidate = StoryRepository.nodes[nodeId];
      if (candidate == null) return;
      final background = switch (candidate.type) {
        StoryNodeType.dialogue =>
          candidate.background ?? 'backgrounds/story_bg.png',
        StoryNodeType.options =>
          candidate.background ?? 'backgrounds/options_bg.png',
        _ => null,
      };
      if (background != null) assetNames.add(background);
    }

    addBackgroundForNodeId(node.id);
    addBackgroundForNodeId(node.nextId);
    for (final choice in node.choices) {
      addBackgroundForNodeId(choice.nextId);
    }
    for (final route in node.karmaRoutes) {
      addBackgroundForNodeId(route.nextId);
    }

    for (final assetName in assetNames) {
      unawaited(precacheImage(AssetImage(FqaAssets.image(assetName)), context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final node = controller.currentNode;
    final screen = switch (node.type) {
      StoryNodeType.dialogue => DiscussionScreen(controller: controller),
      StoryNodeType.options => OptionsScreen(controller: controller),
      StoryNodeType.firstEnding => FirstEndingScreen(controller: controller),
      StoryNodeType.karma => KarmaReflectionScreen(controller: controller),
      StoryNodeType.unlock => UnlockCollectibleScreen(controller: controller),
      StoryNodeType.ending => FinalEndingScreen(controller: controller),
    };
    final transitionDuration =
        FqaTransitions.usesStoryFlowTransition(controller.storyTransition)
        ? FqaTransitions.storyNodeDuration
        : Duration.zero;
    final showsPersistentTopBar =
        node.type == StoryNodeType.dialogue ||
        node.type == StoryNodeType.options;
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: FqaTransitions.durationFor(context, transitionDuration),
          switchInCurve: FqaTransitions.curve,
          switchOutCurve: FqaTransitions.curve,
          transitionBuilder: (child, animation) =>
              FqaTransitions.storyNodeTransition(
                controller.storyTransition,
                child,
                animation,
              ),
          child: KeyedSubtree(key: ValueKey(node.id), child: screen),
        ),
        if (showsPersistentTopBar)
          StoryTopBar(
            title: node.title,
            onBack: controller.exitToHome,
            onPause: controller.showPause,
            animateEntrance:
                controller.storyTransition == StoryTransitionKind.homeToStory,
          ),
      ],
    );
  }
}
