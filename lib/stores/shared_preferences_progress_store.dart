import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/stores/progress_store.dart';

class SharedPreferencesProgressStore implements ProgressStore {
  const SharedPreferencesProgressStore(this.prefs);

  static const _key = 'fqa_game_state';

  final SharedPreferences prefs;

  @override
  Future<GameSnapshot?> load() async {
    final value = prefs.getString(_key);
    if (value == null) return null;
    return GameSnapshot.fromJson(jsonDecode(value) as Map<String, Object?>);
  }

  @override
  Future<void> save(GameSnapshot snapshot) {
    return prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }
}
