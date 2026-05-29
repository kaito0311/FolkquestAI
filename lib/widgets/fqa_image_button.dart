import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class FqaImageButton extends StatelessWidget {
  const FqaImageButton({
    required this.label,
    required this.onPressed,
    this.assetName = 'buttons/primary_button.png',
    this.width = 300,
    this.height = 80,
    this.fontSize = 22,
    this.letterSpacing,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final String assetName;
  final double width;
  final double height;
  final double fontSize;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        key: ValueKey('button_$label'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: FqaColors.cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            FqaAssetImage(assetName, fit: BoxFit.fill),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FqaColors.cream,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  height: 1.2,
                  letterSpacing: letterSpacing,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
