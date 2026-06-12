import 'package:flutter_test/flutter_test.dart';

import 'package:fqa/models/auth_user.dart';
import 'package:fqa/models/game_snapshot.dart';
import 'package:fqa/services/auth_service.dart';
import 'package:fqa/stores/hybrid_progress_store.dart';
import 'package:fqa/stores/memory_progress_store.dart';
import 'package:fqa/stores/progress_merger.dart';

void main() {
  test('merge keeps stronger progress and unions collectibles', () {
    const local = GameSnapshot(
      currentNodeId: 'local_node',
      karma: 1,
      selectedChoices: ['keep_tree'],
      unlockedCollectibles: {'starfruit'},
      runUnlockedCollectibles: {'starfruit'},
    );
    const remote = GameSnapshot(
      currentNodeId: 'remote_node',
      karma: 3,
      selectedChoices: ['keep_tree', 'small_bag'],
      unlockedCollectibles: {'bag3'},
      runUnlockedCollectibles: {'bag3'},
      completedEndingId: 'enough',
    );

    final merged = mergeProgressSnapshots(local, remote)!;

    expect(merged.currentNodeId, 'remote_node');
    expect(merged.karma, 3);
    expect(merged.selectedChoices, remote.selectedChoices);
    expect(merged.unlockedCollectibles, {'starfruit', 'bag3'});
    expect(merged.runUnlockedCollectibles, {'bag3'});
    expect(merged.completedEndingId, 'enough');
  });

  test('hybrid store saves locally only when signed out', () async {
    final local = MemoryProgressStore();
    final remote = MemoryProgressStore();
    final auth = _FakeAuthService();
    final store = HybridProgressStore(
      local: local,
      authService: auth,
      remoteFactory: (_) => remote,
    );
    const snapshot = GameSnapshot(
      currentNodeId: 'start_intro',
      karma: 0,
      selectedChoices: [],
      unlockedCollectibles: {},
    );

    await store.save(snapshot);

    expect(local.snapshot, snapshot);
    expect(remote.snapshot, isNull);
  });

  test('hybrid store merges and saves both stores when signed in', () async {
    final local = MemoryProgressStore()
      ..snapshot = const GameSnapshot(
        currentNodeId: 'local_node',
        karma: 2,
        selectedChoices: ['local'],
        unlockedCollectibles: {'starfruit'},
      );
    final remote = MemoryProgressStore()
      ..snapshot = const GameSnapshot(
        currentNodeId: 'remote_node',
        karma: 1,
        selectedChoices: [],
        unlockedCollectibles: {'bag3'},
      );
    final auth = _FakeAuthService(
      user: const AuthUser(uid: 'uid', email: 'player@example.com'),
    );
    final store = HybridProgressStore(
      local: local,
      authService: auth,
      remoteFactory: (_) => remote,
    );

    final merged = await store.load();

    expect(merged?.currentNodeId, 'local_node');
    expect(merged?.unlockedCollectibles, {'starfruit', 'bag3'});
    expect(local.snapshot?.unlockedCollectibles, {'starfruit', 'bag3'});
    expect(remote.snapshot?.unlockedCollectibles, {'starfruit', 'bag3'});
  });
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.user});

  AuthUser? user;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser?> signInWithGoogle() async => user;

  @override
  Future<void> signOut() async {
    user = null;
  }
}
