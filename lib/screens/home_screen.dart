import 'package:flutter/material.dart';

import 'package:fqa/app/fqa_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/utility_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/home_bg.png',
      child: Stack(
        children: [
          const Positioned(
            top: 116,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'FolkQuest',
                  style: TextStyle(
                    color: Color(0xffffe8a6),
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.15,
                    height: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '· Ăn khế trả vàng ·',
                  style: TextStyle(
                    color: FqaColors.cream,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 502,
            left: 0,
            right: 0,
            child: Column(
              children: [
                FqaImageButton(
                  label: 'Bắt đầu',
                  onPressed: controller.startOrResume,
                ),
                const SizedBox(height: 16),
                FqaImageButton(
                  label: 'Bộ sưu tập',
                  onPressed: controller.openCollection,
                ),
                const SizedBox(height: 16),
                FqaImageButton(
                  label: 'Thành tích',
                  onPressed: () => showPlaceholder(context, 'Thành tích'),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 27,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UtilityIcon(
                  assetName: 'icons/guide_icon.png',
                  semanticLabel: 'Hướng dẫn',
                  onTap: () => showPlaceholder(context, 'Hướng dẫn'),
                ),
                const SizedBox(width: 24),
                UtilityIcon(
                  assetName: 'icons/settings_icon.png',
                  semanticLabel: 'Cài đặt',
                  onTap: () => showPlaceholder(context, 'Cài đặt'),
                ),
                const SizedBox(width: 24),
                UtilityIcon(
                  assetName: 'icons/login_icon.png',
                  semanticLabel: 'Đăng nhập',
                  onTap: () => showPlaceholder(context, 'Đăng nhập'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
