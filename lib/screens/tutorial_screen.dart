import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    'Đây là hướng dẫn của trò chơi. Hãy vui lòng đọc kỹ hướng dẫn sử dụng trước khi dùng.\n\nXin chân thành cảm ơn.',
                    style: TextStyle(
                      color: const Color(0xffe5d4a5),
                      fontSize: layout.font(14),
                      height: 2.05,
                      fontWeight: FontWeight.w700,
                    ),
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
              semanticLabel: 'Quay lại',
              size: layout.s(46).clamp(42.0, 48.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: Text(
              'HƯỚNG DẪN',
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
