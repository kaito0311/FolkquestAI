import 'package:flutter/material.dart';

import 'package:fqa/models/story_transition_kind.dart';

class FqaTransitions {
  const FqaTransitions._();

  static const appViewDuration = Duration(milliseconds: 280);
  static const storyNodeDuration = Duration(milliseconds: 240);
  static const overlayDuration = Duration(milliseconds: 180);
  static const curve = Curves.easeOutCubic;

  static Duration durationFor(BuildContext context, Duration duration) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : duration;
  }

  static Widget softPageTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.018),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }

  static Widget softOverlayTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
        child: child,
      ),
    );
  }

  static Widget storyNodeTransition(
    StoryTransitionKind kind,
    Widget child,
    Animation<double> animation,
  ) {
    final isCeremony = switch (kind) {
      StoryTransitionKind.toFirstEnding ||
      StoryTransitionKind.firstEndingToKarma ||
      StoryTransitionKind.karmaToUnlock ||
      StoryTransitionKind.unlockToEnding => true,
      _ => false,
    };
    final curved = CurvedAnimation(
      parent: animation,
      curve: isCeremony ? Curves.easeInOutCubic : curve,
    );
    const offset = Offset(0, 0.018);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
