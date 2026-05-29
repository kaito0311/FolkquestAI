import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';

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
      child: Stack(
        children: [
          Positioned(
            left: 37,
            right: 37,
            top: 56,
            height: 101,
            child: Stack(
              fit: StackFit.expand,
              children: const [
                FqaAssetImage('panels/karma_title.png'),
                Center(
                  child: Text(
                    'Nghiệp Lực',
                    style: TextStyle(
                      color: Color(0xfff7e4b0),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 180,
            child: Column(
              children: [
                SizedBox(
                  width: 224,
                  height: 102,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FqaAssetImage('panels/karma_badge.png'),
                      Center(
                        child: Text(
                          '$sign${controller.karma}',
                          style: const TextStyle(
                            color: FqaColors.gold,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  node.reflectionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xfff2d39a),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: Text(
                    node.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xfff0d7a4),
                      fontSize: 16,
                      height: 1.78,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 94,
            right: 94,
            bottom: 61,
            child: FqaImageButton(
              label: 'Tiếp tục',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/small_button.png',
              onPressed: controller.advance,
            ),
          ),
        ],
      ),
    );
  }
}
