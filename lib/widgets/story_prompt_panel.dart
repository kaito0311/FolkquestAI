import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scroll_hint.dart';
import 'package:fqa/widgets/speaker_tag.dart';

class StoryPromptPanel extends StatelessWidget {
  const StoryPromptPanel({
    required this.speaker,
    required this.text,
    required this.onSpeak,
    super.key,
  });

  final String speaker;
  final String text;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 24,
            top: 14,
            height: 138,
            child: FqaAssetImage(
              'panels/choice_panel.png',
              fit: BoxFit.fill,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xcc2b1a0d),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xff8b6a2e), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 46,
            right: 46,
            top: 45,
            bottom: 10,
            child: FqaScrollHint(
              child: Text(
                text,
                style: const TextStyle(
                  color: FqaColors.cream,
                  fontSize: 17,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SpeakerTag(speaker: speaker),
          Positioned(
            right: 36,
            top: 38,
            child: IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              color: FqaColors.gold,
              tooltip: 'Read aloud',
              onPressed: onSpeak,
            ),
          ),
        ],
      ),
    );
  }
}
