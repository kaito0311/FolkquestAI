import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_pressable.dart';

class CollectionTab extends StatelessWidget {
  const CollectionTab({
    required this.label,
    required this.assetName,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final String assetName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FqaPressable(
        key: ValueKey('filter_$label'),
        borderRadius: 6,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: FqaAssetImage(
                assetName,
                fit: BoxFit.contain,
                fallback: Icon(
                  selected ? Icons.auto_awesome : Icons.lock_open,
                  color: selected ? FqaColors.gold : const Color(0xffc8ad6b),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xfff0dc9d)
                    : const Color(0xffc8ad6b),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
