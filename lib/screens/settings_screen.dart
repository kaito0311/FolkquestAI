import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/app_localizations.dart';
import 'package:fqa/models/app_language.dart';
import 'package:fqa/services/text_to_speech_service.dart';
import 'package:fqa/widgets/fqa_asset_image.dart';
import 'package:fqa/widgets/fqa_pressable.dart';
import 'package:fqa/widgets/fqa_scaffold.dart';
import 'package:fqa/widgets/responsive_layout.dart';
import 'package:fqa/widgets/utility_icon.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadTtsVoices();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
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
                title: strings.settings,
                layout: layout,
                onBack: widget.controller.closeUtility,
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
                            height: 80,
                            icon: Icons.language,
                            title: strings.languageLabel,
                            subtitle: strings.languageHint,
                            trailing: _LanguageSelector(
                              value: widget.controller.language,
                              onChanged: widget.controller.setLanguage,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.speed,
                            title: strings.speechRate,
                            subtitle: strings.speechRateHint,
                            footer: _SettingSlider(
                              layout: layout,
                              value: widget.controller.speechRateSliderPosition,
                              min: GameController.minSpeechRateSliderPosition,
                              max: GameController.maxSpeechRateSliderPosition,
                              divisions: 10,
                              leadingIcon: Icons.slow_motion_video_outlined,
                              trailingIcon: Icons.fast_forward,
                              valueLabel:
                                  '${widget.controller.speechRateMultiplier.toStringAsFixed(1)}×',
                              semanticLabel: strings.speechRate,
                              onChanged:
                                  widget.controller.setSpeechRateSliderPosition,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.record_voice_over_outlined,
                            title: strings.voice,
                            subtitle: strings.voiceHint,
                            trailing: _VoiceSelector(
                              voices: widget.controller.availableVoices,
                              value: widget.controller.selectedVoiceName,
                              defaultLabel: strings.defaultVoice,
                              onChanged: widget.controller.setVoiceName,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.music_note,
                            title: strings.backgroundMusic,
                            subtitle: strings.musicHint,
                            trailing: _SettingSwitch(
                              value: widget.controller.musicEnabled,
                              onChanged: widget.controller.setMusicEnabled,
                            ),
                            footer: _SettingSlider(
                              layout: layout,
                              value: widget.controller.musicVolume,
                              enabled: widget.controller.musicEnabled,
                              leadingIcon: widget.controller.musicVolume > 50
                                  ? Icons.volume_up
                                  : Icons.volume_down,
                              valueLabel:
                                  '${widget.controller.musicVolume.round()}%',
                              semanticLabel: 'Âm lượng nhạc nền',
                              onChanged: widget.controller.setMusicVolume,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.text_fields,
                            title: strings.textSize,
                            subtitle: strings.textSizeHint,
                            footer: _TextSizeSegment(
                              layout: layout,
                              selected: widget.controller.textSize,
                              onChanged: widget.controller.setTextSize,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 120,
                            icon: Icons.wb_sunny_outlined,
                            title: strings.brightness,
                            subtitle: strings.brightnessHint,
                            trailing: Text(
                              '${widget.controller.screenBrightness.round()}%',
                              style: TextStyle(
                                color: const Color(0xffad9e79),
                                fontSize: layout.font(14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            footer: _SettingSlider(
                              layout: layout,
                              value: widget.controller.screenBrightness,
                              leadingIcon: Icons.brightness_low,
                              trailingIcon: Icons.brightness_high,
                              semanticLabel: 'Độ sáng màn hình',
                              onChanged: widget.controller.setScreenBrightness,
                            ),
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.info_outline,
                            title: strings.about,
                            subtitle: strings.aboutHint,
                            showChevron: true,
                            onTap: widget.controller.openInformation,
                          ),
                          SizedBox(height: layout.gap(15)),
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.restore,
                            title: strings.restoreDefaults,
                            subtitle: strings.restoreDefaultsHint,
                            showChevron: true,
                            onTap: _restoreDefaults,
                          ),
                          SizedBox(height: layout.gap(15)),
                          if (widget.controller.isSignedIn) ...[
                            _SettingCard(
                              layout: layout,
                              height: 80,
                              icon: Icons.account_circle_outlined,
                              title: widget.controller.currentUser!.label,
                              subtitle:
                                  widget.controller.currentUser!.email ??
                                  strings.syncingProgress,
                            ),
                            SizedBox(height: layout.gap(15)),
                          ],
                          _SettingCard(
                            layout: layout,
                            height: 80,
                            icon: Icons.logout,
                            title: strings.signOut,
                            subtitle: widget.controller.isSignedIn
                                ? strings.signOutHint
                                : strings.notSignedIn,
                            showChevron: widget.controller.isSignedIn,
                            enabled:
                                widget.controller.isSignedIn &&
                                !widget.controller.authBusy,
                            onTap: widget.controller.isSignedIn
                                ? () => unawaited(_signOut())
                                : null,
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
                            strings.version,
                            style: TextStyle(
                              color: const Color(0xff63431f),
                              fontSize: layout.font(10),
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

  Future<void> _signOut() async {
    await widget.controller.signOut();
    if (!mounted || widget.controller.authError == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(widget.controller.authError!)));
    widget.controller.clearAuthError();
  }

  void _restoreDefaults() {
    widget.controller
      ..setMusicEnabled(true)
      ..setMusicVolume(20)
      ..setTextSize(AppTextSize.medium)
      ..setScreenBrightness(100)
      ..resetVoiceNames()
      ..setSpeechRateMultiplier(1);
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
              semanticLabel: 'Quay lại',
              size: layout.s(46).clamp(42.0, 48.0),
              onTap: onBack,
            ),
          ),
          Center(
            child: SizedBox(
              width: titleWidth,
              height: 44 * titleScale,
              child: Stack(
                clipBehavior: Clip.none,
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
                    title,
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
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
    this.enabled = true,
    this.onTap,
  });

  static const _frameCenterSlice = Rect.fromLTRB(10, 10, 788, 261);

  final ResponsiveLayout layout;
  final double height;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? footer;
  final bool showChevron;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardHeight = layout
        .s(height)
        .clamp(height == 80 ? 72.0 : 108.0, height);

    return SizedBox(
      height: cardHeight,
      child: Semantics(
        button: onTap != null,
        enabled: enabled,
        child: FqaPressable(
          borderRadius: 8,
          semanticButton: false,
          onTap: enabled ? onTap : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const FqaAssetImage(
                'panels/setting_frame.png',
                fit: BoxFit.fill,
                centerSlice: _frameCenterSlice,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  layout.s(18),
                  layout.s(14),
                  layout.s(18),
                  layout.s(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: enabled
                              ? const Color(0xffb07d36)
                              : const Color(0xff765c36),
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
                                  color: enabled
                                      ? const Color(0xffb79e6c)
                                      : const Color(0xff765c36),
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
                                  color: enabled
                                      ? const Color(0xffe5d4a5)
                                      : const Color(0xff806b46),
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
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.value, required this.onChanged});

  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<AppLanguage>(
        value: value,
        isDense: true,
        dropdownColor: const Color(0xfffff4d6),
        iconEnabledColor: const Color(0xff76522a),
        style: const TextStyle(
          color: Color(0xff76522a),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        onChanged: (language) {
          if (language != null) onChanged(language);
        },
        items: AppLanguage.values
            .map(
              (language) => DropdownMenuItem(
                value: language,
                child: Text(language.label),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _VoiceSelector extends StatelessWidget {
  const _VoiceSelector({
    required this.voices,
    required this.value,
    required this.defaultLabel,
    required this.onChanged,
  });

  final List<TtsVoice> voices;
  final String? value;
  final String defaultLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: voices.any((voice) => voice.name == value) ? value : null,
          isExpanded: true,
          isDense: true,
          dropdownColor: const Color(0xfffff4d6),
          iconEnabledColor: const Color(0xff76522a),
          style: const TextStyle(
            color: Color(0xff76522a),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(defaultLabel, overflow: TextOverflow.ellipsis),
            ),
            ...voices.map(
              (voice) => DropdownMenuItem<String?>(
                value: voice.name,
                child: Text(voice.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('setting_music_switch'),
      button: true,
      toggled: value,
      label: 'Nhạc nền',
      child: FqaPressable(
        borderRadius: 18,
        semanticButton: false,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 54,
          height: 30,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value ? const Color(0xff9b6b2c) : const Color(0xff4b3420),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: value ? const Color(0xff9b6b2c) : const Color(0xff8f7a59),
              width: 2,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xffd7bb75),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.layout,
    required this.value,
    required this.leadingIcon,
    required this.semanticLabel,
    required this.onChanged,
    this.enabled = true,
    this.trailingIcon,
    this.valueLabel,
    this.min = 0,
    this.max = 100,
    this.divisions = 100,
  });

  final ResponsiveLayout layout;
  final double value;
  final IconData leadingIcon;
  final String semanticLabel;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final IconData? trailingIcon;
  final String? valueLabel;
  final double min;
  final double max;
  final int divisions;

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled
        ? const Color(0xffb07d36)
        : const Color(0xff765c36);
    final textColor = enabled
        ? const Color(0xffad9e79)
        : const Color(0xff765c36);

    return SizedBox(
      height: layout.s(34).clamp(30.0, 38.0),
      child: Row(
        children: [
          Icon(leadingIcon, color: iconColor, size: layout.s(24)),
          SizedBox(width: layout.s(8)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: const Color(0xffb07d36),
                inactiveTrackColor: const Color(0xff916526),
                disabledActiveTrackColor: const Color(0xff72522a),
                disabledInactiveTrackColor: const Color(0xff4d351d),
                thumbColor: const Color(0xffe3d69d),
                disabledThumbColor: const Color(0xff806b46),
                overlayColor: const Color(0x33e3d69d),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: layout.s(7).clamp(6.0, 8.0),
                  disabledThumbRadius: layout.s(7).clamp(6.0, 8.0),
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: layout.s(14).clamp(12.0, 16.0),
                ),
              ),
              child: Semantics(
                label: semanticLabel,
                value: valueLabel ?? value.toStringAsFixed(2),
                child: Slider(
                  key: ValueKey('setting_slider_$semanticLabel'),
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ),
          ),
          SizedBox(width: layout.s(8)),
          SizedBox(
            width: layout.s(42).clamp(36.0, 44.0),
            child: valueLabel != null
                ? Text(
                    valueLabel!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: textColor,
                      fontSize: layout.font(13),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : trailingIcon != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      trailingIcon,
                      color: iconColor,
                      size: layout.s(24),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TextSizeSegment extends StatelessWidget {
  const _TextSizeSegment({
    required this.layout,
    required this.selected,
    required this.onChanged,
  });

  final ResponsiveLayout layout;
  final AppTextSize selected;
  final ValueChanged<AppTextSize> onChanged;

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
          for (final option in AppTextSize.values)
            _TextSizeOption(
              layout: layout,
              option: option,
              selected: selected == option,
              onTap: () => onChanged(option),
            ),
        ],
      ),
    );
  }
}

class _TextSizeOption extends StatelessWidget {
  const _TextSizeOption({
    required this.layout,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ResponsiveLayout layout;
  final AppTextSize option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: FqaPressable(
          key: ValueKey('setting_text_size_${option.name}'),
          borderRadius: 5,
          semanticButton: false,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? const Color(0xff6e4e24) : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                switch (option) {
                  AppTextSize.small => context.strings.small,
                  AppTextSize.medium => context.strings.medium,
                  AppTextSize.large => context.strings.large,
                },
                style: TextStyle(
                  color: const Color(0xffddcc9e),
                  fontSize: layout.font(12),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
