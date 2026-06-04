import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return FqaScaffold(
      background: 'backgrounds/collection_bg.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayout.of(constraints);
          final horizontalPadding = layout.horizontalScreenPadding(
            portrait: 36,
            landscape: 96,
          );
          final contentWidth = layout.contentWidth(352, landscapeValue: 520);

          return Stack(
            children: [
              _UtilityHeader(
                title: 'Cài đặt',
                layout: layout,
                onBack: controller.closeUtility,
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                top: layout.y(125).clamp(104.0, 125.0),
                bottom: layout.gap(52),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.music_note,
                            title: 'Nhạc nền',
                            subtitle: 'Bật / tắt nhạc nền trong game',
                            trailing: Switch.adaptive(
                              value: true,
                              activeThumbColor: const Color(0xffd7bb75),
                              activeTrackColor: const Color(0xff9b6b2c),
                              onChanged: (_) {},
                            ),
                            footer: _StaticSlider(
                              layout: layout,
                              label: '100%',
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.text_fields,
                            title: 'Kích thước chữ',
                            subtitle: 'Điều chỉnh kích thước chữ hiển thị',
                            footer: _TextSizeSegment(layout: layout),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.wb_sunny_outlined,
                            title: 'Độ sáng',
                            subtitle: 'Điều chỉnh độ sáng màn hình',
                            trailing: Text(
                              '100%',
                              style: TextStyle(
                                color: const Color(0xffad9e79),
                                fontSize: layout.font(14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            footer: _StaticSlider(layout: layout, label: null),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.info_outline,
                            title: 'Giới thiệu ứng dụng',
                            subtitle: 'Tìm hiểu thêm về FolkQuest AI',
                            showChevron: true,
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.restore,
                            title: 'Khôi phục mặc định',
                            subtitle: 'Đưa tất cả cài đặt về mặc định ban đầu',
                            showChevron: true,
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.logout,
                            title: 'Đăng xuất',
                            subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
                            showChevron: true,
                          ),
                          SizedBox(height: layout.gap(20)),
                          SizedBox(
                            width: layout.s(119),
                            height: layout.s(14),
                            child: const FqaAssetImage(
                              'decor/setting_line.png',
                            ),
                          ),
                          SizedBox(height: layout.gap(6)),
                          Text(
                            'phiên bản 1.0.0',
                            style: TextStyle(
                              color: const Color(0xff63431f),
                              fontSize: layout.font(7),
                              fontWeight: FontWeight.w800,
                            ),
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

class _UtilityHeader extends StatelessWidget {
  const _UtilityHeader({
    required this.title,
    required this.layout,
    required this.onBack,
  });

  final String title;
  final ResponsiveLayout layout;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
              semanticLabel: 'Quay lại',
              size: layout.s(46).clamp(42.0, 48.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xffb07d36),
                fontSize: layout.font(30),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.layout,
    required this.height,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.footer,
    this.showChevron = false,
  });

  final ResponsiveLayout layout;
  final double height;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? footer;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(height).clamp(height == 80 ? 72.0 : 108.0, height),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FqaAssetImage('panels/setting_frame.png', fit: BoxFit.fill),
          Padding(
            padding: EdgeInsets.fromLTRB(
              layout.s(18),
              layout.s(14),
              layout.s(18),
              layout.s(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xffb07d36),
                      size: layout.s(34).clamp(28.0, 38.0),
                    ),
                    SizedBox(width: layout.s(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xffb79e6c),
                              fontSize: layout.font(14),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: layout.s(3)),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xffe5d4a5),
                              fontSize: layout.font(11),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ?trailing,
                    if (showChevron)
                      Icon(
                        Icons.chevron_right,
                        color: const Color(0xffb07d36),
                        size: layout.s(32),
                      ),
                  ],
                ),
                if (footer != null) ...[const Spacer(), footer!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticSlider extends StatelessWidget {
  const _StaticSlider({required this.layout, required this.label});

  final ResponsiveLayout layout;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.volume_down,
          color: const Color(0xffb07d36),
          size: layout.s(28),
        ),
        SizedBox(width: layout.s(10)),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xff916526),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(width: layout.s(10)),
        Container(
          width: layout.s(13),
          height: layout.s(13),
          decoration: const BoxDecoration(
            color: Color(0xffe3d69d),
            shape: BoxShape.circle,
          ),
        ),
        if (label != null) ...[
          SizedBox(width: layout.s(12)),
          Text(
            label!,
            style: TextStyle(
              color: const Color(0xffad9e79),
              fontSize: layout.font(14),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _TextSizeSegment extends StatelessWidget {
  const _TextSizeSegment({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.s(36).clamp(32.0, 36.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff916526)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _TextSizeOption(layout: layout, label: 'Nhỏ'),
          _TextSizeOption(layout: layout, label: 'Trung bình', selected: true),
          _TextSizeOption(layout: layout, label: 'Lớn'),
        ],
      ),
    );
  }
}

class _TextSizeOption extends StatelessWidget {
  const _TextSizeOption({
    required this.layout,
    required this.label,
    this.selected = false,
  });

  final ResponsiveLayout layout;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? const Color(0xff6e4e24) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xffddcc9e),
              fontSize: layout.font(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
