import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/story_dialogue_panel.dart';
import 'package:fqa/widgets/story_top_bar.dart';

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
