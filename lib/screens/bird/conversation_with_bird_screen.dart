import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/story_top_bar.dart';

class ConversationWithBirdScreen extends StatefulWidget {
  const ConversationWithBirdScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ConversationWithBirdScreen> createState() =>
      _ConversationWithBirdScreenState();
}

class _ConversationWithBirdScreenState
    extends State<ConversationWithBirdScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit(String question) {
    widget.controller.submitBirdQuestion(question);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.controller.birdQuestion;

    return FqaScaffold(
      background: 'backgrounds/bird_chat_bg.png',
      overlay: const _ConversationOverlay(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final inputBottom = layout.gap(20);
          final inputHeight = layout.s(52).clamp(46.0, 52.0);
          final threadTop = layout.isLandscape
              ? layout.y(176).clamp(132.0, 200.0)
              : layout.y(410).clamp(276.0, 410.0);

          return Stack(
            children: [
              StoryTopBar(
                title: 'Chim Thần',
                onBack: widget.controller.backFromBirdConversation,
                onPause: widget.controller.showPause,
              ),
              Positioned(
                left: layout.horizontalScreenPadding(
                  portrait: 26,
                  landscape: 70,
                ),
                right: layout.horizontalScreenPadding(
                  portrait: 22,
                  landscape: 70,
                ),
                top: threadTop,
                bottom: inputBottom + inputHeight + layout.gap(18),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _BirdBubble(
                        layout: layout,
                        text:
                            'Con cứ hỏi điều còn băn khoăn. Ta sẽ cùng con nhìn lại câu chuyện.',
                      ),
                      SizedBox(height: layout.gap(24)),
                      _UserBubble(layout: layout, text: question),
                      SizedBox(height: layout.gap(24)),
                      _BirdBubble(
                        layout: layout,
                        text:
                            'Khi lòng tham lớn hơn sự biết đủ, con người dễ đánh mất những gì mình đang có.',
                      ),
                    ],
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
                child: _ConversationInput(
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

class _BirdBubble extends StatelessWidget {
  const _BirdBubble({required this.layout, required this.text});

  final ResponsiveLayout layout;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: layout.s(45).clamp(40.0, 45.0),
          height: layout.s(45).clamp(40.0, 45.0),
          child: const FqaAssetImage('icons/bird_avatar.png'),
        ),
        SizedBox(width: layout.s(11)),
        SizedBox(
          width: layout.contentWidth(212, landscapeValue: 320),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: layout.s(45).clamp(40.0, 45.0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _BubbleFrame(
                    assetName: 'panels/bird_chat_frame.png',
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(layout.s(15)),
                      topRight: Radius.circular(layout.s(15)),
                      bottomRight: Radius.circular(layout.s(15)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    layout.s(16),
                    layout.s(10),
                    layout.s(14),
                    layout.s(10),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: const Color(0xffd4b072),
                      fontSize: layout.font(11),
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.layout, required this.text});

  final ResponsiveLayout layout;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Spacer(),
        SizedBox(
          width: layout.contentWidth(212, landscapeValue: 320),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: layout.s(45).clamp(40.0, 45.0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _BubbleFrame(
                    assetName: 'panels/user_chat_frame.png',
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(layout.s(15)),
                      topRight: Radius.circular(layout.s(15)),
                      bottomLeft: Radius.circular(layout.s(15)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    layout.s(18),
                    layout.s(12),
                    layout.s(13),
                    layout.s(12),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: const Color(0xffd8c58f),
                      fontSize: layout.font(10),
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: layout.s(12)),
        SizedBox(
          width: layout.s(45).clamp(40.0, 45.0),
          height: layout.s(45).clamp(40.0, 45.0),
          child: const FqaAssetImage('icons/player_avatar.png'),
        ),
      ],
    );
  }
}

class _BubbleFrame extends StatelessWidget {
  const _BubbleFrame({required this.assetName, required this.borderRadius});

  final String assetName;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0xff925e12)),
        ),
        child: FqaAssetImage(assetName, fit: BoxFit.fill),
      ),
    );
  }
}

class _ConversationInput extends StatelessWidget {
  const _ConversationInput({
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
              key: const ValueKey('bird_followup_input'),
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
                hintText: 'Nhập tin nhắn ...',
                hintStyle: TextStyle(
                  color: const Color(0xff73684c),
                  fontSize: layout.font(15),
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: layout.s(18),
                  right: layout.s(8),
                  bottom: layout.s(4),
                ),
              ),
            ),
          ),
          InkWell(
            key: const ValueKey('bird_followup_send'),
            borderRadius: BorderRadius.circular(24),
            onTap: () => onSubmit(controller.text),
            child: SizedBox(
              width: layout.s(54).clamp(48.0, 58.0),
              child: Transform.rotate(
                angle: -0.37,
                child: const Padding(
                  padding: EdgeInsets.all(11),
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

class _ConversationOverlay extends StatelessWidget {
  const _ConversationOverlay();

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
