import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/models/collectible.dart';
import 'package:fqa/widgets/collection/collectible_card.dart';

class CollectibleGrid extends StatelessWidget {
  const CollectibleGrid({
    required this.controller,
    required this.items,
    super.key,
  });

  final GameController controller;
  final List<Collectible> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 126 / 170,
      children: [
        for (final collectible in items)
          CollectibleCard(
            collectible: collectible,
            unlocked: controller.isUnlocked(collectible),
          ),
      ],
    );
  }
}
