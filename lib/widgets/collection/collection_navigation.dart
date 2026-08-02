import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/models/collection_filter.dart';
import 'package:fqa/widgets/collection/collection_tab.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class CollectionNavigation extends StatelessWidget {
  const CollectionNavigation({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const FqaAssetImage('navigation/nav_bar.png', fit: BoxFit.fill),
        Row(
          children: [
            CollectionTab(
              label: context.strings.all,
              assetName: 'navigation/nav_all.png',
              selected: controller.collectionFilter == CollectionFilter.all,
              onTap: () => controller.setCollectionFilter(CollectionFilter.all),
            ),
            CollectionTab(
              label: context.strings.opened,
              assetName: 'navigation/nav_open.png',
              selected: controller.collectionFilter == CollectionFilter.opened,
              onTap: () =>
                  controller.setCollectionFilter(CollectionFilter.opened),
            ),
            CollectionTab(
              label: context.strings.locked,
              assetName: 'navigation/nav_locked.png',
              selected: controller.collectionFilter == CollectionFilter.locked,
              onTap: () =>
                  controller.setCollectionFilter(CollectionFilter.locked),
            ),
          ],
        ),
      ],
    );
  }
}
