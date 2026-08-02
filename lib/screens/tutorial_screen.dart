import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final english = controller.language.name == 'english';
    final sections = english ? _englishSections : _vietnameseSections;
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
              _TutorialHeader(layout: layout, onBack: controller.closeUtility),
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
                      _TutorialIntro(
                        layout: layout,
                        text: english
                            ? 'FolkQuest AI is an interactive storytelling experience: read, choose, reflect, and unlock pieces of the tale.'
                            : 'FolkQuest AI là trải nghiệm kể chuyện tương tác: bạn đọc, lựa chọn, suy ngẫm và mở khóa các mảnh ghép của truyện.',
                      ),
                      SizedBox(height: layout.gap(22)),
                      _TutorialSection(
                        layout: layout,
                        title: sections[0].$1,
                        bullets: sections[0].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _TutorialSection(
                        layout: layout,
                        title: sections[1].$1,
                        bullets: sections[1].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _TutorialSection(
                        layout: layout,
                        title: sections[2].$1,
                        bullets: sections[2].$2,
                      ),
                      SizedBox(height: layout.gap(20)),
                      _TutorialSection(
                        layout: layout,
                        title: sections[3].$1,
                        bullets: sections[3].$2,
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

class _TutorialIntro extends StatelessWidget {
  const _TutorialIntro({required this.layout, required this.text});

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

class _TutorialSection extends StatelessWidget {
  const _TutorialSection({
    required this.layout,
    required this.title,
    required this.bullets,
  });

  final ResponsiveLayout layout;
  final String title;
  final List<String> bullets;

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
        for (final bullet in bullets) ...[
          _TutorialBullet(layout: layout, text: bullet),
          SizedBox(height: layout.gap(8)),
        ],
      ],
    );
  }
}

class _TutorialBullet extends StatelessWidget {
  const _TutorialBullet({required this.layout, required this.text});

  final ResponsiveLayout layout;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: layout.font(7)),
          child: Icon(
            Icons.diamond,
            color: const Color(0xffb07d36),
            size: layout.s(8).clamp(6.0, 9.0),
          ),
        ),
        SizedBox(width: layout.s(9).clamp(7.0, 10.0)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xffe5d4a5),
              fontSize: layout.font(13),
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TutorialHeader extends StatelessWidget {
  const _TutorialHeader({required this.layout, required this.onBack});

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
              context.strings.guide.toUpperCase(),
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

const _vietnameseSections = [
  (
    'Mục tiêu',
    [
      'Theo dõi câu chuyện dân gian và chọn cách nhân vật phản ứng trong từng tình huống.',
      'Mỗi lựa chọn có thể thay đổi Karma, mở nhánh truyện mới và dẫn tới kết thúc khác nhau.',
    ],
  ),
  (
    'Cách chơi',
    [
      'Chạm “Tiếp tục” để đọc lời thoại và tiến qua các cảnh.',
      'Khi màn hình lựa chọn xuất hiện, đọc kỹ lời dẫn rồi chọn phương án bạn muốn thử.',
      'Sau một nhánh kết thúc, hãy xem màn hình Karma để hiểu điều lựa chọn vừa phản ánh.',
    ],
  ),
  (
    'Vật phẩm sưu tầm',
    [
      'Hoàn thành một số nhánh truyện sẽ mở khóa vật phẩm trong Bộ sưu tập.',
      'Bạn có thể quay lại trang Bộ sưu tập để xem vật phẩm, kết thúc đã gặp và tiến trình của mình.',
    ],
  ),
  (
    'Mẹo nhỏ',
    [
      'Không có lựa chọn duy nhất đúng. Hãy thử nhiều hướng để thấy câu chuyện thay đổi ra sao.',
      'Dùng nút tạm dừng để mở cài đặt, hướng dẫn hoặc quay về màn hình chính khi cần.',
    ],
  ),
];
const _englishSections = [
  (
    'Goal',
    [
      'Follow the folktale and choose how the character responds in each situation.',
      'Each choice can change Karma, unlock story branches, and lead to different endings.',
    ],
  ),
  (
    'How to play',
    [
      'Tap “Continue” to read dialogue and move through scenes.',
      'When choices appear, read the prompt and select the option you want to try.',
      'After an ending, view the Karma screen to understand what your choice reflects.',
    ],
  ),
  (
    'Collectibles',
    [
      'Completing story branches unlocks items in the Collection.',
      'Return to the Collection to view items, endings you have found, and your progress.',
    ],
  ),
  (
    'Tip',
    [
      'There is no single correct choice. Try different paths to see how the story changes.',
      'Use Pause to open settings, this guide, or return to the main screen.',
    ],
  ),
];
