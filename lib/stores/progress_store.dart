import 'package:fqa/models/game_snapshot.dart';

abstract class ProgressStore {
  Future<GameSnapshot?> load();
  Future<void> save(GameSnapshot snapshot);
}
