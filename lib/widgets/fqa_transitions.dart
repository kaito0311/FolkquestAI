import 'package:flutter/material.dart';

import 'package:fqa/models/story_transition_kind.dart';

class FqaTransitions {
  const FqaTransitions._();

  static const appViewDuration = Duration(milliseconds: 280);
  static const storyNodeDuration = Duration(milliseconds: 240);
  static const overlayDuration = Duration(milliseconds: 180);
  static const curve = Curves.easeOutCubic;

  static bool usesStoryFlowTransition(StoryTransitionKind kind) {
    return switch (kind) {
      StoryTransitionKind.storyToStory ||
      StoryTransitionKind.storyToOptions ||
      StoryTransitionKind.optionsToStory => true,
      _ => false,
    };
  }

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
    if (!usesStoryFlowTransition(kind)) return child;

    // Keep the two full-screen scenes opaque. The outgoing scene leaves to
    // the left while the incoming one enters from the right, so the app's
    // black backdrop is never exposed during a story/option transition.
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final isExiting = animation.status == AnimationStatus.reverse;
        final horizontalOffset = isExiting
            ? animation.value - 1
            : 1 - animation.value;
        return FractionalTranslation(
          translation: Offset(horizontalOffset, 0),
          child: child,
        );
      },
    );
  }
}
