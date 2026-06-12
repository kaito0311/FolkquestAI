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
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final scaledChild = MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(controller.textScaleFactor),
              ),
              child: child ?? const SizedBox.shrink(),
            );
            final opacity = controller.brightnessOverlayOpacity;
            if (opacity == 0) return scaledChild;
            return Stack(
              children: [
                scaledChild,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Color.fromRGBO(0, 0, 0, opacity)),
                  ),
                ),
              ],
            );
          },
          home: FqaApp(controller: controller),
        );
      },
    );
  }
}
