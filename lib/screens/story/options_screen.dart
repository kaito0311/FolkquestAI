import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalPadding(32);
          final choiceWidth = layout.maxWidth(362, padding: horizontalPadding);
          final choiceHeight = layout.s(60).clamp(52.0, 60.0);
          final promptTop = layout
              .y(464)
              .clamp(390.0, constraints.maxHeight * 0.56);
          final choicesTop = (promptTop + layout.y(164)).clamp(
            promptTop + 140,
            constraints.maxHeight - 220,
          );

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
                top: promptTop,
                child: StoryPromptPanel(
                  speaker: node.speaker ?? '',
                  text: node.text,
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: choicesTop,
                bottom: layout.gap(18),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final entry in node.choices.asMap().entries) ...[
                        if (entry.key > 0) SizedBox(height: layout.gap(12)),
                        FqaImageButton(
                          label: entry.value.label,
                          width: choiceWidth,
                          height: choiceHeight,
                          fontSize: layout.font(18),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
