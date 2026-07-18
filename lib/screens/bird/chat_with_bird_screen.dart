import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_pressable.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_top_bar.dart';

class ChatWithBirdScreen extends StatefulWidget {
  const ChatWithBirdScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ChatWithBirdScreen> createState() => _ChatWithBirdScreenState();
}

class _ChatWithBirdScreenState extends State<ChatWithBirdScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit(String question) async {
    _messageController.clear();
    final submitted = await widget.controller.submitBirdQuestion(question);
    if (!mounted) return;
    if (!submitted) _messageController.text = question;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return FqaScaffold(
      background: 'backgrounds/bird_chat_bg.png',
      overlay: const _BirdScreenOverlay(),
      resizeToAvoidBottomInset: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.portraitOf(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 27,
            landscape: 56,
          );
          final contentWidth = layout.contentWidth(372, landscapeValue: 480);
          final inputBottom =
              MediaQuery.viewInsetsOf(context).bottom + layout.gap(20);
          final inputHeight = layout.s(52).clamp(46.0, 52.0);
          final panelTop = layout.isLandscape
              ? layout.y(216).clamp(150.0, 232.0)
              : layout.y(489).clamp(360.0, 489.0);

          return Stack(
            children: [
              StoryTopBar(
                title: strings.magicBird,
                onBack: widget.controller.closeBirdChat,
                onPause: widget.controller.showPause,
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: panelTop,
                bottom: inputBottom + inputHeight + layout.gap(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _BirdGreeting(layout: layout),
                          SizedBox(height: layout.gap(12)),
                          for (final question
                              in strings.birdPresetQuestions) ...[
                            _PresetQuestionButton(
                              label: question,
                              layout: layout,
                              onTap: () => _submit(question),
                            ),
                            SizedBox(height: layout.gap(8)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: layout.horizontalScreenPadding(
                  portrait: 30,
                  landscape: 72,
                ),
                right: layout.horizontalScreenPadding(
                  portrait: 30,
                  landscape: 72,
                ),
                bottom: inputBottom,
                height: inputHeight,
                child: _BirdMessageInput(
                  controller: _messageController,
                  layout: layout,
                  onSubmit: _submit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BirdGreeting extends StatelessWidget {
  const _BirdGreeting({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(123).clamp(104.0, 132.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage('panels/bird_intro_panel.png', fit: BoxFit.fill),
          Padding(
            padding: EdgeInsets.fromLTRB(
              layout.s(32),
              layout.s(18),
              layout.s(28),
              layout.s(16),
            ),
            child: Text(
              context.strings.birdGreeting,
              style: TextStyle(
                color: const Color(0xffd4b072),
                fontSize: layout.font(18),
                height: 1.22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetQuestionButton extends StatelessWidget {
  const _PresetQuestionButton({
    required this.label,
    required this.layout,
    required this.onTap,
  });

  final String label;
  final ResponsiveLayout layout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(55).clamp(48.0, 58.0),
      child: FqaPressable(
        key: ValueKey('bird_preset_$label'),
        borderRadius: 6,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const FqaAssetImage(
              'buttons/preset_question.png',
              fit: BoxFit.fill,
            ),
            Padding(
              padding: EdgeInsets.only(left: layout.s(32), right: layout.s(44)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xffd4b072),
                        fontSize: layout.font(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirdMessageInput extends StatelessWidget {
  const _BirdMessageInput({
    required this.controller,
    required this.layout,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final ResponsiveLayout layout;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff1c150a),
        border: Border.all(color: const Color(0xff925e12)),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('bird_message_input'),
              controller: controller,
              minLines: 1,
              maxLines: 1,
              onSubmitted: onSubmit,
              style: TextStyle(
                color: FqaColors.cream,
                fontSize: layout.font(15),
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: context.strings.messageHint,
                hintStyle: TextStyle(
                  color: const Color(0xff73684c),
                  fontSize: layout.font(15),
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: layout.s(18),
                  right: layout.s(8),
                  bottom: layout.s(2),
                ),
              ),
            ),
          ),
          FqaPressable(
            key: const ValueKey('bird_send'),
            borderRadius: 24,
            onTap: () => onSubmit(controller.text),
            child: SizedBox(
              width: layout.s(54).clamp(48.0, 58.0),
              child: Transform.rotate(
                angle: -0.37,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(11, 8, 11, 15),
                  child: FqaAssetImage('icons/send_message_button.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BirdScreenOverlay extends StatelessWidget {
  const _BirdScreenOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x61080706),
            Color(0x1f080706),
            Color(0x14080706),
            Color(0x1f080706),
            Color(0x52080706),
          ],
          stops: [0, 0.22, 0.44, 0.68, 1],
        ),
      ),
    );
  }
}
