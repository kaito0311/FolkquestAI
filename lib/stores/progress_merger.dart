import 'package:fqa/models/game_snapshot.dart';

GameSnapshot? mergeProgressSnapshots(
  GameSnapshot? local,
  GameSnapshot? remote,
) {
  if (local == null) return remote;
  if (remote == null) return local;

  final localScore = _progressScore(local);
  final remoteScore = _progressScore(remote);
  final stronger = localScore >= remoteScore ? local : remote;
  final sameRun =
      local.currentNodeId == remote.currentNodeId ||
      local.selectedChoices.length == remote.selectedChoices.length;

  return GameSnapshot(
    currentNodeId: local.selectedChoices.length >= remote.selectedChoices.length
        ? local.currentNodeId
        : remote.currentNodeId,
    karma: local.karma >= remote.karma ? local.karma : remote.karma,
    selectedChoices:
        local.selectedChoices.length >= remote.selectedChoices.length
        ? local.selectedChoices
        : remote.selectedChoices,
    unlockedCollectibles: {
      ...local.unlockedCollectibles,
      ...remote.unlockedCollectibles,
    },
    runUnlockedCollectibles: sameRun
        ? {...local.runUnlockedCollectibles, ...remote.runUnlockedCollectibles}
        : stronger.runUnlockedCollectibles,
    completedEndingId:
        local.completedEndingId ??
        remote.completedEndingId ??
        stronger.completedEndingId,
    playCount: local.playCount >= remote.playCount
        ? local.playCount
        : remote.playCount,
  );
}

int _progressScore(GameSnapshot snapshot) {
  return snapshot.selectedChoices.length * 10 +
      snapshot.unlockedCollectibles.length +
      (snapshot.completedEndingId == null ? 0 : 100);
}
