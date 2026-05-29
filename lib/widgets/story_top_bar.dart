import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/utility_icon.dart';

class StoryTopBar extends StatelessWidget {
  const StoryTopBar({
    required this.title,
    required this.onBack,
    required this.onPause,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      left: 12,
      right: 12,
      height: 128,
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: 'Quay lại',
              size: 48,
              onTap: onBack,
            ),
          ),
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 240,
                height: 127,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const FqaAssetImage('panels/title_plaque.png'),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: FqaColors.cream,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: UtilityIcon(
              assetName: 'icons/pause_icon.png',
              semanticLabel: 'Tạm dừng',
              size: 48,
              onTap: onPause,
            ),
          ),
        ],
      ),
    );
  }
}
