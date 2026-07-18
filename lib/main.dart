import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fqa/app/main_app.dart';
import 'package:fqa/controllers/game_controller.dart';
import 'package:fqa/firebase_options.dart';
import 'package:fqa/services/auth_service.dart';
import 'package:fqa/services/bird_chat_service.dart';
import 'package:fqa/services/firebase_auth_service.dart';
import 'package:fqa/stores/hybrid_progress_store.dart';
import 'package:fqa/stores/progress_store.dart';
import 'package:fqa/stores/shared_preferences_progress_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _tryInitializeFirebase();
  PaintingBinding.instance.imageCache.maximumSize = 40;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 40 << 20;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final localStore = SharedPreferencesProgressStore(prefs);
  final AuthService authService = firebaseReady
      ? FirebaseAuthService()
      : const NoopAuthService();
  final ProgressStore progressStore = firebaseReady
      ? HybridProgressStore(local: localStore, authService: authService)
      : localStore;
  final BirdChatService birdChatService = firebaseReady
      ? FirebaseBirdChatService()
      : const LocalBirdChatService();
  final controller = GameController(
    progressStore,
    authService: authService,
    birdChatService: birdChatService,
  );
  await controller.load();
  runApp(MainApp(controller: controller));
}

Future<bool> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (error) {
    debugPrint('Firebase is not configured yet: $error');
    return false;
  }
}
