class Collectible {
  const Collectible({
    required this.id,
    required this.name,
    required this.description,
    required this.assetName,
    this.initiallyUnlocked = false,
  });

  final String id;
  final String name;
  final String description;
  final String assetName;
  final bool initiallyUnlocked;
}
