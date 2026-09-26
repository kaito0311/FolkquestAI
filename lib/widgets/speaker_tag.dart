import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class SpeakerTag extends StatelessWidget {
  const SpeakerTag({required this.speaker, super.key});

  final String speaker;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 30,
      top: 0,
      width: 200,
      height: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage('panels/speaker_tag.png', fit: BoxFit.fill),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                speaker,
                style: const TextStyle(
                  color: FqaColors.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
