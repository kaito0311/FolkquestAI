import 'package:fqa/models/collectible.dart';
import 'package:fqa/models/ending.dart';
import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';
import 'package:fqa/models/story_node_type.dart';
import 'package:fqa/models/app_language.dart';
import 'package:fqa/repositories/english_story_content.dart';

class StoryRepository {
  static const startNodeId = 'start_intro';

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
      name: 'Cán cân công bằng',
      description: 'Biểu tượng của lời yêu cầu chia tài sản công bằng.',
      assetName: 'collectibles/item_fair_share_scale.png',
    ),
  ];

  static Set<String> get initialUnlockedIds => collectibles
      .where((collectible) => collectible.initiallyUnlocked)
      .map((collectible) => collectible.id)
      .toSet();

  static List<Collectible> collectiblesFor(AppLanguage language) {
    if (language != AppLanguage.english) return collectibles;
    return [
      for (final item in collectibles)
        Collectible(
          id: item.id,
          name: _englishCollectibleNames[item.id] ?? item.name,
          description:
              _englishCollectibleDescriptions[item.id] ?? item.description,
          assetName: item.assetName,
          initiallyUnlocked: item.initiallyUnlocked,
        ),
    ];
  }

  static const _englishCollectibleNames = {
    'bag3': 'Three-span bag',
    'starfruit': 'Starfruit tree',
    'gold': 'Gold',
    'feather': 'Magic Bird feather',
    'bag12': 'Twelve-span bag',
    'half': 'Fair-share scale',
  };
  static const _englishCollectibleDescriptions = {
    'bag3': 'A symbol of knowing what is enough.',
    'starfruit': 'A small inheritance that opens a new path.',
    'gold': 'A reward that tests the heart.',
    'feather': 'A symbol of good fortune and kindness repaid.',
    'bag12': 'A reminder about greed.',
    'half': 'A symbol of asking for a fair division of the inheritance.',
  };

  static const endings = {
    'early_bad': Ending(
      id: 'early_bad',
      title: 'Cơ hội khép lại',
      karmaSummary: 'Lòng tham khiến cơ duyên khép lại quá sớm.',
    ),
    'no_promise': Ending(
      id: 'no_promise',
      title: 'Chim Thần rời đi',
      karmaSummary: 'Cơ hội tốt cần được giữ bằng sự tử tế.',
    ),
    'enough': Ending(
      id: 'enough',
      title: 'Con đường biết đủ',
      karmaSummary: 'Người đã biết dừng lại.',
    ),
    'player_bad': Ending(
      id: 'player_bad',
      title: 'Người em rơi xuống biển',
      karmaSummary: 'Chiếc túi quá lớn kéo cả lòng người xuống thấp.',
    ),
    'brother_bad': Ending(
      id: 'brother_bad',
      title: 'Tấm lòng vị tha',
      karmaSummary: 'Người có một tấm lòng vị tha',
    ),
    'keep_tree': Ending(
      id: 'keep_tree',
      title: 'Giữ lấy cây khế',
      karmaSummary: 'Người em biết bảo vệ điều quý giá bằng lòng bình an.',
    ),
  };

  static Ending ending(
    String id, {
    AppLanguage language = AppLanguage.vietnamese,
  }) {
    final ending = endings[id] ?? endings.values.first;
    if (language != AppLanguage.english) return ending;
    final text = _englishEndings[ending.id];
    return text == null
        ? ending
        : Ending(id: ending.id, title: text.$1, karmaSummary: text.$2);
  }

  static const _englishEndings = {
    'early_bad': ('An opportunity closes', 'Greed closed the door too early.'),
    'no_promise': (
      'The Magic Bird leaves',
      'Good opportunities need kindness to remain.',
    ),
    'enough': ('The path of knowing enough', 'You knew when to stop.'),
    'player_bad': (
      'The younger brother falls into the sea',
      'An oversized bag pulled the heart down with it.',
    ),
    'brother_bad': ('Compassion', 'A heart can remain compassionate.'),
    'keep_tree': (
      'Keep the starfruit tree',
      'The younger brother protects what is precious with peace.',
    ),
  };

  static const nodes = {
    'start_intro': StoryNode(
      id: 'start_intro',
      title: 'Mở đầu truyện',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/001_start_intro.png',
      text:
          'Ngày xưa, trong một ngôi làng nhỏ, có hai anh em sống nương tựa vào nhau. Bạn sẽ bước vào câu chuyện trong vai người em, hiền lành nhưng phải tự chọn cách giữ lấy lòng mình.',
      nextId: 'father_passes_away',
    ),
    'father_passes_away': StoryNode(
      id: 'father_passes_away',
      title: 'Cha qua đời',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/002_father_passes_away.png',
      text:
          'Sau khi cha mất, căn nhà vắng đi tiếng dặn dò quen thuộc. Hai anh em đứng trước phần gia tài còn lại và một cuộc chia chác không dễ nói thành lời.',
      nextId: 'divide_inheritance',
    ),
    'divide_inheritance': StoryNode(
      id: 'divide_inheritance',
      title: 'Chia gia tài',
      type: StoryNodeType.options,
      speaker: 'Người anh',
      background: 'backgrounds/003_divide_inheritance.png',
      text:
          'Từ nay, chú hãy ra ở riêng. Ruộng vườn, nhà cửa để anh giữ. Sau vườn còn một cây khế, chú nhận lấy mà sống.',
      choices: [
        StoryChoice(
          label: 'Chấp nhận cây khế',
          nextId: 'accept_starfruit_tree',
          karmaDelta: 1,
          unlockCollectibleIds: ['starfruit'],
        ),
        StoryChoice(
          label: 'Yêu cầu chia công bằng',
          nextId: 'inheritance_argument',
          unlockCollectibleIds: ['half'],
        ),
      ],
    ),
    'starfruit_unlock': StoryNode(
      id: 'starfruit_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Gia tài nhỏ mở ra con đường mới.',
      nextId: 'accept_starfruit_tree',
      unlockCollectibleId: 'starfruit',
    ),
    'half_unlock': StoryNode(
      id: 'half_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Biểu tượng của lời yêu cầu chia tài sản công bằng.',
      nextId: 'inheritance_argument',
      unlockCollectibleId: 'half',
    ),
    'accept_starfruit_tree': StoryNode(
      id: 'accept_starfruit_tree',
      title: 'Chấp nhận',
      type: StoryNodeType.dialogue,
      speaker: 'Người em',
      background: 'backgrounds/003_divide_inheritance.png',
      text:
          'Người em cúi đầu nhận phần ít ỏi. Cậu không muốn anh em vì của cải mà mất tình thân, chỉ mong cây khế sau nhà còn đủ để nuôi ngày tháng tới.',
      nextId: 'starfruit_tree',
    ),
    'inheritance_argument': StoryNode(
      id: 'inheritance_argument',
      title: 'Tranh chấp gia tài',
      type: StoryNodeType.options,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/003_1_inheritance_argument.png',
      text:
          'Người em không muốn gây chuyện, nhưng cũng cảm thấy việc chia gia tài như vậy chưa thật công bằng.',
      choices: [
        StoryChoice(
          label: 'Bình tĩnh nói lý với anh',
          nextId: 'fair_argument',
          karmaDelta: 1,
        ),
        StoryChoice(
          label: 'Nóng giận tranh giành',
          nextId: 'angry_argument',
          karmaDelta: -1,
        ),
        StoryChoice(
          label: 'Đòi phần hơn vì mình là em',
          nextId: 'early_bad_ending',
          karmaDelta: -2,
        ),
      ],
    ),
    'fair_argument': StoryNode(
      id: 'fair_argument',
      title: 'Lời nói công bằng',
      type: StoryNodeType.dialogue,
      speaker: 'Người em',
      background: 'backgrounds/003_1_inheritance_argument.png',
      text:
          'Người em giữ giọng bình tĩnh. Cậu chỉ xin anh nghĩ lại cho phải đạo, rồi vẫn chấp nhận chăm cây khế khi thấy lòng anh đã quyết.',
      nextId: 'starfruit_tree',
    ),
    'angry_argument': StoryNode(
      id: 'angry_argument',
      title: 'Cơn giận nổi lên',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/003_1_inheritance_argument.png',
      text:
          'Lời qua tiếng lại làm sân nhà nặng trĩu. Người em giận dữ rời đi, trong lòng vẫn còn vướng nỗi ấm ức về phần gia tài ít ỏi.',
      nextId: 'starfruit_tree',
    ),
    'early_bad_ending': StoryNode(
      id: 'early_bad_ending',
      title: 'Cơ hội khép lại',
      type: StoryNodeType.firstEnding,
      background: 'backgrounds/early_bad_ending.png',
      text:
          'Vì đòi phần hơn, người em đánh mất cả chút tình thân còn lại. Cây khế cũng chẳng còn thuộc về cậu, và câu chuyện vàng bạc khép lại trước khi bắt đầu.',
      nextId: 'early_bad_reflection',
    ),
    'starfruit_tree': StoryNode(
      id: 'starfruit_tree',
      title: 'Cây khế',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/004_starfruit_tree.png',
      text:
          'Từ ngày nhận cây khế, người em ngày ngày chăm sóc nó. Cây lớn lên xanh tốt, mùa nào cũng sai quả.',
      nextId: 'bird_appears',
    ),
    'bird_appears': StoryNode(
      id: 'bird_appears',
      title: 'Chim Thần',
      type: StoryNodeType.options,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/005_bird_appears.png',
      text:
          'Một hôm, có một con chim lớn bay đến đậu trên cây khế. Chim ăn từng quả chín vàng, khiến người em vừa ngạc nhiên vừa lo lắng.',
      choices: [
        StoryChoice(
          label: 'Nhẹ nhàng than với Chim Thần',
          nextId: 'gentle_complaint',
          karmaDelta: 1,
        ),
        StoryChoice(
          label: 'Vác gậy đuổi chim đi',
          nextId: 'chase_bird',
          karmaDelta: -1,
        ),
      ],
    ),
    'gentle_complaint': StoryNode(
      id: 'gentle_complaint',
      title: 'Gặp Chim Thần',
      type: StoryNodeType.dialogue,
      speaker: 'Người em',
      background: 'backgrounds/005_bird_appears.png',
      text:
          'Người em chắp tay thưa nhẹ: Chim ăn hết khế, nhà con sống sao? Nếu chim cần khế, xin hãy để lại cho con một đường sinh nhai.',
      nextId: 'karma_check',
    ),
    'chase_bird': StoryNode(
      id: 'chase_bird',
      title: 'Đuổi Chim Thần',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/005_1_chase_bird.png',
      text:
          'Người em nóng lòng vì sợ mất hết khế, liền vác gậy chạy ra đuổi chim. Chim Thần bay lên, ánh mắt trầm xuống như đang nhìn thấu lòng người.',
      nextId: 'karma_check',
    ),
    'karma_check': StoryNode(
      id: 'karma_check',
      title: 'Nghiệp lực',
      type: StoryNodeType.dialogue,
      text: '',
      karmaRoutes: [
        KarmaRoute(maxKarma: -2, nextId: 'no_promise_ending'),
        KarmaRoute(minKarma: -1, nextId: 'bird_promise'),
      ],
    ),
    'no_promise_ending': StoryNode(
      id: 'no_promise_ending',
      title: 'Chim Thần rời đi',
      type: StoryNodeType.firstEnding,
      speaker: 'Chim Thần',
      background: 'backgrounds/006_1_no_promise_ending.png',
      text:
          'Lòng người còn đầy nóng giận và tham cầu. Cơ hội tốt nếu không được giữ bằng sự tử tế, cũng sẽ bay đi như cánh chim trước gió.',
      nextId: 'no_promise_reflection',
    ),
    'bird_promise': StoryNode(
      id: 'bird_promise',
      title: 'Chim Thần đáp',
      type: StoryNodeType.dialogue,
      speaker: 'Chim Thần',
      background: 'backgrounds/006_bird_promise.png',
      text: 'Ăn một quả, trả cục vàng. May túi ba gang, mang đi mà đựng.',
      nextId: 'choose_bag',
    ),
    'choose_bag': StoryNode(
      id: 'choose_bag',
      title: 'Chọn túi',
      type: StoryNodeType.options,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/007_choose_bag.png',
      text:
          'Nghe lời Chim Thần, người em chuẩn bị một chiếc túi để đi lấy vàng. Nhưng trong lòng cậu vẫn phải tự quyết: nên mang vừa đủ, hay mang thật nhiều?',
      choices: [
        StoryChoice(
          label: 'May túi 3 gang',
          nextId: 'gold_island',
          karmaDelta: 1,
          unlockCollectibleIds: ['bag3', 'gold', 'feather'],
        ),
        StoryChoice(
          label: 'May túi 12 gang',
          nextId: 'gold_island_large',
          karmaDelta: -1,
          maxResultingKarma: -1,
          unlockCollectibleIds: ['bag12'],
        ),
      ],
    ),
    'bag3_unlock': StoryNode(
      id: 'bag3_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Biểu tượng của sự vừa đủ.',
      nextId: 'gold_unlock',
      unlockCollectibleId: 'bag3',
    ),
    'gold_unlock': StoryNode(
      id: 'gold_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Phần thưởng thử lòng người.',
      nextId: 'feather_unlock',
      unlockCollectibleId: 'gold',
    ),
    'bag12_unlock': StoryNode(
      id: 'bag12_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Lời nhắc về lòng tham.',
      nextId: 'gold_island_large',
      unlockCollectibleId: 'bag12',
    ),
    'gold_island': StoryNode(
      id: 'gold_island',
      title: 'Đảo vàng',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/008_gold_island.png',
      text:
          'Chim Thần cõng người em bay qua núi cao, biển rộng, rồi đáp xuống một hòn đảo lấp lánh ánh vàng.',
      nextId: 'younger_brother_prospers',
    ),
    'gold_island_large': StoryNode(
      id: 'gold_island_large',
      title: 'Đảo vàng',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/008_gold_island.png',
      text:
          'Chim Thần cõng người em đến đảo vàng. Trước ánh vàng lấp lánh, chiếc túi mười hai gang bỗng trở nên quá hấp dẫn để dừng lại.',
      nextId: 'player_bad_ending',
    ),
    'younger_brother_prospers': StoryNode(
      id: 'younger_brother_prospers',
      title: 'Phát đạt',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/009_younger_brother_prospers.png',
      text:
          'Người em trở về với túi vàng vừa đủ. Từ đó, cậu sửa lại mái nhà, giúp đỡ người nghèo và sống một cuộc đời yên ổn.',
      nextId: 'brother_returns',
    ),
    'brother_returns': StoryNode(
      id: 'brother_returns',
      title: 'Người anh',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/012_brother_returns.png',
      text:
          'Thấy người em trở nên khá giả, người anh sinh lòng tò mò. Hắn quay lại, nhìn cây khế sai quả rồi nở một nụ cười đầy tính toán.',
      nextId: 'player_decides_exchange',
    ),
    'player_decides_exchange': StoryNode(
      id: 'player_decides_exchange',
      title: 'Đổi cây khế',
      type: StoryNodeType.options,
      speaker: 'Người anh',
      background: 'backgrounds/009_younger_brother_prospers.png',
      text:
          'Chú đổi cây khế cho anh đi. Anh trả lại ruộng vườn ngày trước, còn cây khế này để anh chăm thử một mùa.',
      choices: [
        StoryChoice(
          label: 'Đồng ý đổi cây khế',
          nextId: 'brother_greed_cutscene',
          karmaDelta: 1,
        ),
        StoryChoice(
          label: 'Không đồng ý đổi cây khế',
          nextId: 'keep_tree_ending',
          karmaDelta: 0,
        ),
      ],
    ),
    'brother_greed_cutscene': StoryNode(
      id: 'brother_greed_cutscene',
      title: 'Túi lớn',
      type: StoryNodeType.dialogue,
      speaker: 'Người kể chuyện',
      background: 'backgrounds/013_brother_greed_cutscene.png',
      text:
          'Sau khi đổi được cây khế, người anh không may túi ba gang như lời dặn. Hắn lén may một chiếc túi thật lớn, mong mang về nhiều vàng hơn người em.',
      nextId: 'brother_bad_ending',
    ),
    'brother_bad_ending': StoryNode(
      id: 'brother_bad_ending',
      title: 'Người anh',
      speaker: 'Người kể chuyện',
      type: StoryNodeType.dialogue,
      background: 'backgrounds/014_brother_bad_ending.png',
      text:
          'Chiếc túi quá nặng kéo người anh chao đảo giữa trời. Vàng rơi tung tóe xuống biển, còn hắn hoảng hốt nhận ra lòng tham đã trở thành gánh nặng không thể giữ nổi.',
      nextId: 'brother_bad_first_ending',
    ),
    'brother_bad_first_ending': StoryNode(
      id: 'brother_bad_first_ending',
      title: 'Kết cục',
      type: StoryNodeType.firstEnding,
      background: 'backgrounds/ending_bg.png',
      text:
          'Người em đứng lặng nhìn về phía trước, hiểu rằng có những mất mát không thể níu lại. Câu chuyện của người anh khép lại bằng cái giá của lòng tham, để người ở lại phải tự giữ lấy phần sáng trong lòng mình.',
      nextId: 'brother_bad_reflection',
    ),
    'player_bad_ending': StoryNode(
      id: 'player_bad_ending',
      title: 'Lòng tham',
      type: StoryNodeType.firstEnding,
      background: 'backgrounds/011_player_bad_ending.png',
      text:
          'Người em chọn chiếc túi quá lớn và cố nhét thật nhiều vàng. Khi Chim Thần bay qua biển, chiếc túi nặng khiến cậu không còn giữ được thăng bằng.',
      nextId: 'player_bad_reflection',
    ),
    'keep_tree_ending': StoryNode(
      id: 'keep_tree_ending',
      title: 'Giữ lấy cây khế',
      type: StoryNodeType.dialogue,
      speaker: "Người kể chuyện",
      background: 'backgrounds/009_younger_brother_prospers.png',
      text:
          'Người em mỉm cười từ chối. Cây khế không chỉ là của cải, mà là bài học về sự vừa đủ và lòng biết ơn cậu muốn tự mình gìn giữ.',
      nextId: 'keep_tree_first_ending',
    ),
    'keep_tree_first_ending': StoryNode(
      id: 'keep_tree_first_ending',
      title: 'Giữ lấy cây khế',
      type: StoryNodeType.firstEnding,
      background: 'backgrounds/first_positive_ending_bg.png',
      text:
          'Người em giữ lại cây khế và tiếp tục sống một cuộc đời bình yên. Cậu hiểu rằng biết đủ không có nghĩa là từ bỏ điều quý giá, mà là biết trân trọng và bảo vệ điều thực sự thuộc về mình.',
      nextId: 'keep_tree_reflection',
    ),
    'early_bad_reflection': StoryNode(
      id: 'early_bad_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Khi phần hơn trở thành điều duy nhất được nhìn thấy, con đường tốt đẹp cũng mất đi trước mắt.',
      reflectionTitle: 'Người đã để lòng tham đi trước tình thân.',
      nextId: 'early_bad_summary',
    ),
    'no_promise_reflection': StoryNode(
      id: 'no_promise_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Không phải cơ hội nào cũng quay lại. Có lúc một lời nóng giận đủ làm cánh cửa lành bay xa.',
      reflectionTitle: 'Người đã đánh rơi cơ duyên với Chim Thần.',
      nextId: 'no_promise_summary',
    ),
    'enough_reflection': StoryNode(
      id: 'enough_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Điều khó nhất trên đời không phải là kiếm được thật nhiều, mà là biết khi nào đã đủ.',
      reflectionTitle: 'Người đã biết dừng lại.',
      nextId: 'enough_ending',
    ),
    'player_bad_reflection': StoryNode(
      id: 'player_bad_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Chiếc túi càng lớn, đường về càng nặng. Lòng tham đôi khi bắt đầu từ một ý nghĩ rất nhỏ.',
      reflectionTitle: 'Người đã để vàng nặng hơn mạng sống.',
      nextId: 'player_bad_summary',
    ),
    'brother_bad_reflection': StoryNode(
      id: 'brother_bad_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Có những hậu quả không đến từ lựa chọn của ta, nhưng vẫn nhắc ta vì sao cần giữ lòng mình sáng.',
      reflectionTitle: 'Người đã chứng kiến cái giá của lòng tham.',
      nextId: 'brother_bad_summary',
    ),
    'keep_tree_reflection': StoryNode(
      id: 'keep_tree_reflection',
      title: 'Nghiệp lực',
      type: StoryNodeType.karma,
      text:
          'Biết chia sẻ không có nghĩa là trao đi mọi điều quý giá. Có khi giữ lại cũng là một cách sống có trách nhiệm.',
      reflectionTitle: 'Người đã giữ được điều cần giữ.',
      nextId: 'keep_tree_summary',
    ),
    'feather_unlock': StoryNode(
      id: 'feather_unlock',
      title: 'Đã mở khóa',
      type: StoryNodeType.unlock,
      text: 'Biểu tượng của cơ duyên, phần thưởng và lòng tốt được đền đáp.',
      nextId: 'enough_ending',
      unlockCollectibleId: 'feather',
    ),
    'early_bad_summary': StoryNode(
      id: 'early_bad_summary',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/early_bad_ending.png',
      coverAlignmentY: -0.3,
      text: 'Mất cây khế',
      endingId: 'early_bad',
    ),
    'no_promise_summary': StoryNode(
      id: 'no_promise_summary',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/006_1_no_promise_ending.png',
      coverAlignmentY: -0.45,
      text: 'Chim Thần rời đi',
      endingId: 'no_promise',
    ),
    'enough_ending': StoryNode(
      id: 'enough_ending',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/first_positive_ending_bg.png',
      coverAlignmentY: -0.2,
      text: 'Con đường biết đủ',
      endingId: 'enough',
    ),
    'player_bad_summary': StoryNode(
      id: 'player_bad_summary',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/011_player_bad_ending.png',
      coverAlignmentY: -0.25,
      text: 'Người em rơi xuống biển',
      endingId: 'player_bad',
    ),
    'brother_bad_summary': StoryNode(
      id: 'brother_bad_summary',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/ending_bg.png',
      coverAlignmentY: -0.15,
      text: 'Tấm lòng vị tha của người em',
      endingId: 'brother_bad',
    ),
    'keep_tree_summary': StoryNode(
      id: 'keep_tree_summary',
      title: 'Kết cục của bạn',
      type: StoryNodeType.ending,
      background: 'backgrounds/009_younger_brother_prospers.png',
      coverAlignmentX: -0.2,
      coverAlignmentY: -0.6,
      text: 'Giữ lấy cây khế',
      endingId: 'keep_tree',
    ),
  };

  static String unlockNodeIdForCollectible(String collectibleId) {
    return switch (collectibleId) {
      'starfruit' => 'starfruit_unlock',
      'half' => 'half_unlock',
      'bag3' => 'bag3_unlock',
      'gold' => 'gold_unlock',
      'bag12' => 'bag12_unlock',
      'feather' => 'feather_unlock',
      _ => 'feather_unlock',
    };
  }

  static StoryNode node(
    String id, {
    AppLanguage language = AppLanguage.vietnamese,
  }) {
    final node = nodes[id] ?? nodes[startNodeId]!;
    return language == AppLanguage.english
        ? EnglishStoryContent.localize(node)
        : node;
  }
}
