import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_dialogue_panel.dart';
import 'package:fqa/widgets/story_top_bar.dart';

class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    return FqaScaffold(
      background: node.background ?? 'backgrounds/story_bg.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final panelWidth = layout.contentWidth(
            constraints.maxWidth,
            landscapeValue: 640,
          );
          final panelBottom = layout.isLandscape
              ? layout.gap(28)
              : layout.y(49).clamp(24.0, 49.0);

          return Stack(
            children: [
              StoryTopBar(
                title: node.title,
                onBack: controller.exitToHome,
                onPause: controller.showPause,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: panelBottom,
                child: Center(
                  child: SizedBox(
                    width: panelWidth,
                    child: StoryDialoguePanel(
                      speaker: node.speaker ?? '',
                      text: node.text,
                      onContinue: controller.advance,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
