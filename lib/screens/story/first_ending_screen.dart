import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_scroll_hint.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_entrance.dart';

class FirstEndingScreen extends StatelessWidget {
  const FirstEndingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;
    return FqaScaffold(
      background: node.background ?? 'backgrounds/first_positive_ending_bg.png',
      overlay: const _FirstEndingOverlay(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalPadding(30);
          final titleTop = layout.ceremonyTitleTop();
          final dialogBottom = layout.isLandscape
              ? layout.gap(28)
              : layout.y(61).clamp(28.0, 61.0);

          return Stack(
            children: [
              _FirstEndingTitle(
                title: node.title,
                layout: layout,
                top: titleTop,
                horizontalPadding: horizontalPadding,
              ),
              _FirstEndingDialog(
                quote: node.text,
                layout: layout,
                bottom: dialogBottom,
                horizontalPadding: horizontalPadding,
                onContinue: controller.advance,
                onSpeak: controller.speakCurrentStoryText,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FirstEndingOverlay extends StatelessWidget {
  const _FirstEndingOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}

class _FirstEndingTitle extends StatelessWidget {
  const _FirstEndingTitle({
    required this.title,
    required this.layout,
    required this.top,
    required this.horizontalPadding,
  });

  final String title;
  final ResponsiveLayout layout;
  final double top;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final width = layout.maxWidth(250, padding: horizontalPadding);
    final height = layout.s(53).clamp(48.0, 53.0);

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      top: top,
      child: StoryEntrance(
        key: ValueKey('first_ending_title_$title'),
        offset: const Offset(0, -0.18),
        delay: const Duration(milliseconds: 100),
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
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
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xfff4dda2),
                        fontSize: layout.font(21),
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
        ),
      ),
    );
  }
}

class _FirstEndingDialog extends StatelessWidget {
  const _FirstEndingDialog({
    required this.quote,
    required this.layout,
    required this.bottom,
    required this.horizontalPadding,
    required this.onContinue,
    required this.onSpeak,
  });

  final String quote;
  final ResponsiveLayout layout;
  final double bottom;
  final double horizontalPadding;
  final VoidCallback onContinue;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final width = layout.maxWidth(366, padding: horizontalPadding);
    final height = layout.isLandscape
        ? layout.s(260).clamp(220.0, 280.0)
        : layout.s(280).clamp(240.0, 300.0);
    final buttonWidth = layout.maxWidth(238, padding: horizontalPadding + 64);
    final buttonHeight = layout.s(56).clamp(48.0, 56.0);

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: bottom,
      child: StoryEntrance(
        key: ValueKey('first_ending_dialog_$quote'),
        offset: const Offset(0, 0.15),
        delay: const Duration(milliseconds: 180),
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const FqaAssetImage(
                      'panels/first_positive_content_frame.png',
                      fit: BoxFit.fill,
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
                      Expanded(
                        child: FqaScrollHint(
                          child: _FirstEndingQuote(text: quote, layout: layout),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        color: const Color(0xfff4dda2),
                        tooltip: 'Read aloud',
                        onPressed: onSpeak,
                      ),
                      SizedBox(height: layout.gap(2)),
                      _FirstEndingDecorativeLine(layout: layout),
                      SizedBox(height: layout.gap(6)),
                      _FirstEndingContinueButton(
                        width: buttonWidth,
                        height: buttonHeight,
                        fontSize: layout.font(19),
                        onPressed: onContinue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstEndingQuote extends StatelessWidget {
  const _FirstEndingQuote({required this.text, required this.layout});

  final String text;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xfff8e9c5),
        fontSize: layout.font(15),
        fontWeight: FontWeight.w600,
        height: 1.6,
      ),
    );
  }
}

class _FirstEndingDecorativeLine extends StatelessWidget {
  const _FirstEndingDecorativeLine({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.maxWidth(208, padding: 0),
      height: layout.s(24).clamp(20.0, 24.0),
      child: const FqaAssetImage(
        'decor/first_positive_decorative_line.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _FirstEndingContinueButton extends StatelessWidget {
  const _FirstEndingContinueButton({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.onPressed,
  });

  final double width;
  final double height;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.82,
      child: FqaImageButton(
        label: context.strings.continueLabel,
        width: width,
        height: height,
        fontSize: fontSize,
        assetName: 'buttons/ending_button.png',
        onPressed: onPressed,
      ),
    );
  }
}
