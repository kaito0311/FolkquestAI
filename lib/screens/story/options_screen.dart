import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/story_prompt_panel.dart';
import 'package:fqa/widgets/story_top_bar.dart';

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
