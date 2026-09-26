import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final english = controller.language.name == 'english';
    final sections = english ? _englishInformation : _vietnameseInformation;
    return FqaScaffold(
      background: 'backgrounds/collection_bg.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 61,
            landscape: 120,
          );

          return Stack(
            children: [
              _InformationHeader(
                layout: layout,
                onBack: controller.closeUtility,
              ),
              Positioned(
                top: layout.y(115).clamp(96.0, 124.0),
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: layout.s(205).clamp(160.0, 205.0),
                    height: layout.s(24).clamp(18.0, 24.0),
                    child: const FqaAssetImage('decor/tutorial_line.png'),
                  ),
                ),
              ),
              Positioned(
                top: layout.y(160).clamp(132.0, 160.0),
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: layout.gap(48),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InformationIntro(
                        layout: layout,
                        text: english
                            ? 'FolkQuest AI combines storytelling, choices, and reflection to make folktales an interactive journey.'
                            : 'FolkQuest AI kết hợp kể chuyện, lựa chọn và suy ngẫm để biến truyện dân gian thành một hành trình có thể tương tác.',
                      ),
                      SizedBox(height: layout.gap(22)),
                      _InformationSection(
                        layout: layout,
                        title: sections[0].$1,
                        body: sections[0].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _InformationSection(
                        layout: layout,
                        title: sections[1].$1,
                        body: sections[1].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _InformationSection(
                        layout: layout,
                        title: sections[2].$1,
                        body: sections[2].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _InformationSection(
                        layout: layout,
                        title: sections[3].$1,
                        body: sections[3].$2,
                      ),
                      SizedBox(height: layout.gap(16)),
                    ],
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

class _InformationIntro extends StatelessWidget {
  const _InformationIntro({required this.layout, required this.text});

  final ResponsiveLayout layout;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xffe5d4a5),
        fontSize: layout.font(14),
        height: 1.55,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({
    required this.layout,
    required this.title,
    required this.body,
  });

  final ResponsiveLayout layout;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: const Color(0xffb07d36),
            fontSize: layout.font(14),
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: layout.gap(8)),
        Text(
          body,
          style: TextStyle(
            color: const Color(0xffe5d4a5),
            fontSize: layout.font(13),
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InformationHeader extends StatelessWidget {
  const _InformationHeader({required this.layout, required this.onBack});

  final ResponsiveLayout layout;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: layout.y(28).clamp(18.0, 36.0),
      left: layout.horizontalScreenPadding(portrait: 20, landscape: 54),
      right: layout.horizontalScreenPadding(portrait: 20, landscape: 54),
      height: layout.s(72).clamp(60.0, 76.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: layout.s(10),
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: context.strings.back,
              size: layout.s(46).clamp(42.0, 48.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: Text(
              context.strings.information.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xffb07d36),
                fontSize: layout.font(30),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _vietnameseInformation = [
  (
    'FolkQuest AI',
    'Ứng dụng giúp người chơi khám phá truyện dân gian Việt Nam qua các lựa chọn tương tác, phản hồi Karma và bộ sưu tập vật phẩm.',
  ),
  (
    'Trải nghiệm',
    'Mỗi nhánh truyện được thiết kế để khuyến khích đọc chậm, suy nghĩ về hệ quả và thử lại nhiều hướng khác nhau.',
  ),
  (
    'Dữ liệu chơi',
    'Tiến trình, lựa chọn, vật phẩm đã mở khóa và cài đặt cá nhân được lưu để bạn có thể tiếp tục hành trình sau này.',
  ),
  ('Phiên bản', 'Phiên bản 1.0.0\nFQA/FolkQuest mobile experience.'),
];
const _englishInformation = [
  (
    'FolkQuest AI',
    'Explore Vietnamese folktales through interactive choices, Karma reflections, and collectible items.',
  ),
  (
    'Experience',
    'Each story branch encourages careful reading, thinking about consequences, and trying different paths.',
  ),
  (
    'Game data',
    'Your progress, choices, unlocked items, and personal settings are saved so you can continue later.',
  ),
  ('Version', 'Version 1.0.0\nFQA/FolkQuest mobile experience.'),
];
