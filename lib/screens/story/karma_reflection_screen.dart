import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';

class KarmaReflectionScreen extends StatelessWidget {
  const KarmaReflectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    final sign = controller.karma >= 0 ? '+' : '';
    return FqaScaffold(
      background: 'backgrounds/karma_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x55080706)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 37,
            landscape: 48,
          );
          final contentWidth = layout.contentWidth(352, landscapeValue: 420);
          final titleHeight = layout.s(101).clamp(82.0, 101.0);
          final titleTop = layout.isLandscape
              ? layout.gap(28)
              : layout.y(56).clamp(32.0, 56.0);
          final summaryTop = layout.isLandscape
              ? titleTop + titleHeight + layout.gap(8)
              : layout.y(180).clamp(136.0, 180.0);
          final buttonBottom = layout.isLandscape
              ? layout.gap(28)
              : layout.y(61).clamp(28.0, 61.0);
          final buttonWidth = layout.contentWidth(238, landscapeValue: 238);
          final buttonHeight = layout.s(56).clamp(48.0, 56.0);

          return Stack(
            children: [
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: titleTop,
                height: titleHeight,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const FqaAssetImage('panels/karma_title.png'),
                        Center(
                          child: Text(
                            'Nghiệp Lực',
                            style: TextStyle(
                              color: const Color(0xfff7e4b0),
                              fontSize: layout.font(23),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: summaryTop,
                bottom: buttonBottom + buttonHeight + layout.gap(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: layout.s(224).clamp(180.0, 224.0),
                        height: layout.s(102).clamp(82.0, 102.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const FqaAssetImage('panels/karma_badge.png'),
                            Center(
                              child: Text(
                                '$sign${controller.karma}',
                                style: TextStyle(
                                  color: FqaColors.gold,
                                  fontSize: layout.font(48),
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: layout.gap(20)),
                      Text(
                        node.reflectionTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xfff2d39a),
                          fontSize: layout.font(18),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: layout.gap(16)),
                      SizedBox(
                        width: layout.contentWidth(250, landscapeValue: 420),
                        child: Text(
                          node.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xfff0d7a4),
                            fontSize: layout.font(16),
                            height: 1.78,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: buttonBottom,
                child: Center(
                  child: FqaImageButton(
                    label: 'Tiếp tục',
                    width: buttonWidth,
                    height: buttonHeight,
                    fontSize: layout.font(19),
                    assetName: 'buttons/small_button.png',
                    onPressed: controller.advance,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
