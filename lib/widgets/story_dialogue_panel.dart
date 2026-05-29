import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/speaker_tag.dart';
import 'package:fqa/widgets/utility_icon.dart';

class StoryDialoguePanel extends StatelessWidget {
  const StoryDialoguePanel({
    required this.speaker,
    required this.text,
    required this.onContinue,
    super.key,
  });

  final String speaker;
  final String text;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 40,
            top: 13,
            height: 179,
            child: FqaAssetImage(
              'panels/dialog_panel.png',
              fit: BoxFit.fill,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xdd2a1a0d),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xff8b6a2e), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 44,
            right: 88,
            top: 64,
            child: Text(
              text,
              key: const ValueKey('story_dialogue_text'),
              style: const TextStyle(
                color: FqaColors.cream,
                fontSize: 17,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SpeakerTag(speaker: speaker),
          Positioned(
            right: 48,
            bottom: 38,
            child: Transform.rotate(
              angle: 3.14159,
              child: UtilityIcon(
                assetName: 'icons/back_icon.png',
                semanticLabel: 'Tiếp tục',
                size: 40,
                onTap: onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
