import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/collection/collectible_grid.dart';
import 'package:fqa/widgets/collection/collection_navigation.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
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
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 49,
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: 'Quay lại',
              size: 40,
              onTap: controller.exitToHome,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 52,
            child: Text(
              'Bộ sưu tập',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff0dca0),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.76,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 122,
            bottom: 172,
            child: CollectibleGrid(controller: controller, items: items),
          ),
          Positioned(
            left: 63,
            right: 63,
            bottom: 172,
            height: 66,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xe61d140b),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff7a5a28)),
              ),
              child: const Center(
                child: Text(
                  'Thu thập để khám phá\ncâu chuyện và ý nghĩa ẩn giấu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffecdba8),
                    fontSize: 12,
                    height: 1.65,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 33,
            right: 33,
            bottom: 25,
            height: 76,
            child: CollectionNavigation(controller: controller),
          ),
        ],
      ),
    );
  }
}
