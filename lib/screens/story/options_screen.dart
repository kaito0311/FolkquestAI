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
          final contentWidth = layout.contentWidth(
            constraints.maxWidth,
            landscapeValue: 640,
          );
          final choiceWidth = layout.isLandscape
              ? layout.contentWidth(362, landscapeValue: 420)
              : layout.maxWidth(362, padding: horizontalPadding);
          final choiceHeight = layout.s(60).clamp(52.0, 60.0);
          final portraitPromptTop = layout.y(464);
          final portraitPromptMax = constraints.maxHeight * 0.56;
          final safePortraitPromptTop = portraitPromptMax < 390
              ? portraitPromptMax
              : portraitPromptTop.clamp(390.0, portraitPromptMax);
          final promptTop = layout.isLandscape
              ? layout.y(214).clamp(150.0, constraints.maxHeight * 0.36)
              : safePortraitPromptTop;
          final portraitChoicesTop = promptTop + layout.y(164);
          final portraitChoicesMin = promptTop + 140;
          final portraitChoicesMax = constraints.maxHeight - 220;
          final safePortraitChoicesTop = portraitChoicesMax < portraitChoicesMin
              ? portraitChoicesMax
              : portraitChoicesTop.clamp(
                  portraitChoicesMin,
                  portraitChoicesMax,
                );
          final choicesTop = layout.isLandscape
              ? promptTop + layout.gap(150)
              : safePortraitChoicesTop;

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
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: StoryPromptPanel(
                      speaker: node.speaker ?? '',
                      text: node.text,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: layout.isLandscape ? 0 : horizontalPadding,
                right: layout.isLandscape ? 0 : horizontalPadding,
                top: choicesTop,
                bottom: layout.gap(18),
                child: Center(
                  child: SizedBox(
                    width: layout.isLandscape ? contentWidth : null,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
