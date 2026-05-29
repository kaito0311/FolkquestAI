import 'package:flutter/material.dart';

import 'package:fqa/models/collectible.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';

class CollectibleCard extends StatelessWidget {
  const CollectibleCard({
    required this.collectible,
    required this.unlocked,
    super.key,
  });

  final Collectible collectible;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final visibleName = unlocked ? collectible.name : '???';
    return SizedBox(
      key: ValueKey('collectible_${collectible.id}'),
      width: 126,
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xfff5e8c8), Color(0xffe5d29a)],
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.28,
                          child: FqaAssetImage(
                            collectible.assetName,
                            fallback: Icon(
                              unlocked ? Icons.auto_awesome : Icons.lock,
                              color: const Color(0xff6a481d),
                              size: 46,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 46,
                    color: const Color(0xff1c150a),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      visibleName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xffe1ce97),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FqaAssetImage('panels/card_frame.png', fit: BoxFit.fill),
        ],
      ),
    );
  }
}
