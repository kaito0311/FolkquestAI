import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/models/bird_conversation_message.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/fqa_pressable.dart';
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
  final _scrollController = ScrollController();
  final _messageKeys = <DateTime, GlobalKey>{};
  DateTime? _pinnedUserMessageCreatedAt;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit(String question) async {
    _messageController.clear();
    final submit = widget.controller.submitBirdQuestion(question);
    _pinLatestUserMessageToTopWithRetries();
    final submitted = await submit;
    if (!mounted) return;
    if (!submitted) {
      _messageController.text = question;
      return;
    }
  }

  void _pinLatestUserMessageToTopWithRetries() {
    for (final delay in const [
      Duration.zero,
      Duration(milliseconds: 40),
      Duration(milliseconds: 120),
      Duration(milliseconds: 240),
    ]) {
      Future<void>.delayed(delay, _scrollLatestUserMessageToTop);
    }
  }

  void _scrollLatestUserMessageToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final latestUserMessage = widget.controller.birdMessages.reversed
          .where((message) => message.isUser)
          .firstOrNull;
      if (latestUserMessage == null) return;
      _pinnedUserMessageCreatedAt = latestUserMessage.createdAt;
      final key = _messageKeys[latestUserMessage.createdAt];
      final context = key?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.birdMessages;
    final activeMessageTimes = messages
        .map((message) => message.createdAt)
        .toSet();
    _messageKeys.removeWhere((time, _) => !activeMessageTimes.contains(time));
    for (final message in messages) {
      _messageKeys.putIfAbsent(message.createdAt, GlobalKey.new);
    }

    return FqaScaffold(
      background: 'backgrounds/bird_chat_bg.png',
      overlay: const _ConversationOverlay(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final inputBottom = layout.gap(20);
          final inputHeight = layout.s(52).clamp(46.0, 52.0);
          final continueButtonBottom =
              inputBottom + inputHeight + layout.gap(14);
          final continueButtonHeight = layout.s(38).clamp(34.0, 42.0);
          final threadTop = layout.isLandscape
              ? layout.y(176).clamp(132.0, 200.0)
              : layout.y(150).clamp(150.0, 410.0);
          final threadBottom =
              continueButtonBottom + continueButtonHeight + layout.gap(16);

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
                bottom: threadBottom,
                child: _ConversationThread(
                  controller: _scrollController,
                  layout: layout,
                  messages: messages,
                  messageKeys: _messageKeys,
                  pinnedUserMessageCreatedAt: _pinnedUserMessageCreatedAt,
                  responsePending: widget.controller.birdResponsePending,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: continueButtonBottom,
                child: Center(
                  child: FqaImageButton(
                    label: 'Tiếp tục câu chuyện',
                    width: layout.contentWidth(194, landscapeValue: 220),
                    height: continueButtonHeight,
                    fontSize: layout.font(14),
                    assetName: 'buttons/unlock_button.png',
                    onPressed:
                        widget.controller.continueBirdConversationToKarma,
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
                  enabled: !widget.controller.birdResponsePending,
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

class _ConversationThread extends StatelessWidget {
  const _ConversationThread({
    required this.controller,
    required this.layout,
    required this.messages,
    required this.messageKeys,
    required this.pinnedUserMessageCreatedAt,
    required this.responsePending,
  });

  final ScrollController controller;
  final ResponsiveLayout layout;
  final List<BirdConversationMessage> messages;
  final Map<DateTime, GlobalKey> messageKeys;
  final DateTime? pinnedUserMessageCreatedAt;
  final bool responsePending;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final entry in messages.asMap().entries) ...[
                  Builder(
                    builder: (context) {
                      final message = entry.value;
                      if (message.isUser) {
                        return KeyedSubtree(
                          key: messageKeys[message.createdAt],
                          child: _UserBubble(
                            layout: layout,
                            text: message.text,
                            createdAt: message.createdAt,
                          ),
                        );
                      }
                      return KeyedSubtree(
                        key: messageKeys[message.createdAt],
                        child: _BirdBubble(
                          layout: layout,
                          text: message.text.isEmpty && responsePending
                              ? 'Chim Thần đang suy nghĩ...'
                              : message.text,
                          createdAt: message.createdAt,
                        ),
                      );
                    },
                  ),
                  if (entry.key < messages.length - 1)
                    SizedBox(height: layout.gap(15)),
                ],
                if (pinnedUserMessageCreatedAt != null)
                  SizedBox(height: constraints.maxHeight * 0.72),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatMessageTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _MessageTime extends StatelessWidget {
  const _MessageTime({required this.time, required this.layout});

  final DateTime time;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatMessageTime(time),
      style: TextStyle(
        color: const Color(0xffa48955),
        fontSize: layout.font(10),
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BirdBubble extends StatelessWidget {
  const _BirdBubble({
    required this.layout,
    required this.text,
    required this.createdAt,
  });

  final ResponsiveLayout layout;
  final String text;
  final DateTime createdAt;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: _BirdMessageText(
                        text: text,
                        style: TextStyle(
                          color: const Color(0xffd4b072),
                          fontSize: layout.font(14),
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: layout.gap(4)),
            Padding(
              padding: EdgeInsets.only(left: layout.s(6)),
              child: _MessageTime(time: createdAt, layout: layout),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class _BirdMessageText extends StatelessWidget {
  const _BirdMessageText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(style: style, children: _parseBoldMarkdown(text, style)),
    );
  }
}

List<TextSpan> _parseBoldMarkdown(String text, TextStyle style) {
  final spans = <TextSpan>[];
  var cursor = 0;

  while (cursor < text.length) {
    final start = text.indexOf('**', cursor);
    if (start < 0) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }

    final end = text.indexOf('**', start + 2);
    if (end < 0) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }

    if (start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, start)));
    }

    final boldText = text.substring(start + 2, end);
    if (boldText.isEmpty) {
      spans.add(const TextSpan(text: '****'));
    } else {
      spans.add(
        TextSpan(
          text: boldText,
          style: style.copyWith(fontWeight: FontWeight.w900),
        ),
      );
    }
    cursor = end + 2;
  }

  return spans;
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({
    required this.layout,
    required this.text,
    required this.createdAt,
  });

  final ResponsiveLayout layout;
  final String text;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
                          fontSize: layout.font(14),
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: layout.gap(4)),
            Padding(
              padding: EdgeInsets.only(right: layout.s(6)),
              child: _MessageTime(time: createdAt, layout: layout),
            ),
          ],
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
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final ResponsiveLayout layout;
  final bool enabled;
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
              enabled: enabled,
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
                  bottom: layout.s(2),
                ),
              ),
            ),
          ),
          FqaPressable(
            key: const ValueKey('bird_followup_send'),
            borderRadius: 24,
            enabled: enabled,
            onTap: enabled ? () => onSubmit(controller.text) : null,
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
