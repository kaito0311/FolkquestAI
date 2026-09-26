import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/utility_icon.dart';
import 'package:fqa/widgets/story_entrance.dart';

class StoryTopBar extends StatelessWidget {
  const StoryTopBar({
    required this.title,
    required this.onBack,
    required this.onPause,
    this.animateEntrance = true,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final bool animateEntrance;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      left: 12,
      right: 12,
      height: 128,
      child: animateEntrance
          ? StoryEntrance(
              key: ValueKey('story_top_$title'),
              offset: const Offset(0, -0.22),
              delay: const Duration(milliseconds: 60),
              child: _content(),
            )
          : _content(),
    );
  }

  Widget _content() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = (constraints.maxHeight * 0.36).clamp(42.0, 48.0);
        final iconTop = (constraints.maxHeight - iconSize) * 0.45;
        final titleTop = (constraints.maxHeight - iconSize) * 0.17;
        final plaqueSideGap = iconSize + 18;
        final plaqueWidth = (constraints.maxWidth - plaqueSideGap * 2).clamp(
          0.0,
          240.0,
        );
        final plaqueHeight = plaqueWidth * 127 / 240;
        final plaqueTop = -(constraints.maxHeight * 0.08).clamp(10.0, 14.0);
        final isEnglish = Localizations.localeOf(context).languageCode == 'en';
        final titleFontSize =
            (constraints.maxHeight * (isEnglish ? 0.16 : 0.16)).clamp(
              isEnglish ? 18.0 : 18.0,
              isEnglish ? 20.0 : 20.0,
            );

        return Stack(
          children: [
            Positioned(
              top: iconTop,
              left: 0,
              child: UtilityIcon(
                assetName: 'icons/back_icon.png',
                semanticLabel: 'Quay lại',
                size: iconSize,
                onTap: onBack,
              ),
            ),
            Positioned(
              top: plaqueTop,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: plaqueWidth,
                  height: plaqueHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FqaAssetImage('panels/title_plaque.png'),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: titleTop),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FqaColors.cream,
                              fontFamily: 'Roboto',
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
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
              top: iconTop,
              right: 0,
              child: UtilityIcon(
                assetName: 'icons/pause_icon.png',
                semanticLabel: 'Tạm dừng',
                size: iconSize,
                onTap: onPause,
              ),
            ),
          ],
        );
      },
    );
  }
}
