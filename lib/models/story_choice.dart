class StoryChoice {
  const StoryChoice({
    required this.label,
    required this.nextId,
    this.karmaDelta = 0,
    this.unlockCollectibleIds = const [],
  });

  final String label;
  final String nextId;
  final int karmaDelta;
  final List<String> unlockCollectibleIds;
}
