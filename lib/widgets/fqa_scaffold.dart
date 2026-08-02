import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class FqaScaffold extends StatelessWidget {
  const FqaScaffold({
    required this.background,
    required this.child,
    this.overlay,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final String background;
  final Widget child;
  final Widget? overlay;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FqaColors.brown,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FqaAssetImage(
              background,
              key: const ValueKey('fqa_scaffold_background_image'),
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
            _SafeContentPadding(child: child),
          ],
        ),
      ),
    );
  }
}

class _SafeContentPadding extends StatelessWidget {
  const _SafeContentPadding({required this.child});

  static const _designedTopClearance = 28.0;
  static const _designedBottomClearance = 24.0;
  static const _designedSideClearance = 16.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: _extraPaddingFor(viewPadding.left, _designedSideClearance),
        top: _extraPaddingFor(viewPadding.top, _designedTopClearance),
        right: _extraPaddingFor(viewPadding.right, _designedSideClearance),
        bottom: _extraPaddingFor(viewPadding.bottom, _designedBottomClearance),
      ),
      child: child,
    );
  }

  double _extraPaddingFor(double safeInset, double designedClearance) {
    final extra = safeInset - designedClearance;
    return extra > 0 ? extra : 0;
  }
}
