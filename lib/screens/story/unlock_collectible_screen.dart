import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scroll_hint.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_entrance.dart';

class UnlockCollectibleScreen extends StatelessWidget {
  const UnlockCollectibleScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final collectibles = StoryRepository.collectiblesFor(controller.language);
    final collectible = collectibles.firstWhere(
      (item) => item.id == controller.currentNode.unlockCollectibleId,
      orElse: () => collectibles.first,
    );
    return FqaScaffold(
      background: 'backgrounds/unlock_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xbb070504)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 40,
            landscape: 56,
          );
          final artSize = layout.isLandscape
              ? layout.s(180).clamp(132.0, 180.0)
              : layout.s(208).clamp(160.0, 208.0);
          final titleTop = layout.ceremonyTitleTop();
          final artTop = layout.isLandscape
              ? layout.gap(70)
              : layout.y(106).clamp(82.0, 106.0);
          final textTop = artTop + artSize + layout.gap(22);
          final buttonBottom = layout.continuationButtonBottom();
          final buttonWidth = layout.contentWidth(238, landscapeValue: 238);
          final buttonHeight = layout.s(56).clamp(48.0, 56.0);

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: titleTop,
                child: StoryEntrance(
                  key: ValueKey('unlock_title_${collectible.id}'),
                  offset: const Offset(0, -0.14),
                  delay: const Duration(milliseconds: 80),
                  child: Text(
                    context.strings.unlocked,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xfff4d88f),
                      fontSize: layout.font(18),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.44,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: artTop,
                child: StoryEntrance(
                  key: ValueKey('unlock_art_${collectible.id}'),
                  offset: const Offset(0, 0.06),
                  scaleBegin: 0.72,
                  delay: const Duration(milliseconds: 180),
                  duration: const Duration(milliseconds: 520),
                  child: Center(
                    child: SizedBox(
                      width: artSize,
                      height: artSize,
                      child: SizedBox.square(
                        dimension: artSize * 0.72,
                        child: FqaAssetImage(
                          collectible.assetName,
                          fallback: Icon(
                            Icons.auto_awesome,
                            color: FqaColors.gold,
                            size: artSize * 0.58,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: textTop,
                bottom: buttonBottom + buttonHeight * 2 + layout.gap(30),
                child: StoryEntrance(
                  key: ValueKey('unlock_description_${collectible.id}'),
                  offset: const Offset(0, 0.1),
                  delay: const Duration(milliseconds: 300),
                  child: FqaScrollHint(
                    child: Column(
                      children: [
                        Text(
                          collectible.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xffefcf86),
                            fontSize: layout.font(30),
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: layout.gap(18)),
                        SizedBox(
                          width: layout.contentWidth(258, landscapeValue: 520),
                          child: Text(
                            collectible.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xffe7d3a2),
                              fontSize: layout.font(16),
                              height: 2,
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
                bottom: buttonBottom,
                child: Column(
                  children: [
                    FqaImageButton(
                      label: context.strings.viewCollection,
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(19),
                      assetName: 'buttons/unlock_button.png',
                      onPressed: () => controller.continueFromUnlock(
                        openCollectionFirst: true,
                      ),
                    ),
                    SizedBox(height: layout.gap(14)),
                    FqaImageButton(
                      label: context.strings.continueLabel,
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(19),
                      assetName: 'buttons/unlock_button.png',
                      onPressed: controller.continueFromUnlock,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
