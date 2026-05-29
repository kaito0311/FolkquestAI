import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ResponsiveLayout {
  ResponsiveLayout._(this.size)
    : widthScale = size.width / designWidth,
      heightScale = size.height / designHeight,
      minScale = math.min(size.width / designWidth, size.height / designHeight),
      maxScale = math.max(size.width / designWidth, size.height / designHeight);

  factory ResponsiveLayout.of(BoxConstraints constraints) {
    return ResponsiveLayout._(
      Size(constraints.maxWidth, constraints.maxHeight),
    );
  }

  static const designWidth = 426.0;
  static const designHeight = 899.0;

  final Size size;
  final double widthScale;
  final double heightScale;
  final double minScale;
  final double maxScale;

  double x(double value) => value * widthScale;

  double y(double value) => value * heightScale;

  double s(double value) => value * minScale;

  double m(double value) => value * maxScale;

  double font(double value) => value * minScale.clamp(0.86, 1.08);

  double gap(double value) => value * minScale.clamp(0.72, 1.0);

  double horizontalPadding(double value) {
    return math.min(value, math.max(16, size.width * 0.08));
  }

  double maxWidth(double value, {double padding = 0}) {
    return math.min(value, math.max(0, size.width - padding * 2));
  }
}
