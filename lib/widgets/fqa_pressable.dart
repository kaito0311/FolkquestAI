import 'package:flutter/material.dart';

class FqaPressable extends StatefulWidget {
  const FqaPressable({
    required this.child,
    this.onTap,
    this.borderRadius = 8,
    this.pressedScale = 0.965,
    this.hoverScale = 1.015,
    this.enabled = true,
    this.semanticButton = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double pressedScale;
  final double hoverScale;
  final bool enabled;
  final bool semanticButton;

  @override
  State<FqaPressable> createState() => _FqaPressableState();
}

class _FqaPressableState extends State<FqaPressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _active => widget.enabled && widget.onTap != null;

  double get _scale {
    if (!_active) return 1;
    if (_pressed) return widget.pressedScale;
    if (_hovered || _focused) return widget.hoverScale;
    return 1;
  }

  double get _highlightOpacity {
    if (!_active) return 0;
    if (_pressed) return 0.08;
    if (_hovered || _focused) return 0.12;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 110);

    return Semantics(
      button: widget.semanticButton,
      enabled: _active,
      child: FocusableActionDetector(
        enabled: _active,
        mouseCursor: _active ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _active ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: _active ? () => setState(() => _pressed = false) : null,
          onTapUp: _active ? (_) => setState(() => _pressed = false) : null,
          onTap: _active ? widget.onTap : null,
          child: AnimatedScale(
            scale: _scale,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  widget.child,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _highlightOpacity,
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        child: const ColoredBox(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
