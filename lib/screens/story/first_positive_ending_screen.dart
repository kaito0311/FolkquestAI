import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';

class FirstPositiveEndingScreen extends StatelessWidget {
  const FirstPositiveEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/first_positive_ending_bg.png',
      overlay: Stack(
        fit: StackFit.expand,
        children: const [
          DecoratedBox(decoration: BoxDecoration(color: Color(0x33140f08))),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.18, 0.42, 0.68, 1],
                colors: [
                  Color(0x52090704),
                  Color(0x1f090704),
                  Color(0x14090704),
                  Color(0x42090704),
                  Color(0x9e090704),
                ],
              ),
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalPadding(30);
          final titleWidth = layout.maxWidth(250, padding: horizontalPadding);
          final panelWidth = layout.maxWidth(366, padding: horizontalPadding);
          final buttonWidth = layout.maxWidth(
            238,
            padding: horizontalPadding + 64,
          );

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: layout.y(39).clamp(28.0, 39.0)),
                SizedBox(
                  width: titleWidth,
                  height: layout.s(53).clamp(48.0, 53.0),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      const FqaAssetImage(
                        'panels/first_positive_title_frame.png',
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: layout.gap(4)),
                        child: Center(
                          child: Text(
                            'Kết thúc tốt đẹp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xfff4dda2),
                              fontSize: layout.font(15),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: panelWidth,
                  height: layout.s(220).clamp(220.0, 220.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: const FqaAssetImage(
                            'panels/first_positive_content_frame.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          layout.maxWidth(44, padding: 0),
                          layout.gap(34),
                          layout.maxWidth(44, padding: 0),
                          layout.gap(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Người biết đủ sẽ luôn nhận được những điều xứng đáng.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xfff8e9c5),
                                fontSize: layout.font(15),
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: layout.gap(12)),
                            SizedBox(
                              width: layout.maxWidth(208, padding: 0),
                              height: layout.s(24).clamp(20.0, 24.0),
                              child: const FqaAssetImage(
                                'decor/first_positive_decorative_line.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Opacity(
                                  opacity: 0.82,
                                  child: FqaImageButton(
                                    label: 'Tiếp tục',
                                    width: buttonWidth,
                                    height: layout.s(56).clamp(46.0, 56.0),
                                    fontSize: layout.font(19),
                                    assetName: 'buttons/ending_button.png',
                                    onPressed: controller.advance,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: layout.y(39).clamp(28.0, 39.0)),
              ],
            ),
          );
        },
      ),
    );
  }
}
