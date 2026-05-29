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
      overlay: const FqaAssetImage(
        'backgrounds/collection_overlay.png',
        fit: BoxFit.cover,
      ),
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
              Positioned(
                left: horizontalPadding,
                top: layout.isLandscape
                    ? layout.gap(24)
                    : layout.y(49).clamp(36.0, 49.0),
                child: UtilityIcon(
                  assetName: 'icons/back_icon.png',
                  semanticLabel: 'Quay lại',
                  size: layout.s(40).clamp(36.0, 44.0),
                  onTap: controller.exitToHome,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: layout.isLandscape
                    ? layout.gap(28)
                    : layout.y(52).clamp(38.0, 52.0),
                child: Text(
                  'Bộ sưu tập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xfff0dca0),
                    fontSize: layout.font(22),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.76,
                  ),
                ),
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
