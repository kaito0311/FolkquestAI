import 'dart:async';

import 'package:flutter/material.dart';

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
                top: layout.y(150),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FolkQuest',
                          key: const ValueKey('home_title'),
                          style: TextStyle(
                            color: const Color(0xffffe8a6),
                            fontFamily: 'Georgia',
                            fontFamilyFallback: const [
                              'Times New Roman',
                              'serif',
                            ],
                            fontSize: layout.font(40),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.15,
                            height: 1,
                            shadows: _titleShadows,
                          ),
                        ),
                        SizedBox(width: layout.gap(7)),
                        Container(
                          key: const ValueKey('home_title_ai'),
                          width: layout.s(38).clamp(34.0, 38.0),
                          height: layout.s(38).clamp(34.0, 38.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff7f2418),
                            border: Border.all(
                              color: const Color.fromARGB(255, 63, 22, 17),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black87,
                                blurRadius: 2,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: const Color(0xffffe8c0),
                              fontFamily: 'Georgia',
                              fontFamilyFallback: const [
                                'Times New Roman',
                                'serif',
                              ],
                              fontSize: layout.font(23),
                              fontWeight: FontWeight.w700,
                              height: 1,
                              shadows: _titleShadows,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: layout.gap(8)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SubtitleRule(width: layout.s(30)),
                        SizedBox(width: layout.gap(8)),
                        Text(
                          'ĂN KHẾ TRẢ VÀNG',
                          key: const ValueKey('home_subtitle'),
                          style: TextStyle(
                            color: FqaColors.cream,
                            fontFamily: 'Georgia',
                            fontFamilyFallback: const [
                              'Times New Roman',
                              'serif',
                            ],
                            fontSize: layout.font(14),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.1,
                            shadows: _titleShadows,
                          ),
                        ),
                        SizedBox(width: layout.gap(8)),
                        _SubtitleRule(width: layout.s(30)),
                      ],
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
                      label: 'Hồ sơ',
                      width: buttonWidth,
                      height: buttonHeight,
                      fontSize: layout.font(22),
                      onPressed: controller.openProfile,
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

  static const _titleShadows = [
    Shadow(color: Colors.black, offset: Offset(-1, -1)),
    Shadow(color: Colors.black, offset: Offset(0, -1)),
    Shadow(color: Colors.black, offset: Offset(1, -1)),
    Shadow(color: Colors.black, offset: Offset(-1, 0)),
    Shadow(color: Colors.black, offset: Offset(1, 0)),
    Shadow(color: Colors.black, offset: Offset(-1, 1)),
    Shadow(color: Colors.black, offset: Offset(0, 1)),
    Shadow(color: Colors.black, offset: Offset(1, 1)),
  ];

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

class _SubtitleRule extends StatelessWidget {
  const _SubtitleRule({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: const Divider(
        color: Color(0xffd7ad5d),
        thickness: 1.5,
        height: 1.5,
      ),
    );
  }
}
