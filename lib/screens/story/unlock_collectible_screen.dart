import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';

class UnlockCollectibleScreen extends StatelessWidget {
  const UnlockCollectibleScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final collectible = StoryRepository.collectibles.firstWhere(
      (item) => item.id == controller.currentNode.unlockCollectibleId,
      orElse: () => StoryRepository.collectibles.first,
    );
    return FqaScaffold(
      background: 'backgrounds/unlock_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xbb070504)),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 39,
            child: Text(
              'Đã mở khóa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff4d88f),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.44,
              ),
            ),
          ),
          Positioned(
            left: 109,
            right: 109,
            top: 106,
            height: 208,
            child: FqaAssetImage(
              collectible.assetName,
              fallback: const Icon(
                Icons.auto_awesome,
                color: FqaColors.gold,
                size: 120,
              ),
            ),
          ),
          Positioned(
            left: 40,
            right: 40,
            top: 338,
            child: Text(
              collectible.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xffefcf86),
                fontSize: 30,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: 84,
            right: 84,
            top: 399,
            child: Text(
              collectible.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xffe7d3a2),
                fontSize: 16,
                height: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 94,
            right: 94,
            bottom: 31,
            child: Column(
              children: [
                FqaImageButton(
                  label: 'Xem bộ sưu tập',
                  width: 238,
                  height: 56,
                  fontSize: 19,
                  assetName: 'buttons/unlock_button.png',
                  onPressed: () =>
                      controller.continueFromUnlock(openCollectionFirst: true),
                ),
                const SizedBox(height: 14),
                FqaImageButton(
                  label: 'Tiếp tục',
                  width: 238,
                  height: 56,
                  fontSize: 19,
                  assetName: 'buttons/unlock_button.png',
                  onPressed: controller.continueFromUnlock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
