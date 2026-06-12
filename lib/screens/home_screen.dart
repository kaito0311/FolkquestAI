import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/app/fqa_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/home_bg.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final buttonWidth = layout.maxWidth(
            300,
            padding: layout.horizontalPadding(32),
          );
          final buttonHeight = layout.s(80).clamp(68.0, 80.0);
          final utilitySize = layout.s(56).clamp(48.0, 56.0);
          final utilityGap = layout.gap(24);

          return Stack(
            children: [
              Positioned(
                top: layout.y(116),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'FolkQuest',
                      style: TextStyle(
                        color: const Color(0xffffe8a6),
                        fontSize: layout.font(46),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.15,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: layout.gap(8)),
                    Text(
                      '· Ăn khế trả vàng ·',
                      style: TextStyle(
                        color: FqaColors.cream,
                        fontSize: layout.font(15),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.3,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: layout.y(502),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    FqaImageButton(
                      label: 'Bắt đầu',
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(22),
                      onPressed: controller.startOrResume,
                    ),
                    SizedBox(height: layout.gap(16)),
                    FqaImageButton(
                      label: 'Bộ sưu tập',
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(22),
                      onPressed: controller.openCollection,
                    ),
                    SizedBox(height: layout.gap(16)),
                    FqaImageButton(
                      label: 'Thành tích',
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(22),
                      onPressed: () => showPlaceholder(context, 'Thành tích'),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: layout.y(27).clamp(18.0, 27.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UtilityIcon(
                      assetName: 'icons/guide_icon.png',
                      semanticLabel: 'Hướng dẫn',
                      size: utilitySize,
                      onTap: controller.openTutorial,
                    ),
                    SizedBox(width: utilityGap),
                    UtilityIcon(
                      assetName: 'icons/settings_icon.png',
                      semanticLabel: 'Cài đặt',
                      size: utilitySize,
                      onTap: controller.openSettings,
                    ),
                    SizedBox(width: utilityGap),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        UtilityIcon(
                          assetName: controller.isSignedIn
                              ? 'icons/logout_icon.png'
                              : 'icons/login_icon.png',
                          semanticLabel: controller.isSignedIn
                              ? 'Đăng xuất'
                              : 'Đăng nhập',
                          size: utilitySize,
                          onTap: controller.authBusy
                              ? () {}
                              : () {
                                  if (controller.isSignedIn) {
                                    unawaited(_signOut(context));
                                    return;
                                  }
                                  unawaited(_signIn(context));
                                },
                        ),
                        if (controller.authBusy)
                          SizedBox(
                            width: utilitySize * 0.62,
                            height: utilitySize * 0.62,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: FqaColors.gold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    await controller.signInWithGoogle();
    if (!context.mounted || controller.authError == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(controller.authError!)));
    controller.clearAuthError();
  }

  Future<void> _signOut(BuildContext context) async {
    await controller.signOut();
    if (!context.mounted || controller.authError == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(controller.authError!)));
    controller.clearAuthError();
  }
}
