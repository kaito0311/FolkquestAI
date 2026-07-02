class StoryChoice {
  const StoryChoice({
    required this.label,
    required this.nextId,
    this.karmaDelta = 0,
    this.maxResultingKarma,
    this.unlockCollectibleIds = const [],
  });

  final String label;
  final String nextId;
  final int karmaDelta;
  final int? maxResultingKarma;
  final List<String> unlockCollectibleIds;
}
