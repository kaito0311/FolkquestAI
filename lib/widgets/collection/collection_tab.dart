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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          child: AnimatedContainer(
            key: ValueKey('collection_tab_active_$label'),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff80612c), Color(0xff3f2a0e)],
                    )
                  : null,
              border: Border.all(
                color: selected ? const Color(0xffffdfa0) : Colors.transparent,
                width: selected ? 1.2 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x80e8b94d),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
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
                      color: selected
                          ? FqaColors.gold
                          : const Color(0xffc8ad6b),
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
        ),
      ),
    );
  }
}
