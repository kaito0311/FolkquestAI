import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class UtilityIcon extends StatelessWidget {
  const UtilityIcon({
    required this.assetName,
    required this.semanticLabel,
    required this.onTap,
    this.size = 56,
    super.key,
  });

  final String assetName;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: InkWell(
        key: ValueKey('icon_$semanticLabel'),
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: FqaAssetImage(
            assetName,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff2d1b0d),
                border: Border.all(color: const Color(0xff8b6a2e)),
              ),
              child: Center(
                child: Icon(
                  semanticLabel == 'Quay lại'
                      ? Icons.arrow_back
                      : semanticLabel == 'Tạm dừng'
                      ? Icons.pause
                      : semanticLabel == 'Đóng'
                      ? Icons.close
                      : Icons.auto_awesome,
                  color: FqaColors.gold,
                  size: size * 0.48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
