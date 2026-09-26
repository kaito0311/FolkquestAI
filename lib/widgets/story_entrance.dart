import 'dart:async';

import 'package:flutter/material.dart';

class StoryEntrance extends StatefulWidget {
  const StoryEntrance({
    required this.child,
    this.offset = const Offset(0, 0.05),
    this.scaleBegin = 1,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    super.key,
  });

  final Widget child;
  final Offset offset;
  final double scaleBegin;
  final Duration delay;
  final Duration duration;

  @override
  State<StoryEntrance> createState() => _StoryEntranceState();
}

class _StoryEntranceState extends State<StoryEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: widget.scaleBegin,
            end: 1,
          ).animate(animation),
          child: widget.child,
        ),
      ),
    );
  }
}
