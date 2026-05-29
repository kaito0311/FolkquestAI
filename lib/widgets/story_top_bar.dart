import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/responsive_layout.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final iconSize = layout.s(48).clamp(42.0, 48.0);
          final iconTop = layout.m(48);
          final plaqueWidth = layout.maxWidth(
            240,
            padding: iconSize + layout.gap(18),
          );
          final plaqueHeight = plaqueWidth * 127 / 240;

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
                top: -layout.gap(14),
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
                            padding: EdgeInsets.only(top: iconTop),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: FqaColors.cream,
                                fontSize: layout.font(20),
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
      ),
    );
  }
}
