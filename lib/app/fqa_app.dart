import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/models/app_view.dart';
import 'package:fqa/screens/bird/chat_with_bird_screen.dart';
import 'package:fqa/screens/bird/conversation_with_bird_screen.dart';
import 'package:fqa/screens/collection/collection_screen.dart';
import 'package:fqa/screens/home_screen.dart';
import 'package:fqa/screens/settings_screen.dart';
import 'package:fqa/screens/story/story_screen.dart';
import 'package:fqa/screens/tutorial_screen.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/pause_overlay.dart';

class FqaApp extends StatelessWidget {
  const FqaApp({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final Widget screen = switch (controller.view) {
      AppView.home => HomeScreen(controller: controller),
      AppView.story => StoryScreen(controller: controller),
      AppView.collection => CollectionScreen(controller: controller),
      AppView.settings => SettingsScreen(controller: controller),
      AppView.tutorial => TutorialScreen(controller: controller),
      AppView.birdChat => ChatWithBirdScreen(controller: controller),
      AppView.birdConversation => ConversationWithBirdScreen(
        controller: controller,
      ),
    };

    return Stack(
      children: [
        screen,
        if (controller.pauseVisible)
          PauseOverlay(
            onContinue: controller.hidePause,
            onRestart: controller.restartRun,
            onExit: controller.exitToHome,
            onUtility: (title) {
              if (title == 'Cài đặt') {
                controller.openSettings();
              } else if (title == 'Trợ giúp') {
                controller.openTutorial();
              } else {
                showPlaceholder(context, title);
              }
            },
          ),
        // const Positioned.fill(
        //   child: IgnorePointer(
        //     child: FqaAssetImage('panels/screen_frame.png', fit: BoxFit.fill),
        //   ),
        // ),
      ],
    );
  }
}

void showPlaceholder(BuildContext context, String title) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xff20150c),
      title: Text(title, style: const TextStyle(color: FqaColors.gold)),
      content: const Text(
        'Màn hình này sẽ được bổ sung khi có thiết kế chi tiết.',
        style: TextStyle(color: FqaColors.cream),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}
