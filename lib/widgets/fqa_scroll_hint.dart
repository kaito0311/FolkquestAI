import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';

class FqaScrollHint extends StatefulWidget {
  const FqaScrollHint({
    required this.child,
    this.hintHeight = 20,
    this.bottomPadding = 6,
    super.key,
  });

  final Widget child;
  final double hintHeight;
  final double bottomPadding;

  @override
  State<FqaScrollHint> createState() => _FqaScrollHintState();
}

class _FqaScrollHintState extends State<FqaScrollHint> {
  final ScrollController _controller = ScrollController();
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void didUpdateWidget(FqaScrollHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateScrollHint)
      ..dispose();
    super.dispose();
  }

  void _updateScrollHint() {
    if (!mounted || !_controller.hasClients) return;

    final position = _controller.position;
    final shouldShow =
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - 4;
    if (shouldShow != _showScrollHint) {
      setState(() => _showScrollHint = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _controller,
              padding: EdgeInsets.only(bottom: widget.bottomPadding),
              child: widget.child,
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              height: widget.hintHeight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: _showScrollHint ? 1 : 0,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: FqaColors.cream.withValues(alpha: 0.62),
                  size: widget.hintHeight + 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
