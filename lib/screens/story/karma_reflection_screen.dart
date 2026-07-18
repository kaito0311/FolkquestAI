import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scroll_hint.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_entrance.dart';

class KarmaReflectionScreen extends StatelessWidget {
  const KarmaReflectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    final variant = _KarmaReflectionVariant.fromKarma(controller.karma);
    return FqaScaffold(
      background: variant.backgroundAsset,
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
          final titleTop = layout.ceremonyTitleTop();
          final summaryTop = titleTop + titleHeight + layout.gap(20);
          final buttonBottom = layout.continuationButtonBottom();
          final buttonWidth = layout.contentWidth(238, landscapeValue: 238);
          final buttonHeight = layout.s(56).clamp(48.0, 56.0);
          final buttonGap = layout.gap(11);

          return Stack(
            children: [
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: titleTop,
                height: titleHeight,
                child: StoryEntrance(
                  key: const ValueKey('karma_title_entrance'),
                  offset: const Offset(0, -0.16),
                  delay: const Duration(milliseconds: 80),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const FqaAssetImage('panels/karma_title.png'),
                          Center(
                            child: Text(
                              context.strings.karma,
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
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: summaryTop,
                bottom:
                    buttonBottom +
                    buttonHeight * 2 +
                    buttonGap +
                    layout.gap(16),
                child: StoryEntrance(
                  key: ValueKey('karma_content_${node.id}'),
                  offset: const Offset(0, 0.1),
                  scaleBegin: 0.94,
                  delay: const Duration(milliseconds: 150),
                  child: FqaScrollHint(
                    child: Column(
                      children: [
                        SizedBox(
                          width: layout.s(224).clamp(180.0, 224.0),
                          height: layout.s(102).clamp(82.0, 102.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FqaAssetImage(
                                variant.badgeAsset,
                                key: const ValueKey('karma_badge_image'),
                              ),
                              Center(
                                child: Text(
                                  variant.scoreText(controller.karma),
                                  key: const ValueKey('karma_score_text'),
                                  style: TextStyle(
                                    color: variant.scoreColor,
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
                        if (variant.showsReflectionTitle) ...[
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
                        ] else
                          SizedBox(height: layout.gap(42)),
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
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: buttonBottom + buttonHeight + buttonGap,
                child: StoryEntrance(
                  key: const ValueKey('karma_chat_button_entrance'),
                  offset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 240),
                  child: Center(
                    child: FqaImageButton(
                      label: context.strings.askMagicBird,
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(19),
                      assetName: 'buttons/small_button.png',
                      onPressed: controller.openBirdChat,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: buttonBottom,
                child: StoryEntrance(
                  key: const ValueKey('karma_continue_button_entrance'),
                  offset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 300),
                  child: Center(
                    child: FqaImageButton(
                      label: context.strings.continueLabel,
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(19),
                      assetName: 'buttons/small_button.png',
                      onPressed: controller.advance,
                    ),
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

class _KarmaReflectionVariant {
  const _KarmaReflectionVariant({
    required this.backgroundAsset,
    required this.badgeAsset,
    required this.scoreColor,
    required this.showsReflectionTitle,
    required this.prefixPositiveSign,
  });

  final String backgroundAsset;
  final String badgeAsset;
  final Color scoreColor;
  final bool showsReflectionTitle;
  final bool prefixPositiveSign;

  String scoreText(int karma) {
    if (prefixPositiveSign && karma > 0) return '+$karma';
    return '$karma';
  }

  static _KarmaReflectionVariant fromKarma(int karma) {
    if (karma < 0) {
      return const _KarmaReflectionVariant(
        backgroundAsset: 'backgrounds/karma_bg_negative.png',
        badgeAsset: 'panels/karma_badge_negative.png',
        scoreColor: Color(0xffe0554c),
        showsReflectionTitle: true,
        prefixPositiveSign: false,
      );
    }
    if (karma == 0) {
      return const _KarmaReflectionVariant(
        backgroundAsset: 'backgrounds/karma_bg_neutral.png',
        badgeAsset: 'panels/karma_badge_neutral.png',
        scoreColor: Color(0xfff5e8c8),
        showsReflectionTitle: false,
        prefixPositiveSign: false,
      );
    }
    return const _KarmaReflectionVariant(
      backgroundAsset: 'backgrounds/karma_bg.png',
      badgeAsset: 'panels/karma_badge.png',
      scoreColor: FqaColors.gold,
      showsReflectionTitle: true,
      prefixPositiveSign: true,
    );
  }
}
