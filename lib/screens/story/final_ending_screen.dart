import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/choice_bullet.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Kết cục của bạn',
              style: TextStyle(
                color: Color(0xffd9b86d),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ending.title,
              key: const ValueKey('ending_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xfff5da92),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 350,
                height: 175,
                child: FqaAssetImage(
                  'backgrounds/ending_image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Nghiệp lực',
                  style: TextStyle(
                    color: Color(0xffd7b66f),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FqaAssetImage('panels/karma_score_pill.png'),
                      Center(
                        child: Text(
                          controller.karma >= 0
                              ? '+${controller.karma}'
                              : '${controller.karma}',
                          style: const TextStyle(
                            color: Color(0xffefd98d),
                            fontSize: 30,
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
            const SizedBox(height: 12),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            SectionTitle('Những lựa chọn chính'),
            const SizedBox(height: 6),
            SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final choice in controller.selectedChoices.take(3))
                    ChoiceBullet(choice),
                  if (controller.selectedChoices.isEmpty)
                    const ChoiceBullet('Chưa có lựa chọn'),
                ],
              ),
            ),
            const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
            const SizedBox(height: 12),
            const SectionTitle('Cổ vật đã mở khóa'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in opened)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: FqaAssetImage(item.assetName),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            FqaImageButton(
              label: 'Chơi lại',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/ending_button.png',
              onPressed: controller.restartRun,
            ),
            const SizedBox(height: 14),
            FqaImageButton(
              label: 'Về menu chính',
              width: 238,
              height: 56,
              fontSize: 19,
              assetName: 'buttons/ending_button.png',
              onPressed: controller.exitToHome,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
