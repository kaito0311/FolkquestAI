import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_pressable.dart';

class UtilityIcon extends StatelessWidget {
  const UtilityIcon({
    required this.assetName,
    required this.semanticLabel,
    required this.onTap,
    this.size = 56,
    super.key,
  });

  final String assetName;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: FqaPressable(
        key: ValueKey('icon_$semanticLabel'),
        borderRadius: size / 2,
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: FqaAssetImage(
            assetName,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff2d1b0d),
                border: Border.all(color: const Color(0xff8b6a2e)),
              ),
              child: Center(
                child: Icon(
                  _fallbackIcon,
                  color: FqaColors.gold,
                  size: size * 0.48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _fallbackIcon {
    return switch (semanticLabel) {
      'Quay lại' || 'Quay láº¡i' => Icons.arrow_back,
      'Tạm dừng' || 'Táº¡m dá»«ng' => Icons.pause,
      'Đóng' || 'ÄĂ³ng' => Icons.close,
      'Đăng nhập' => Icons.login,
      'Đăng xuất' => Icons.logout,
      'Tài khoản' => Icons.account_circle,
      _ => Icons.auto_awesome,
    };
  }
}
