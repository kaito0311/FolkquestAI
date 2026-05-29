import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';

class ChoiceBullet extends StatelessWidget {
  const ChoiceBullet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text(
            '•',
            style: TextStyle(color: Color(0xffddb45d), fontSize: 16),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: FqaColors.parchment,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
