import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/choice_bullet.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/section_title.dart';

class FinalEndingScreen extends StatelessWidget {
  const FinalEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ending = controller.currentEnding;
    final opened = StoryRepository.collectibles
        .where(controller.isUnlocked)
        .take(3)
        .toList(growable: false);
    return FqaScaffold(
      background: 'backgrounds/ending_bg.png',
      overlay: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xdd080604)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalPadding(20);
          final imageWidth = layout.maxWidth(350, padding: horizontalPadding);
          final collectibleSize = ((imageWidth - 18) / 3).clamp(82.0, 100.0);
          final buttonWidth = layout.maxWidth(238, padding: horizontalPadding);
          final buttonHeight = layout.s(56).clamp(50.0, 56.0);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      SizedBox(height: layout.gap(12)),
                      Text(
                        'Kết cục của bạn',
                        style: TextStyle(
                          color: const Color(0xffd9b86d),
                          fontSize: layout.font(14),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.12,
                        ),
                      ),
                      SizedBox(height: layout.gap(16)),
                      Text(
                        ending.title,
                        key: const ValueKey('ending_title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xfff5da92),
                          fontSize: layout.font(22),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: layout.gap(20)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: imageWidth,
                          height: imageWidth * 0.5,
                          child: const FqaAssetImage(
                            'backgrounds/ending_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: layout.gap(12)),
                      const FqaAssetImage(
                        'decor/divider.png',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: layout.gap(12)),
                      Row(
                        children: [
                          Text(
                            'Nghiệp lực',
                            style: TextStyle(
                              color: const Color(0xffd7b66f),
                              fontSize: layout.font(18),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: layout.s(100).clamp(88.0, 100.0),
                            height: layout.s(40).clamp(36.0, 40.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                const FqaAssetImage(
                                  'panels/karma_score_pill.png',
                                ),
                                Center(
                                  child: Text(
                                    controller.karma >= 0
                                        ? '+${controller.karma}'
                                        : '${controller.karma}',
                                    style: TextStyle(
                                      color: const Color(0xffefd98d),
                                      fontSize: layout.font(30),
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: layout.gap(12)),
                      const FqaAssetImage(
                        'decor/divider.png',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: layout.gap(12)),
                      const SectionTitle('Những lựa chọn chính'),
                      SizedBox(height: layout.gap(6)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final choice
                                in controller.selectedChoices.take(3))
                              ChoiceBullet(choice),
                            if (controller.selectedChoices.isEmpty)
                              const ChoiceBullet('Chưa có lựa chọn'),
                          ],
                        ),
                      ),
                      const FqaAssetImage(
                        'decor/divider.png',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: layout.gap(12)),
                      const SectionTitle('Cổ vật đã mở khóa'),
                      SizedBox(height: layout.gap(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final item in opened)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: SizedBox(
                                width: collectibleSize,
                                height: collectibleSize,
                                child: FqaAssetImage(item.assetName),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: layout.gap(18)),
                      FqaImageButton(
                        label: 'Chơi lại',
                        width: buttonWidth,
                        height: buttonHeight,
                        fontSize: layout.font(19),
                        assetName: 'buttons/ending_button.png',
                        onPressed: controller.restartRun,
                      ),
                      SizedBox(height: layout.gap(14)),
                      FqaImageButton(
                        label: 'Về menu chính',
                        width: buttonWidth,
                        height: buttonHeight,
                        fontSize: layout.font(19),
                        assetName: 'buttons/ending_button.png',
                        onPressed: controller.exitToHome,
                      ),
                      SizedBox(height: layout.gap(18)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
