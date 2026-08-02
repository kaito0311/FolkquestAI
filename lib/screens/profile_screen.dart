import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/repositories/story_repository.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

const _settingFrameCenterSlice = Rect.fromLTRB(12, 12, 786, 259);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/collection_bg.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 34,
            landscape: 96,
          );
          final contentWidth = layout.contentWidth(356, landscapeValue: 520);
          final user = controller.currentUser;
          final displayName = user?.label ?? context.strings.folkQuestPlayer;
          final email = user?.email ?? context.strings.notSignedInShort;
          final collectibles =
              '${controller.unlockedCollectibleIds.length}/${StoryRepository.collectibles.length}';

          return Stack(
            children: [
              _ProfileHeader(layout: layout, onBack: controller.closeUtility),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: layout.y(126).clamp(104.0, 130.0),
                bottom: layout.gap(44),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _ProfileCard(
                            layout: layout,
                            displayName: displayName,
                            email: email,
                            signedIn: controller.isSignedIn,
                          ),
                          SizedBox(height: layout.gap(16)),
                          _StatsGrid(
                            layout: layout,
                            playCount: controller.playCount,
                            choices: controller.selectedChoices.length,
                            collectibles: collectibles,
                          ),
                          SizedBox(height: layout.gap(16)),
                          _ProfileNote(
                            layout: layout,
                            signedIn: controller.isSignedIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.layout, required this.onBack});

  final ResponsiveLayout layout;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final titleWidth = layout.s(284).clamp(212.0, 284.0);
    final titleScale = titleWidth / 284;

    return Positioned(
      top: layout.y(28).clamp(18.0, 36.0),
      left: layout.horizontalScreenPadding(portrait: 20, landscape: 54),
      right: layout.horizontalScreenPadding(portrait: 20, landscape: 54),
      height: layout.s(72).clamp(60.0, 76.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: layout.s(10),
            child: UtilityIcon(
              assetName: 'icons/back_icon.png',
              semanticLabel: context.strings.back,
              size: layout.s(46).clamp(42.0, 48.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: SizedBox(
              width: titleWidth,
              height: 33 * titleScale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 25 * titleScale,
                    top: 11.14 * titleScale,
                    width: 44 * titleScale,
                    height: 15 * titleScale,
                    child: Transform.rotate(
                      angle: 3.141592653589793,
                      child: const FqaAssetImage(
                        'decor/setting_title_side_decor.png',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 26 * titleScale,
                    top: 11.14 * titleScale,
                    width: 44 * titleScale,
                    height: 15 * titleScale,
                    child: Transform.scale(
                      scaleY: -1,
                      child: const FqaAssetImage(
                        'decor/setting_title_side_decor.png',
                      ),
                    ),
                  ),
                  Text(
                    context.strings.profile,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xffb07d36),
                      fontSize: layout.font(30),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.76 * titleScale,
                      height: 33 / 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.layout,
    required this.displayName,
    required this.email,
    required this.signedIn,
  });

  final ResponsiveLayout layout;
  final String displayName;
  final String email;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(170).clamp(148.0, 178.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage(
            'panels/setting_frame.png',
            fit: BoxFit.fill,
            centerSlice: _settingFrameCenterSlice,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.s(22),
              vertical: layout.s(18),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: layout.s(82).clamp(70.0, 88.0),
                  height: layout.s(82).clamp(70.0, 88.0),
                  child: const FqaAssetImage('icons/player_avatar.png'),
                ),
                SizedBox(width: layout.s(18)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xffe5d4a5),
                          fontSize: layout.font(19),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: layout.gap(5)),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xffad9e79),
                          fontSize: layout.font(12),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: layout.gap(12)),
                      _StatusPill(layout: layout, signedIn: signedIn),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.layout, required this.signedIn});

  final ResponsiveLayout layout;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: signedIn ? const Color(0xff35572c) : const Color(0xff4b3420),
        border: Border.all(color: const Color(0xff916526)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: layout.s(10),
          vertical: layout.s(5),
        ),
        child: Text(
          signedIn ? context.strings.syncing : context.strings.localPlay,
          style: TextStyle(
            color: const Color(0xffddcc9e),
            fontSize: layout.font(11),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.layout,
    required this.playCount,
    required this.choices,
    required this.collectibles,
  });

  final ResponsiveLayout layout;
  final int playCount;
  final int choices;
  final String collectibles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            layout: layout,
            label: context.strings.playCount,
            value: playCount.toString(),
            icon: Icons.replay,
          ),
        ),
        SizedBox(width: layout.gap(10)),
        Expanded(
          child: _StatTile(
            layout: layout,
            label: context.strings.choices,
            value: choices.toString(),
            icon: Icons.route,
          ),
        ),
        SizedBox(width: layout.gap(10)),
        Expanded(
          child: _StatTile(
            layout: layout,
            label: context.strings.items,
            value: collectibles,
            icon: Icons.inventory_2_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.layout,
    required this.label,
    required this.value,
    required this.icon,
  });

  final ResponsiveLayout layout;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(104).clamp(92.0, 108.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage(
            'panels/setting_frame.png',
            fit: BoxFit.fill,
            centerSlice: _settingFrameCenterSlice,
          ),
          Padding(
            padding: EdgeInsets.all(layout.s(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xffb07d36),
                  size: layout.s(24).clamp(20.0, 26.0),
                ),
                SizedBox(height: layout.gap(5)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xffe5d4a5),
                    fontSize: layout.font(20),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: layout.gap(2)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xffad9e79),
                    fontSize: layout.font(10),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNote extends StatelessWidget {
  const _ProfileNote({required this.layout, required this.signedIn});

  final ResponsiveLayout layout;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(98).clamp(84.0, 104.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage(
            'panels/setting_frame.png',
            fit: BoxFit.fill,
            centerSlice: _settingFrameCenterSlice,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.s(20),
              vertical: layout.s(14),
            ),
            child: Center(
              child: Text(
                signedIn
                    ? context.strings.profileSyncedNote
                    : context.strings.profileLocalNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xffe5d4a5),
                  fontSize: layout.font(13),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
