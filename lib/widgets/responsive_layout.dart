import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum FqaLayoutClass { compactPortrait, regularPortrait, landscape }

class ResponsiveLayout {
  ResponsiveLayout._(this.size, {FqaLayoutClass? forcedLayoutClass})
    : layoutClass =
          forcedLayoutClass ??
          (size.width >= size.height
              ? FqaLayoutClass.landscape
              : size.width < 390
              ? FqaLayoutClass.compactPortrait
              : FqaLayoutClass.regularPortrait),
      widthScale = size.width / designWidth,
      heightScale = size.height / designHeight,
      minScale = math.min(size.width / designWidth, size.height / designHeight),
      maxScale = math.max(size.width / designWidth, size.height / designHeight);

  factory ResponsiveLayout.of(BoxConstraints constraints) {
    return ResponsiveLayout._(
      Size(constraints.maxWidth, constraints.maxHeight),
    );
  }

  /// Uses the portrait composition even when an on-screen keyboard leaves a
  /// short body constraint. The keyboard should only affect vertical space.
  factory ResponsiveLayout.portraitOf(BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    return ResponsiveLayout._(
      size,
      forcedLayoutClass: size.width < 390
          ? FqaLayoutClass.compactPortrait
          : FqaLayoutClass.regularPortrait,
    );
  }

  static const designWidth = 426.0;
  static const designHeight = 899.0;

  final Size size;
  final FqaLayoutClass layoutClass;
  final double widthScale;
  final double heightScale;
  final double minScale;
  final double maxScale;

  bool get isLandscape => layoutClass == FqaLayoutClass.landscape;

  double x(double value) => value * widthScale;

  double y(double value) => value * heightScale;

  double s(double value) => value * minScale;

  double m(double value) => value * maxScale;

  double font(double value) => value * minScale.clamp(0.86, 1.08);

  double gap(double value) => value * minScale.clamp(0.72, 1.0);

  double horizontalPadding(double value) {
    return math.min(value, math.max(16, size.width * 0.08));
  }

  double horizontalScreenPadding({
    double portrait = 24,
    double landscape = 48,
  }) {
    final value = isLandscape ? landscape : portrait;
    return math.min(value, math.max(16, size.width * 0.08));
  }

  double ceremonyTitleTop({double portrait = 39, double landscape = 28}) {
    return isLandscape ? gap(landscape) : y(portrait).clamp(28.0, portrait);
  }

  /// Bottom inset shared by the primary continuation action across story
  /// utility screens, so the action remains in the same place between them.
  double continuationButtonBottom() {
    return isLandscape ? gap(24) : y(31).clamp(24.0, 31.0);
  }

  double maxWidth(double value, {double padding = 0}) {
    return math.min(value, math.max(0, size.width - padding * 2));
  }

  double contentWidth(double portraitValue, {double? landscapeValue}) {
    final value = isLandscape ? landscapeValue ?? portraitValue : portraitValue;
    return math.min(value, size.width);
  }
}
