import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';

class FirstPositiveEndingScreen extends StatelessWidget {
  const FirstPositiveEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/ending_bg.png',
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 39),
            SizedBox(
              width: 250,
              height: 53,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: const [
                  FqaAssetImage('panels/title_plaque.png', fit: BoxFit.fill),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Center(
                      child: Text(
                        'Kết thúc tốt đẹp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xfff4dda2),
                          fontSize: 15,
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
              width: 366,
              height: 220,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: const FqaAssetImage(
                        'panels/dialog_panel.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 44,
                    top: 35,
                    child: SizedBox(
                      width: 278,
                      child: Text(
                        'Người biết đủ sẽ luôn nhận được những điều xứng đáng.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xfff8e9c5),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 79,
                    top: 90,
                    child: SizedBox(
                      width: 208,
                      height: 24,
                      child: FqaAssetImage('decor/divider.png'),
                    ),
                  ),
                  Positioned(
                    left: 64,
                    top: 136,
                    child: Opacity(
                      opacity: 0.82,
                      child: FqaImageButton(
                        label: 'Tiếp tục',
                        width: 238,
                        height: 56,
                        fontSize: 19,
                        assetName: 'buttons/ending_button.png',
                        onPressed: controller.advance,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 39),
          ],
        ),
      ),
    );
  }
}
