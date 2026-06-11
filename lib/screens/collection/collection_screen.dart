import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/collection/collectible_grid.dart';
import 'package:fqa/widgets/collection/collection_navigation.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredCollectibles().toList(growable: false);
    return FqaScaffold(
      background: 'backgrounds/collection_bg.png',
      // overlay: const FqaAssetImage(
      //   'backgrounds/collection_overlay.png',
      //   fit: BoxFit.cover,
      // ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 16,
            landscape: 56,
          );
          final gridWidth = layout.contentWidth(394, landscapeValue: 912);
          final gridTop = layout.isLandscape
              ? layout.gap(84)
              : layout.y(122).clamp(92.0, 122.0);
          final navBottom = layout.isLandscape
              ? layout.gap(20)
              : layout.y(25).clamp(18.0, 25.0);
          final navHeight = layout.s(76).clamp(64.0, 76.0);
          final noteHeight = layout.isLandscape
              ? layout.s(56).clamp(48.0, 56.0)
              : layout.s(66).clamp(56.0, 66.0);
          final noteBottom = navBottom + navHeight + layout.gap(20);
          final gridBottom = noteBottom + noteHeight + layout.gap(16);
          final navWidth = layout.contentWidth(360, landscapeValue: 360);
          final gridColumns = layout.isLandscape ? 5 : 3;

          return Stack(
            children: [
              _CollectionHeader(
                layout: layout,
                horizontalPadding: horizontalPadding,
                onBack: controller.closeCollection,
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: gridTop,
                bottom: gridBottom,
                child: Center(
                  child: SizedBox(
                    width: gridWidth,
                    child: CollectibleGrid(
                      controller: controller,
                      items: items,
                      crossAxisCount: gridColumns,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: noteBottom,
                height: noteHeight,
                child: Center(
                  child: SizedBox(
                    width: layout.contentWidth(300, landscapeValue: 420),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xe61d140b),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xff7a5a28)),
                      ),
                      child: Center(
                        child: Text(
                          'Thu thập để khám phá\ncâu chuyện và ý nghĩa ẩn giấu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xffecdba8),
                            fontSize: layout.font(12),
                            height: 1.65,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: navBottom,
                height: navHeight,
                child: Center(
                  child: SizedBox(
                    width: navWidth,
                    child: CollectionNavigation(controller: controller),
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

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.layout,
    required this.horizontalPadding,
    required this.onBack,
  });

  final ResponsiveLayout layout;
  final double horizontalPadding;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = layout.isLandscape
        ? layout.gap(24)
        : layout.y(28.765625).clamp(18.0, 28.765625);
    final height = layout.s(70.84375).clamp(60.0, 70.84375);
    final titleWidth = layout.s(284).clamp(212.0, 284.0);
    final titleScale = titleWidth / 284;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: horizontalPadding,
            top: layout.s(20).clamp(16.0, 20.0),
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: 'Quay lại',
              size: layout.s(40).clamp(36.0, 44.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: SizedBox(
              width: titleWidth,
              height: 70.84375 * titleScale,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    left: 24 * titleScale,
                    top: 4 * titleScale,
                    width: 236 * titleScale,
                    height: 17.09375 * titleScale,
                    child: const FqaAssetImage(
                      'decor/collection_title_top_line.png',
                    ),
                  ),
                  Positioned(
                    left: 12.125 * titleScale,
                    top: 31.65625 * titleScale,
                    width: 44 * titleScale,
                    height: 19.859375 * titleScale,
                    child: const FqaAssetImage(
                      'decor/collection_title_side_decor.png',
                    ),
                  ),
                  Positioned(
                    right: 12.125 * titleScale,
                    top: 31.4921875 * titleScale,
                    width: 44 * titleScale,
                    height: 20 * titleScale,
                    child: Transform.scale(
                      scaleX: -1,
                      child: const FqaAssetImage(
                        'decor/collection_title_side_decor.png',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 25.09375 * titleScale,
                    height: 33 * titleScale,
                    child: Text(
                      'Bộ sưu tập',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xfff0dca0),
                        fontSize: layout.font(22),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.76 * titleScale,
                        height: 33 / 22,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24 * titleScale,
                    top: 56.09375 * titleScale,
                    width: 236 * titleScale,
                    height: 14.75 * titleScale,
                    child: const FqaAssetImage(
                      'decor/collection_title_bottom_line.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
