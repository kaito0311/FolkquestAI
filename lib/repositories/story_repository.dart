import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';
import 'package:fqa/models/story_node_type.dart';

class StoryRepository {
  static const startNodeId = 'inheritance_intro';

  static const collectibles = [
    Collectible(
      id: 'bag3',
      name: 'Túi ba gang',
      description: 'Biểu tượng của sự vừa đủ.',
      assetName: 'collectibles/item_bag3.png',
    ),
    Collectible(
      id: 'starfruit',
      name: 'Cây khế',
      description: 'Gia tài nhỏ mở ra con đường mới.',
      assetName: 'collectibles/item_starfruit.png',
    ),
    Collectible(
      id: 'gold',
      name: 'Vàng',
      description: 'Phần thưởng thử lòng người.',
      assetName: 'collectibles/item_gold.png',
    ),
    Collectible(
      id: 'feather',
      name: 'Lông chim thần',
      description: 'Biểu tượng của cơ duyên và lòng tốt được đền đáp.',
      assetName: 'collectibles/item_feather.png',
    ),
    Collectible(
      id: 'bag12',
      name: 'Túi 12 gang',
      description: 'Lời nhắc về lòng tham.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'half',
      name: 'Nửa tài sản',
      description: 'Một khả năng khác trong cuộc chia gia tài.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery1',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery2',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
    Collectible(
      id: 'mystery3',
      name: '???',
      description: 'Chưa mở khóa.',
      assetName: 'collectibles/item_bag12.png',
    ),
  ];

  static Set<String> get initialUnlockedIds => collectibles
      .where((collectible) => collectible.initiallyUnlocked)
      .map((collectible) => collectible.id)
      .toSet();

  static const endings = {
    'enough': Ending(
      id: 'enough',
      title: 'Con đường biết đủ',
      karmaSummary: 'Người đã biết dừng lại.',
    ),
    'fairness': Ending(
      id: 'fairness',
      title: 'Con đường công bằng',
      karmaSummary: 'Người đã chọn nói điều cần nói.',
    ),
    'leaving': Ending(
      id: 'leaving',
      title: 'Con đường tự lập',
      karmaSummary: 'Người đã rời đi để giữ lòng bình yên.',
    ),
  };

  static const nodes = {
    // Placeholder story data: replace these nodes with the final script later.
    'inheritance_intro': StoryNode(
      id: 'inheritance_intro',
      title: 'Chia gia tài',
      type: StoryNodeType.dialogue,
      speaker: 'Người anh',
      text:
          'Từ nay, chú hãy ra ở riêng. Ta chia cho chú cây khế sau nhà, còn ruộng vườn ta giữ lại.',
      nextId: 'inheritance_choice',
    ),
    'inheritance_choice': StoryNode(
      id: 'inheritance_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Người em',
      text:
          'Người em nên đáp lại thế nào trước lời chia gia tài của người anh?',
      choices: [
        StoryChoice(
          label: 'Nhận cây khế',
          nextId: 'bag_choice',
          karmaDelta: 1,
          unlockCollectibleIds: ['starfruit'],
        ),
        StoryChoice(
          label: 'Xin chia lại',
          nextId: 'fairness_reflection',
          karmaDelta: 0,
          unlockCollectibleIds: ['half'],
        ),
        StoryChoice(
          label: 'Rời đi',
          nextId: 'leaving_reflection',
          karmaDelta: -1,
        ),
      ],
    ),
    'bag_choice': StoryNode(
      id: 'bag_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Chim thần',
      text: 'Chim thần hứa trả vàng và bảo người em chuẩn bị một chiếc túi.',
      choices: [
        StoryChoice(
          label: 'Chọn túi ba gang',
          nextId: 'gold_choice',
          karmaDelta: 1,
          unlockCollectibleIds: ['bag3', 'feather'],
        ),
        StoryChoice(
          label: 'Chọn túi 12 gang',
          nextId: 'greed_reflection',
          karmaDelta: -2,
          unlockCollectibleIds: ['bag12'],
        ),
      ],
    ),
    'gold_choice': StoryNode(
      id: 'gold_choice',
      title: 'Lựa chọn',
      type: StoryNodeType.options,
      speaker: 'Người em',
      text:
          'Đứng trước kho vàng, người em cần quyết định có lấy thêm hay không.',
      choices: [
        StoryChoice(
          label: 'Không lấy thêm vàng',
          nextId: 'first_positive_ending',
          karmaDelta: 1,
          unlockCollectibleIds: ['gold'],
        ),
        StoryChoice(
          label: 'Lấy thêm một ít',
          nextId: 'greed_reflection',
          karmaDelta: -1,
          unlockCollectibleIds: ['gold'],
        ),
      ],
    ),
    'enough_reflection': StoryNode(
      id: 'enough_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Điều khó nhất trên đời không phải là kiếm được, mà là biết đủ.',
      nextId: 'feather_unlock',
      karmaDelta: 1,
      reflectionTitle: 'Người đã biết dừng lại.',
    ),
    'fairness_reflection': StoryNode(
      id: 'fairness_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Có những lúc công bằng bắt đầu bằng một lời nói bình tĩnh.',
      nextId: 'fairness_ending',
      karmaDelta: 1,
      reflectionTitle: 'Người đã giữ tiếng nói của mình.',
    ),
    'leaving_reflection': StoryNode(
      id: 'leaving_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text: 'Rời đi không phải lúc nào cũng là thua cuộc.',
      nextId: 'leaving_ending',
      karmaDelta: 0,
      reflectionTitle: 'Người đã chọn bình yên.',
    ),
    'greed_reflection': StoryNode(
      id: 'greed_reflection',
      title: 'Nghiệp Lực',
      type: StoryNodeType.karma,
      text:
          'Khi chiếc túi lớn hơn điều cần thiết, đường về cũng trở nên nặng hơn.',
      nextId: 'enough_ending',
      karmaDelta: -1,
      reflectionTitle: 'Người đã nhìn thấy giới hạn.',
    ),
    'feather_unlock': StoryNode(
      id: 'feather_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Biểu tượng của cơ duyên, phần thưởng và lòng tốt được đền đáp.',
      nextId: 'enough_ending',
      unlockCollectibleId: 'feather',
    ),
    'first_positive_ending': StoryNode(
      id: 'first_positive_ending',
      title: 'Kết thúc tốt đẹp',
      type: StoryNodeType.firstEnding,
      text: 'Người biết đủ sẽ luôn nhận được những điều xứng đáng.',
      nextId: 'enough_reflection',
    ),
    'enough_ending': StoryNode(
      id: 'enough_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường biết đủ',
      endingId: 'enough',
    ),
    'fairness_ending': StoryNode(
      id: 'fairness_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường công bằng',
      endingId: 'fairness',
    ),
    'leaving_ending': StoryNode(
      id: 'leaving_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      text: 'Con đường tự lập',
      endingId: 'leaving',
    ),
  };

  static StoryNode node(String id) => nodes[id] ?? nodes[startNodeId]!;
}
