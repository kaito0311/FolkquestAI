import 'package:fqa/models/story_choice.dart';
import 'package:fqa/models/story_node.dart';

/// English copy keeps the original node ids and game mechanics intact.
class EnglishStoryContent {
  static StoryNode localize(StoryNode node) {
    final copy = _copy[node.id];
    if (copy == null) return node;
    return node.copyWith(
      title: copy.title,
      speaker: copy.speaker,
      text: copy.text,
      reflectionTitle: copy.reflectionTitle,
      choices: copy.choiceLabels == null
          ? null
          : List.generate(
              node.choices.length,
              (index) =>
                  _choice(node.choices[index], copy.choiceLabels![index]),
            ),
    );
  }

  static StoryChoice _choice(StoryChoice choice, String label) => StoryChoice(
    label: label,
    nextId: choice.nextId,
    karmaDelta: choice.karmaDelta,
    maxResultingKarma: choice.maxResultingKarma,
    unlockCollectibleIds: choice.unlockCollectibleIds,
  );

  static const _copy = <String, _Copy>{
    'start_intro': _Copy(
      'The story begins',
      'Narrator',
      'Long ago, two brothers lived together in a small village. You are the kind younger brother, and your choices will shape the story.',
    ),
    'father_passes_away': _Copy(
      'Their father passes away',
      'Narrator',
      'After their father dies, the house falls quiet. The brothers must divide the inheritance, though neither finds it easy to say what is fair.',
    ),
    'divide_inheritance': _Copy(
      'Dividing the inheritance',
      'Older brother',
      'From now on, live on your own. I will keep the fields and house. Take the starfruit tree behind the garden and make a life with it.',
      choiceLabels: ['Accept the starfruit tree', 'Ask for a fair share'],
    ),
    'starfruit_unlock': _Copy(
      'Unlocked',
      null,
      'A small inheritance opens a new path.',
    ),
    'half_unlock': _Copy(
      'Unlocked',
      null,
      'A symbol of asking for a fair division of the inheritance.',
    ),
    'accept_starfruit_tree': _Copy(
      'Acceptance',
      'Younger brother',
      'The younger brother accepts the modest share. He does not want wealth to destroy their bond, and hopes the tree will sustain him.',
    ),
    'inheritance_argument': _Copy(
      'The inheritance dispute',
      'Narrator',
      'The younger brother does not wish to quarrel, but the division still does not feel fair.',
      choiceLabels: [
        'Speak calmly and reasonably',
        'Argue in anger',
        'Demand more because you are younger',
      ],
    ),
    'fair_argument': _Copy(
      'A fair request',
      'Younger brother',
      'The younger brother keeps his voice calm. He asks his brother to think again, then accepts caring for the tree when he sees the decision is final.',
    ),
    'angry_argument': _Copy(
      'Anger rises',
      'Narrator',
      'Harsh words make the courtyard heavy. The younger brother leaves in anger, hurt by his meagre share.',
    ),
    'early_bad_ending': _Copy(
      'An opportunity closes',
      null,
      'By demanding more, the younger brother loses even the bond that remained. The starfruit tree is no longer his, and the story of gold ends before it begins.',
    ),
    'starfruit_tree': _Copy(
      'The starfruit tree',
      'Narrator',
      'From the day he receives it, the younger brother tends the tree every day. It grows lush and bears fruit in every season.',
    ),
    'bird_appears': _Copy(
      'The Magic Bird',
      'Narrator',
      'One day, a great bird lands in the starfruit tree and eats its ripe golden fruit. The younger brother is surprised and worried.',
      choiceLabels: [
        'Gently speak to the Magic Bird',
        'Chase the bird away with a stick',
      ],
    ),
    'gentle_complaint': _Copy(
      'Meeting the Magic Bird',
      'Younger brother',
      'The younger brother says softly: “If you eat all the fruit, how will my family live? If you need it, please leave me a way to earn a living.”',
    ),
    'chase_bird': _Copy(
      'Chasing the Magic Bird',
      'Narrator',
      'Fearing the loss of all his fruit, the younger brother runs out with a stick. The Magic Bird flies up, its gaze seeming to see into his heart.',
    ),
    'karma_check': _Copy('Karma', null, ''),
    'no_promise_ending': _Copy(
      'The Magic Bird leaves',
      'Magic Bird',
      'Your heart is still full of anger and greed. A good opportunity that is not held with kindness can fly away like a bird in the wind.',
    ),
    'bird_promise': _Copy(
      'The Magic Bird replies',
      'Magic Bird',
      'Eat one fruit, repay one lump of gold. Sew a three-span bag, and carry it away.',
    ),
    'choose_bag': _Copy(
      'Choose a bag',
      'Narrator',
      'Following the Magic Bird’s words, the younger brother prepares a bag for gold. But he must decide: take enough, or take too much?',
      choiceLabels: ['Sew a three-span bag', 'Sew a twelve-span bag'],
    ),
    'bag3_unlock': _Copy(
      'Unlocked',
      null,
      'A symbol of knowing what is enough.',
    ),
    'gold_unlock': _Copy('Unlocked', null, 'A reward that tests the heart.'),
    'bag12_unlock': _Copy('Unlocked', null, 'A reminder about greed.'),
    'gold_island': _Copy(
      'The Island of Gold',
      'Narrator',
      'The Magic Bird carries the younger brother over high mountains and wide seas to an island glittering with gold.',
    ),
    'gold_island_large': _Copy(
      'The Island of Gold',
      'Narrator',
      'The Magic Bird carries the younger brother to the island. Before the glittering gold, the twelve-span bag becomes too tempting to leave empty.',
    ),
    'younger_brother_prospers': _Copy(
      'A good life',
      'Narrator',
      'The younger brother returns with just enough gold. He repairs his home, helps those in need, and lives peacefully.',
    ),
    'brother_returns': _Copy(
      'The older brother',
      'Narrator',
      'Seeing his younger brother prosper, the older brother grows curious. He returns, sees the fruitful tree, and smiles with calculation.',
    ),
    'player_decides_exchange': _Copy(
      'Exchange the tree',
      'Older brother',
      'Trade the starfruit tree to me. I will return the old fields, and I will care for this tree for one season.',
      choiceLabels: [
        'Agree to exchange the tree',
        'Refuse to exchange the tree',
      ],
    ),
    'brother_greed_cutscene': _Copy(
      'A large bag',
      'Narrator',
      'After gaining the tree, the older brother ignores the three-span instruction. He secretly sews a huge bag, hoping for more gold than his brother.',
    ),
    'brother_bad_ending': _Copy(
      'The older brother',
      'Narrator',
      'The heavy bag makes the older brother sway in the sky. Gold falls into the sea as he realizes that greed has become a burden he cannot carry.',
    ),
    'brother_bad_first_ending': _Copy(
      'The ending',
      null,
      'The younger brother watches quietly. Some losses cannot be called back; the older brother’s story closes with the price of greed.',
    ),
    'player_bad_ending': _Copy(
      'Greed',
      null,
      'The younger brother chooses a bag that is too large and fills it with gold. Over the sea, its weight makes him lose his balance.',
    ),
    'keep_tree_ending': _Copy(
      'Keep the starfruit tree',
      'Narrator',
      'The younger brother smiles and refuses. The tree is not only wealth; it is a lesson in gratitude and knowing what is enough.',
    ),
    'keep_tree_first_ending': _Copy(
      'Keep the starfruit tree',
      null,
      'The younger brother keeps the tree and continues his peaceful life. Knowing what is enough also means protecting what truly belongs to you.',
    ),
    'early_bad_reflection': _Copy(
      'Karma',
      null,
      'When having more becomes the only thing we see, a good path can disappear before our eyes.',
      reflectionTitle: 'Greed was placed before family.',
    ),
    'no_promise_reflection': _Copy(
      'Karma',
      null,
      'Not every opportunity returns. Sometimes one angry outburst is enough to make a kind door close.',
      reflectionTitle: 'The chance with the Magic Bird was lost.',
    ),
    'enough_reflection': _Copy(
      'Karma',
      null,
      'The hardest thing in life is not gaining a great deal, but knowing when we have enough.',
      reflectionTitle: 'You knew when to stop.',
    ),
    'player_bad_reflection': _Copy(
      'Karma',
      null,
      'The larger the bag, the heavier the journey home. Greed can begin with a very small thought.',
      reflectionTitle: 'Gold was made heavier than life.',
    ),
    'brother_bad_reflection': _Copy(
      'Karma',
      null,
      'Some consequences do not come from our own choices, but they still remind us to keep our hearts clear.',
      reflectionTitle: 'You witnessed the price of greed.',
    ),
    'keep_tree_reflection': _Copy(
      'Karma',
      null,
      'Sharing does not mean giving away everything precious. Sometimes keeping something is a responsible choice.',
      reflectionTitle: 'You protected what needed protecting.',
    ),
    'feather_unlock': _Copy(
      'Unlocked',
      null,
      'A symbol of good fortune, reward, and kindness repaid.',
    ),
    'early_bad_summary': _Copy(
      'Your ending',
      null,
      'The starfruit tree is lost.',
    ),
    'no_promise_summary': _Copy('Your ending', null, 'The Magic Bird leaves.'),
    'enough_ending': _Copy('Your ending', null, 'The path of knowing enough.'),
    'player_bad_summary': _Copy(
      'Your ending',
      null,
      'The younger brother falls into the sea.',
    ),
    'brother_bad_summary': _Copy(
      'Your ending',
      null,
      'The younger brother’s compassion.',
    ),
    'keep_tree_summary': _Copy('Your ending', null, 'Keep the starfruit tree.'),
  };
}

class _Copy {
  const _Copy(
    this.title,
    this.speaker,
    this.text, {
    this.reflectionTitle,
    this.choiceLabels,
  });
  final String title;
  final String? speaker;
  final String text;
  final String? reflectionTitle;
  final List<String>? choiceLabels;
}
