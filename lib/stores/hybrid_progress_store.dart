import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/services/auth_service.dart';
import 'package:fqa/stores/firestore_progress_store.dart';
import 'package:fqa/stores/progress_merger.dart';
import 'package:fqa/stores/progress_store.dart';

typedef RemoteProgressStoreFactory = ProgressStore Function(String uid);

class HybridProgressStore implements ProgressStore {
  HybridProgressStore({
    required this.local,
    required this.authService,
    RemoteProgressStoreFactory? remoteFactory,
  }) : _remoteFactory =
           remoteFactory ?? ((uid) => FirestoreProgressStore(uid: uid));

  final ProgressStore local;
  final AuthService authService;
  final RemoteProgressStoreFactory _remoteFactory;

  bool get cloudSyncActive => authService.currentUser != null;

  @override
  Future<GameSnapshot?> load() async {
    final localSnapshot = await local.load();
    final user = authService.currentUser;
    if (user == null) return localSnapshot;

    try {
      final remote = _remoteFactory(user.uid);
      final remoteSnapshot = await remote.load();
      final merged = mergeProgressSnapshots(localSnapshot, remoteSnapshot);
      if (merged != null) {
        await save(merged);
      }
      return merged;
    } catch (_) {
      return localSnapshot;
    }
  }

  @override
  Future<void> save(GameSnapshot snapshot) async {
    await local.save(snapshot);
    final user = authService.currentUser;
    if (user == null) return;
    try {
      await _remoteFactory(user.uid).save(snapshot);
    } catch (_) {
      // Local progress is the source of offline resilience; cloud sync can
      // recover on the next load/save when Firebase is reachable again.
    }
  }
}
