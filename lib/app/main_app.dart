import 'package:flutter/material.dart';

import 'package:fqa/app/fqa_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_colors.dart';

class MainApp extends StatelessWidget {
  const MainApp({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FolkQuest',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: FqaColors.gold),
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          home: FqaApp(controller: controller),
        );
      },
    );
  }
}
