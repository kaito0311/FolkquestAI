import 'package:flutter/material.dart';

import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_image_button.dart';
import 'package:fqa/widgets/utility_icon.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onContinue,
    required this.onRestart,
    required this.onExit,
    required this.onUtility,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final ValueChanged<String> onUtility;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: _PausePanel(
          onClose: onContinue,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
            child: Column(
              children: [
                const _PauseTitle(),
                const SizedBox(height: 16),
                const _PauseDecorativeLine(),
                const SizedBox(height: 16),
                _PauseButtons(
                  onContinue: onContinue,
                  onRestart: onRestart,
                  onExit: onExit,
                ),
                const Spacer(),
                _PauseOperationIcons(onUtility: onUtility),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PausePanel extends StatelessWidget {
  const _PausePanel({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 477,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: FqaAssetImage(
              'panels/pause_panel.png',
              fit: BoxFit.fill,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xff25170c),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
          Positioned(
            top: -16,
            right: -16,
            child: UtilityIcon(
              assetName: 'icons/close_icon.png',
              semanticLabel: 'Đóng',
              size: 56,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseTitle extends StatelessWidget {
  const _PauseTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Tạm dừng',
      style: TextStyle(
        color: FqaColors.cream,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PauseDecorativeLine extends StatelessWidget {
  const _PauseDecorativeLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 160, height: 1, color: const Color(0xff8b6a2e));
  }
}

class _PauseButtons extends StatelessWidget {
  const _PauseButtons({
    required this.onContinue,
    required this.onRestart,
    required this.onExit,
  });

  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FqaImageButton(
          label: 'Tiếp tục',
          width: 260,
          height: 80,
          fontSize: 20,
          assetName: 'buttons/pause_continue_button.png',
          onPressed: onContinue,
        ),
        const SizedBox(height: 8),
        FqaImageButton(
          label: 'Chơi lại',
          width: 260,
          height: 80,
          fontSize: 20,
          assetName: 'buttons/pause_play_again_button.png',
          onPressed: onRestart,
        ),
        const SizedBox(height: 8),
        FqaImageButton(
          label: 'Thoát',
          width: 260,
          height: 80,
          fontSize: 20,
          assetName: 'buttons/pause_exit_button.png',
          onPressed: onExit,
        ),
      ],
    );
  }
}

class _PauseOperationIcons extends StatelessWidget {
  const _PauseOperationIcons({required this.onUtility});

  final ValueChanged<String> onUtility;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UtilityIcon(
          assetName: 'icons/profile_icon.png',
          semanticLabel: 'Hồ sơ',
          size: 40,
          onTap: () => onUtility('profile'),
        ),
        const SizedBox(width: 20),
        UtilityIcon(
          assetName: 'icons/settings_icon.png',
          semanticLabel: 'Cài đặt',
          size: 40,
          onTap: () => onUtility('settings'),
        ),
        const SizedBox(width: 20),
        UtilityIcon(
          assetName: 'icons/help_icon.png',
          semanticLabel: 'Trợ giúp',
          size: 40,
          onTap: () => onUtility('tutorial'),
        ),
      ],
    );
  }
}
