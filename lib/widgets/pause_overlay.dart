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
        child: SizedBox(
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
              Positioned(
                top: -16,
                right: -16,
                child: UtilityIcon(
                  assetName: 'icons/close_icon.png',
                  semanticLabel: 'Đóng',
                  size: 56,
                  onTap: onContinue,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
                  child: Column(
                    children: [
                      const Text(
                        'Tạm dừng',
                        style: TextStyle(
                          color: FqaColors.cream,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 160,
                        height: 1,
                        color: const Color(0xff8b6a2e),
                      ),
                      const SizedBox(height: 16),
                      FqaImageButton(
                        label: 'Tiếp tục',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onContinue,
                      ),
                      const SizedBox(height: 8),
                      FqaImageButton(
                        label: 'Chơi lại',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onRestart,
                      ),
                      const SizedBox(height: 8),
                      FqaImageButton(
                        label: 'Thoát',
                        width: 260,
                        height: 80,
                        fontSize: 20,
                        assetName: 'buttons/pause_button.png',
                        onPressed: onExit,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UtilityIcon(
                            assetName: 'icons/profile_icon.png',
                            semanticLabel: 'Hồ sơ',
                            size: 48,
                            onTap: () => onUtility('Hồ sơ'),
                          ),
                          const SizedBox(width: 20),
                          UtilityIcon(
                            assetName: 'icons/settings_icon.png',
                            semanticLabel: 'Cài đặt',
                            size: 48,
                            onTap: () => onUtility('Cài đặt'),
                          ),
                          const SizedBox(width: 20),
                          UtilityIcon(
                            assetName: 'icons/help_icon.png',
                            semanticLabel: 'Trợ giúp',
                            size: 48,
                            onTap: () => onUtility('Trợ giúp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
