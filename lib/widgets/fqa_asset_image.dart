import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_assets.dart';

class FqaAssetImage extends StatelessWidget {
  const FqaAssetImage(
    this.assetName, {
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.centerSlice,
    this.fallback,
    super.key,
  });

  final String assetName;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Rect? centerSlice;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      FqaAssets.image(assetName),
      fit: fit,
      alignment: alignment,
      centerSlice: centerSlice,
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff33200f),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff8b6a2e)),
              ),
            );
      },
    );
  }
}
