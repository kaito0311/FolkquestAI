import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class FqaScaffold extends StatelessWidget {
  const FqaScaffold({
    required this.background,
    required this.child,
    this.overlay,
    super.key,
  });

  final String background;
  final Widget child;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FqaColors.brown,
      body: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FqaAssetImage(
              background,
              fit: BoxFit.cover,
              fallback: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff36210f),
                      Color(0xff19100b),
                      Color(0xff090705),
                    ],
                  ),
                ),
              ),
            ),
            ?overlay,
            child,
          ],
        ),
      ),
    );
  }
}
