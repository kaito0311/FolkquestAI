import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fqa/app/fqa_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/core/fqa_assets.dart';
import 'package:fqa/core/fqa_colors.dart';
import 'package:fqa/services/bird_chat_service.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    required this.controller,
    this.enableBackgroundMusic = true,
    super.key,
  });

  final GameController controller;
  final bool enableBackgroundMusic;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  AudioPlayer? _backgroundPlayer;
  bool _musicPlaying = false;
  bool _isAppResumed = true;
  bool? _lastMusicEnabled;
  double? _lastMusicVolume;
  bool _initialWarmupScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isAppResumed =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    widget.controller.addListener(_syncBackgroundMusicIfNeeded);
    if (widget.enableBackgroundMusic) {
      _backgroundPlayer = AudioPlayer(playerId: 'folkquest_background_music');
      unawaited(_backgroundPlayer!.setReleaseMode(ReleaseMode.loop));
      unawaited(_syncBackgroundMusic(force: true));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed == isResumed) return;

    _isAppResumed = isResumed;
    if (isResumed) {
      unawaited(_syncBackgroundMusic(force: true));
      return;
    }

    _musicPlaying = false;
    final player = _backgroundPlayer;
    if (player != null) {
      unawaited(player.pause());
    }
  }

  @override
  void didUpdateWidget(MainApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncBackgroundMusicIfNeeded);
      widget.controller.addListener(_syncBackgroundMusicIfNeeded);
      _lastMusicEnabled = null;
      _lastMusicVolume = null;
      _syncBackgroundMusicIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_syncBackgroundMusicIfNeeded);
    final player = _backgroundPlayer;
    _backgroundPlayer = null;
    if (player != null) {
      unawaited(player.dispose());
    }
    super.dispose();
  }

  void _syncBackgroundMusicIfNeeded() {
    final enabled = widget.controller.musicEnabled;
    final volume = widget.controller.musicVolume;
    if (_lastMusicEnabled == enabled && _lastMusicVolume == volume) return;
    _lastMusicEnabled = enabled;
    _lastMusicVolume = volume;
    unawaited(_syncBackgroundMusic());
  }

  Future<void> _syncBackgroundMusic({bool force = false}) async {
    final player = _backgroundPlayer;
    if (player == null) return;

    final volume = (widget.controller.musicVolume / 100).clamp(0.0, 1.0);

    try {
      await player.setVolume(volume);
      if (!_isAppResumed || !widget.controller.musicEnabled) {
        await player.pause();
        _musicPlaying = false;
        return;
      }

      if (_musicPlaying && !force) return;

      await player.play(AssetSource('music/TownTheme.mp3'), volume: volume);

      // The lifecycle or music setting can change while play() is awaiting the
      // platform player. Do not let a late completion restart background audio.
      if (!_isAppResumed || !widget.controller.musicEnabled) {
        await player.pause();
        _musicPlaying = false;
        return;
      }

      _musicPlaying = true;
    } catch (error) {
      _musicPlaying = false;
      debugPrint('Background music could not start: $error');
    }
  }

  void _scheduleInitialWarmup(BuildContext context) {
    if (_initialWarmupScheduled) return;
    _initialWarmupScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final service = widget.controller.birdChatService;
      if (service is FirebaseBirdChatService) {
        unawaited(_preloadBirdChatConfig(service));
      }
      unawaited(_precacheFirstInteractionAssets(context));
    });
  }

  Future<void> _preloadBirdChatConfig(FirebaseBirdChatService service) async {
    try {
      await service.preload();
    } catch (error) {
      debugPrint('Bird chat configuration preload failed: $error');
    }
  }

  Future<void> _precacheFirstInteractionAssets(BuildContext context) async {
    const assets = [
      'backgrounds/story_bg.png',
      'backgrounds/options_bg.png',
      'backgrounds/collection_bg.png',
      'buttons/primary_button.png',
      'icons/back_icon.png',
      'panels/dialog_panel.png',
    ];
    for (final asset in assets) {
      await precacheImage(AssetImage(FqaAssets.image(asset)), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FolkQuest',
          locale: Locale(widget.controller.language.languageCode),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: FqaColors.gold),
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          builder: (context, child) {
            _scheduleInitialWarmup(context);
            final mediaQuery = MediaQuery.of(context);
            final scaledChild = MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  widget.controller.textScaleFactor,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
            final opacity = widget.controller.brightnessOverlayOpacity;
            if (opacity == 0) return scaledChild;
            return Stack(
              children: [
                scaledChild,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Color.fromRGBO(0, 0, 0, opacity)),
                  ),
                ),
              ],
            );
          },
          home: FqaApp(controller: widget.controller),
        );
      },
    );
  }
}
