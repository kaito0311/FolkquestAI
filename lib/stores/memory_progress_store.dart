import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/stores/progress_store.dart';

class MemoryProgressStore implements ProgressStore {
  GameSnapshot? snapshot;

  @override
  Future<GameSnapshot?> load() async => snapshot;

  @override
  Future<void> save(GameSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}
