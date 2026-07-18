import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/choice_bullet.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scroll_hint.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/section_title.dart';
import 'package:fqa/widgets/story_entrance.dart';

class FinalEndingScreen extends StatelessWidget {
  const FinalEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ending = controller.currentEnding;
    final opened = StoryRepository.collectiblesFor(controller.language)
        .where(
          (collectible) =>
              controller.runUnlockedCollectibleIds.contains(collectible.id),
        )
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
          final buttonBottom = layout.isLandscape
              ? layout.gap(24)
              : layout.y(31).clamp(24.0, 31.0);
          final buttonWidth = layout.contentWidth(238, landscapeValue: 238);
          final buttonHeight = layout.s(56).clamp(48.0, 56.0);
          final actionHeight = buttonHeight * 2 + layout.gap(14);
          final contentBottom = buttonBottom + actionHeight + layout.gap(24);
          final titleTop = layout.ceremonyTitleTop();

          return Stack(
            children: [
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 0,
                bottom: contentBottom,
                child: StoryEntrance(
                  key: ValueKey('final_ending_content_${ending.id}'),
                  offset: const Offset(0, 0.08),
                  scaleBegin: 0.97,
                  delay: const Duration(milliseconds: 140),
                  duration: const Duration(milliseconds: 520),
                  child: _FinalEndingContent(
                    ending: ending,
                    coverBackground:
                        controller.currentNode.background ??
                        'backgrounds/first_positive_ending_bg.png',
                    coverAlignment: Alignment(
                      controller.currentNode.coverAlignmentX,
                      controller.currentNode.coverAlignmentY,
                    ),
                    karma: controller.karma,
                    selectedChoices: controller.selectedChoices,
                    unlockedCollectibles: opened,
                    layout: layout,
                    horizontalPadding: horizontalPadding,
                    topPadding: titleTop,
                  ),
                ),
              ),
              _FinalEndingActions(
                layout: layout,
                bottom: buttonBottom,
                width: buttonWidth,
                height: buttonHeight,
                onPlayAgain: controller.restartRun,
                onBackToMenu: controller.exitToHome,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FinalEndingContent extends StatelessWidget {
  const _FinalEndingContent({
    required this.ending,
    required this.coverBackground,
    required this.coverAlignment,
    required this.karma,
    required this.selectedChoices,
    required this.unlockedCollectibles,
    required this.layout,
    required this.horizontalPadding,
    required this.topPadding,
  });

  final Ending ending;
  final String coverBackground;
  final AlignmentGeometry coverAlignment;
  final int karma;
  final List<String> selectedChoices;
  final List<Collectible> unlockedCollectibles;
  final ResponsiveLayout layout;
  final double horizontalPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return FqaScrollHint(
      child: Column(
        children: [
          SizedBox(height: topPadding),
          _FinalEndingTitles(ending: ending, layout: layout),
          SizedBox(height: layout.gap(20)),
          _FinalEndingCover(
            background: coverBackground,
            alignment: coverAlignment,
            layout: layout,
            horizontalPadding: horizontalPadding,
          ),
          SizedBox(height: layout.gap(12)),
          _FinalEndingDivider(
            layout: layout,
            horizontalPadding: horizontalPadding,
          ),
          SizedBox(height: layout.gap(12)),
          _FinalEndingKarma(karma: karma, layout: layout),
          SizedBox(height: layout.gap(12)),
          _FinalEndingDivider(
            layout: layout,
            horizontalPadding: horizontalPadding,
          ),
          SizedBox(height: layout.gap(12)),
          _FinalEndingChoices(choices: selectedChoices),
          SizedBox(height: layout.gap(10)),
          _FinalEndingDivider(
            layout: layout,
            horizontalPadding: horizontalPadding,
          ),
          SizedBox(height: layout.gap(12)),
          _FinalEndingUnlockedCollection(
            items: unlockedCollectibles,
            layout: layout,
            horizontalPadding: horizontalPadding,
          ),
          SizedBox(height: layout.gap(18)),
        ],
      ),
    );
  }
}

class _FinalEndingTitles extends StatelessWidget {
  const _FinalEndingTitles({required this.ending, required this.layout});

  final Ending ending;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}

class _FinalEndingCover extends StatelessWidget {
  const _FinalEndingCover({
    required this.background,
    required this.alignment,
    required this.layout,
    required this.horizontalPadding,
  });

  final String background;
  final AlignmentGeometry alignment;
  final ResponsiveLayout layout;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final width = layout.maxWidth(350, padding: horizontalPadding);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: width * 0.5,
        child: FqaAssetImage(
          background,
          key: const ValueKey('final_ending_cover_image'),
          fit: BoxFit.cover,
          alignment: alignment,
        ),
      ),
    );
  }
}

class _FinalEndingKarma extends StatelessWidget {
  const _FinalEndingKarma({required this.karma, required this.layout});

  final int karma;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              FqaAssetImage(
                karma >= 0
                    ? 'panels/karma_score_pill.png'
                    : 'panels/red_score.png',
                key: const ValueKey('final_ending_karma_score_image'),
              ),
              Center(
                child: Text(
                  karma >= 0 ? '+$karma' : '$karma',
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
    );
  }
}

class _FinalEndingChoices extends StatelessWidget {
  const _FinalEndingChoices({required this.choices});

  final List<String> choices;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Những lựa chọn chính'),
          const SizedBox(height: 6),
          for (final choice in choices.take(3)) ChoiceBullet(choice),
          if (choices.isEmpty) const ChoiceBullet('Chưa có lựa chọn'),
        ],
      ),
    );
  }
}

class _FinalEndingUnlockedCollection extends StatelessWidget {
  const _FinalEndingUnlockedCollection({
    required this.items,
    required this.layout,
    required this.horizontalPadding,
  });

  final List<Collectible> items;
  final ResponsiveLayout layout;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final coverWidth = layout.maxWidth(350, padding: horizontalPadding);
    final itemSize = ((coverWidth - 18) / 3).clamp(82.0, 100.0);

    return Column(
      children: [
        const SectionTitle('Cổ vật đã mở khóa'),
        SizedBox(height: layout.gap(8)),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              key: const ValueKey('ending_unlocked_scroll'),
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: SizedBox(
                          width: itemSize,
                          height: itemSize,
                          child: FqaAssetImage(
                            item.assetName,
                            key: ValueKey('ending_unlocked_${item.id}'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FinalEndingActions extends StatelessWidget {
  const _FinalEndingActions({
    required this.layout,
    required this.bottom,
    required this.width,
    required this.height,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  final ResponsiveLayout layout;
  final double bottom;
  final double width;
  final double height;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Column(
        children: [
          FqaImageButton(
            label: 'Chơi lại',
            width: width,
            height: height,
            fontSize: layout.font(19),
            assetName: 'buttons/ending_button.png',
            onPressed: onPlayAgain,
          ),
          SizedBox(height: layout.gap(14)),
          FqaImageButton(
            label: 'Về menu chính',
            width: width,
            height: height,
            fontSize: layout.font(19),
            assetName: 'buttons/ending_button.png',
            onPressed: onBackToMenu,
          ),
        ],
      ),
    );
  }
}

class _FinalEndingDivider extends StatelessWidget {
  const _FinalEndingDivider({
    required this.layout,
    required this.horizontalPadding,
  });

  final ResponsiveLayout layout;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.x(200).clamp(100, 300),
      height: layout.s(18).clamp(12.0, 18.0),
      child: const FqaAssetImage('decor/divider.png', fit: BoxFit.contain),
    );
  }
}
