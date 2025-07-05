import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:japa_counter/models/quote_model.dart';

class QuotesService {
  static const String _customQuotesKey = 'custom_quotes';
  static const String _favoriteQuotesKey = 'favorite_quotes';
  
  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get all built-in quotes
  static List<Quote> get builtInQuotes {
    final now = DateTime.now();
    return _builtInQuoteData.map((data) => Quote(
      id: 'builtin_${_builtInQuoteData.indexOf(data)}',
      text: data['quote']!,
      author: data['author']!,
      type: QuoteType.text,
      createdAt: now,
    )).toList();
  }

  // Get built-in image quotes
  static List<Quote> get builtInImageQuotes {
    final now = DateTime.now();
    return [
      Quote(
        id: 'image_1',
        text: 'Daily Spiritual Wisdom',
        author: 'A.C. Bhaktivedanta Swami Prabhupāda',
        type: QuoteType.image,
        imageUrl: 'http://harekrishnacalendar.com/wp-content/uploads/2012/09/Srila-Prabhupada-Quotes-For-Month-July-07.png',
        createdAt: now,
      ),
      // Add more image quotes as needed
    ];
  }

  // Get all custom quotes
  static Future<List<Quote>> getCustomQuotes() async {
    final prefs = await _prefs;
    final quotesJson = prefs.getStringList(_customQuotesKey) ?? [];
    
    return quotesJson
        .map((quoteString) => Quote.fromJson(json.decode(quoteString)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get all quotes (built-in + custom)
  static Future<List<Quote>> getAllQuotes() async {
    final customQuotes = await getCustomQuotes();
    final allQuotes = <Quote>[];
    
    // Add built-in text quotes
    allQuotes.addAll(builtInQuotes);
    
    // Add built-in image quotes
    allQuotes.addAll(builtInImageQuotes);
    
    // Add custom quotes
    allQuotes.addAll(customQuotes);
    
    return allQuotes;
  }

  // Get quotes by type
  static Future<List<Quote>> getQuotesByType(QuoteType type) async {
    final allQuotes = await getAllQuotes();
    return allQuotes.where((quote) => quote.type == type).toList();
  }

  // Get favorite quotes
  static Future<List<Quote>> getFavoriteQuotes() async {
    final prefs = await _prefs;
    final favoriteIds = prefs.getStringList(_favoriteQuotesKey) ?? [];
    final allQuotes = await getAllQuotes();
    
    return allQuotes.where((quote) => favoriteIds.contains(quote.id)).toList();
  }

  // Add custom quote
  static Future<void> addCustomQuote(String text, String author) async {
    final customQuotes = await getCustomQuotes();
    
    final newQuote = Quote(
      id: _generateId(),
      text: text,
      author: author,
      type: QuoteType.custom,
      createdAt: DateTime.now(),
    );
    
    customQuotes.add(newQuote);
    await _saveCustomQuotes(customQuotes);
  }

  // Update custom quote
  static Future<void> updateCustomQuote(String id, String text, String author) async {
    final customQuotes = await getCustomQuotes();
    final index = customQuotes.indexWhere((quote) => quote.id == id);
    
    if (index >= 0) {
      customQuotes[index] = customQuotes[index].copyWith(
        text: text,
        author: author,
        updatedAt: DateTime.now(),
      );
      await _saveCustomQuotes(customQuotes);
    }
  }

  // Delete custom quote
  static Future<void> deleteCustomQuote(String id) async {
    final customQuotes = await getCustomQuotes();
    customQuotes.removeWhere((quote) => quote.id == id);
    await _saveCustomQuotes(customQuotes);
    
    // Also remove from favorites if it exists
    await removeFavorite(id);
  }

  // Toggle favorite status
  static Future<void> toggleFavorite(String quoteId) async {
    final prefs = await _prefs;
    final favoriteIds = prefs.getStringList(_favoriteQuotesKey) ?? [];
    
    if (favoriteIds.contains(quoteId)) {
      favoriteIds.remove(quoteId);
    } else {
      favoriteIds.add(quoteId);
    }
    
    await prefs.setStringList(_favoriteQuotesKey, favoriteIds);
  }

  // Remove from favorites
  static Future<void> removeFavorite(String quoteId) async {
    final prefs = await _prefs;
    final favoriteIds = prefs.getStringList(_favoriteQuotesKey) ?? [];
    favoriteIds.remove(quoteId);
    await prefs.setStringList(_favoriteQuotesKey, favoriteIds);
  }

  // Check if quote is favorite
  static Future<bool> isFavorite(String quoteId) async {
    final prefs = await _prefs;
    final favoriteIds = prefs.getStringList(_favoriteQuotesKey) ?? [];
    return favoriteIds.contains(quoteId);
  }

  // Search quotes
  static Future<List<Quote>> searchQuotes(String query) async {
    if (query.trim().isEmpty) return [];
    
    final allQuotes = await getAllQuotes();
    final lowerQuery = query.toLowerCase();
    
    return allQuotes.where((quote) {
      final textMatch = quote.text.toLowerCase().contains(lowerQuery);
      final authorMatch = quote.author.toLowerCase().contains(lowerQuery);
      
      return textMatch || authorMatch;
    }).toList();
  }

  // Get random quote
  static Future<Quote> getRandomQuote() async {
    final allQuotes = await getAllQuotes();
    final textQuotes = allQuotes.where((q) => q.type == QuoteType.text).toList();
    
    if (textQuotes.isEmpty) return builtInQuotes.first;
    
    final randomIndex = DateTime.now().microsecond % textQuotes.length;
    return textQuotes[randomIndex];
  }

  // Get quote of the day (based on current date)
  static Future<Quote> getQuoteOfTheDay() async {
    final allQuotes = await getAllQuotes();
    final textQuotes = allQuotes.where((q) => q.type == QuoteType.text).toList();
    
    if (textQuotes.isEmpty) return builtInQuotes.first;
    
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % textQuotes.length;
    
    return textQuotes[quoteIndex];
  }

  // Private helper methods
  static Future<void> _saveCustomQuotes(List<Quote> quotes) async {
    final prefs = await _prefs;
    final quotesJson = quotes
        .map((quote) => json.encode(quote.toJson()))
        .toList();
    
    await prefs.setStringList(_customQuotesKey, quotesJson);
  }

  // Built-in quotes data
  static const List<Map<String, String>> _builtInQuoteData = [
    {
      "quote": "Living beings who are entangled in the complicated meshes of birth and death can be freed immediately by even unconsciously chanting the holy name of Kṛṣṇa, which is feared by fear personified.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "The transcendental loving service of the Lord is performed in three ways – with the body, with the mind and with words. Here the sages pray that their words may always be engaged in glorifying the Supreme Lord.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Anyone who is steady in his determination for the advanced stage of spiritual realization and can equally tolerate the onslaughts of distress and happiness is certainly a person eligible for liberation.",
      "author": "A.C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "When one waters the root of a tree, he automatically waters the branches, twigs, leaves and flowers; when one supplies food to the stomach through the mouth, he satisfies all the various parts of the body.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "My dear Arjuna, only by undivided devotional service can I be understood as I am, standing before you, and can thus be seen directly. Only in this way can you enter into the mysteries of My understanding.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Even if the Hare Kṛṣṇa mantra is not chanted properly, it still has so much potency that the chanter gains the effect.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda, Srimad-Bhagavatam, Fourth Canto"
    },
    {
      "quote": "The living being is in the state of forgetfulness of his relation with God due to his being overly attracted to material sense gratification from time immemorial.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "If by studying Bhagavad-gītā one decides to surrender to Kṛṣṇa, he is immediately freed from all sinful reactions.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "For man, mind is the cause of bondage and mind is the cause of liberation. Mind absorbed in sense objects is the cause of bondage, and mind detached from the sense objects is the cause of liberation.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Because materialists cannot understand Krsna spiritually, they are advised to concentrate the mind on physical things and try to see how Krsna is manifested by physical representations.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "The Lord is more anxious to take us back into His kingdom than we can desire. Most of us do not desire at all to go back to Godhead. Only a very few men want to go back to Godhead. But anyone who desires to go back to Godhead, Śrī Kṛṣṇa helps in all respects.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Never expect any good from the so-called society, friendship and love, Only Krishna is the genuine friend of all living beings and it is He only who can give us all benedictions.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "All the Vedic literatures and the Purāṇas are meant for conquering the darkest region of material existence.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "A yogī is greater than the ascetic, greater than the empiricist and greater than the fruitive worker. Therefore, O Arjuna, in all circumstances, be a yogī.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "The humble sage, by virtue of true knowledge, sees with equal vision a learned and gentle brāhmaṇa, a cow, an elephant, a dog, and a dog-eater.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "First-class religion teaches one how to love God without any motive. If I serve God for some profit, that is business—not love.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "The art of focusing one's attention on the Supreme and giving one's love to Him is called Kṛṣṇa consciousness.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Krishna may crush our ego, pulverize it, crush it to powder, make it into granules. Do we still continue to remain faithful to Krishna?",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Therefore the process of devotional service is always a success.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Selfishness is either self-centered or self-extended.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "So it is our request that you try to study Bhagavad-gītā as it is. Don't try to distort it by your so-called education. Try to understand Kṛiṣṇa as He is saying. Then you will be benefited. Your life will be successful.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "There is a proverb in Bengali that a bad king spoils the kingdom and a bad housewife spoils the family.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "One cannot reach the real point of factual knowledge without being helped by the right person who is already established in that knowledge.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Their idea is that marriage is for legalized prostitution. They think like that, but that is not marriage.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Bhakti-yoga means vairāgya-vidyā, the art that can help one develop a distaste for material enjoyment.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Our only business is to love God, not to ask God for our necessities.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "If we are serious and sincere devotees, the Lord will give us the intelligence to offer prayers properly.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Actual devotees and saintly persons are always anxious to see how the people can be made happy both materially and spiritually.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "To become free from sinful life, there is only one simple method: if you surrender to Kṛṣṇa. That is the beginning of bhakti.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "Religion means to know God and to love Him.",
      "author": "A. C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "The life of material existence is just like hard wood, and if we carve Krishna out of it, that will be success of our life.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Devotional service is more or less a declaration of war against the illusory energy.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Don't feel yourself to be alone because GOD is always with you.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "The big fish, shark, they do not come into the river. They constantly remain in the ocean. Similarly, those who are pure devotees always remain in the ocean of transcendental loving service to the Lord.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "One whose happiness is within, who is active within, who rejoices within and is illumined within, is actually the perfect mystic. He is liberated in the Supreme, and ultimately he attains the Supreme.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "It has been stated, 'although Srimati Radharani developed a deep loving affection for Krsna, She hid Her attitude in the core of Her heart so that others could not detect Her actual condition.",
      "author": "A.C. Bhaktivedanta Swami Prabhupada"
    },
    {
      "quote": "Religion without philosophy is sentiment, or sometimes fanaticism, while philosophy without religion is mental speculation.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Modern man has struggled very hard to reach the moon, but he has not tried very hard to elevate himself spiritually.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Material qualifications are decorations on a dead body.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Out of many thousands among men, one may endeavor for perfection, and of those who have achieved perfection, hardly one knows Me in truth.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Ātmā, or self, is distinguished from matter and material elements. It is spiritual in constitution, and thus it is never satisfied by any amount of material planning.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Sometimes the Lord arranges an unfortunate wife for His devotee so that gradually, due to family circumstances, the devotee becomes detached from his wife and home and makes progress in devotional life.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Krishna Consciousness is so nice that if one takes part in it in either ways, like hearing, chanting, remembering, worshiping, praying, or even simply by eating prasadam, the transcendental effect will be visible.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "This is the age of Kali which plunders away the spiritual sense of human beings and it is only the Divine Grace of Lord Chaitanya, Who can protect us from all these dangerous pitfalls.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "A person, who is always anxious to render service unto the Supreme Lord Hari, as His eternal servitor, in all conditions of life is considered to be liberated even though within the material body.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Maya is very strong and as soon as there is opportunity Maya will attack. Therefore one should be very careful against the attack of Maya. And the only effective defense is to remain Krishna consciousness always.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Difficulties of life may come as seasonal changes but we should not be disturbed by all those difficulties. Our process is to chant and that process will gradually clear everything in due course.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Anyone's special talent should be engaged in the service of the Lord, and thereby become successful in life. We are not meant for learning something new for the service of the Lord; but we have to engage whatever talents we have already got.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "A child is a rare gift given by Krishna, but at the same time a great responsibility; every parent has the responsibility to see that his child grows up Krishna consciousness.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Always remember Krishna Who is your dearest most friend and always serve Him just to please Him, and He will give you all intelligence how to be a first-class devotee.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Those who take Krishna's advent as that of an ordinary man are great fools, but if one can simply understand the transcendental nature of this event as well as His disappearance, he becomes immediately liberated.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Krishna consciousness is the process of eternal life. The process is simple and the results are sublime. You follow it and you will be happy in this life as well as in the next.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Chant Hare Krishna sincerely and all good intelligence consultation shall come from within. Krishna says that, 'those who are engaged in My service, I give intelligence for his progressive march'.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Vedanta means ultimate knowledge. Knowledge is never perfect unless one comes to the point of understanding Krishna. To remain in Krishna Consciousness is actual understanding of Vedanta.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "If we are always afraid of our mistakes, Krishna will save us from all such misgivings and even if we imperceptibly commit some mistake, He will forgive us. But we should be always very careful not to commit mistakes.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Chanting of Hare Krishna is not meant for achieving any other better thing than Krishna. But when we chant Hare Krishna without any offense, we relish Krishna, the Reservoir of all pleasure.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "One should always remain active in Krishna's service; otherwise the strong maya will catch him and engage him in her service.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Without cleaning the mind, nobody can advance in spiritual understanding. And the chanting of Hare Krishna is the cleansing process of the mind. That is our motto.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Your body is dedicated to Krishna; therefore you should not be neglectful about your body. You should always think that your body is no more your body, but it is Krishna's body. Therefore you should take care of it.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Our business is to try our best. Result we leave it for consideration of Krishna, and we shall not be disappointed whether the result is favorable or unfavorable. Actually there cannot be any unfavorable result, because we are serving Krishna.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "It is your good fortune that you can serve Krishna in so many ways—to work, to write, to speak, to paint, to build—all of these talents must be employed in Krishna's service. That will make you perfect.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "In humble submission the devotee finds such sweet transcendental pleasure that no more he is interested in the nonsense material world and no more he is affected by the influence of the inferior energy, the maya.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Dedicate your life for Krishna. Even if there are some faults, dedicated life is noble life. Maybe, due to our past habits, we may commit some faulty action, but that dedicated life is sublime.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "When one becomes accustomed to inoffensive chanting, then his fruit is that he is promoted to the stage of pure Love of Godhead, or prema. This prema is the perfectional stage of consciousness and the most blissful by very far.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "There are four classes of men: lazy intelligent, busy intelligent, lazy fool and busy fool. First-class man is lazy intelligent. Busy fool is very dangerous.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "We should always remember that our body is not for sense gratification; it is for Krishna's service only. And to render very good sound service to Krishna we should not neglect the upkeep of the body.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "This Krishna consciousness temple is the hospital for the diseased spirit soul. And everyone is diseased. Come to this hospital. We shall take care of you and cure your material disease.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Cleanliness is next to Godliness. This point should be very carefully observed, and then you will advance very quickly to the perfectional stage of Krishna consciousness.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "If you want perfection in your business, then you must try to satisfy the Supreme Personality of Godhead. Otherwise you are simply wasting your time.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Krishna is Controller and we are controlled. When we simply remember to accept the control of Krishna and not to act independently then all fortune is automatically present.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Simply engage yourself in Krishna's service. That will protect you from any attack of maya. Maya can take Krishna's place in our heart as soon as there is a slackness on our part. Otherwise, if Krishna's seated always, maya has no opportunity to occupy the seat.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Everything in the Temple should be kept nice and clean. Everyone should wash hands before touching anything of Krishna's. We should always remember that Krishna is the purest & similarly only the pure can associate with Him. Cleanliness is next to Godliness.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "\"Money is the honey\" goes so far as it is employed for Krishna consciousness. The body is undoubtedly a material vehicle but when it acts for Krishna consciousness it becomes spiritualized. By the grace of Krishna, material energy can be transformed to spiritual energy & spiritual energy is never deteriorated. To be in Krishna consciousness means to be in spiritual energy.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "If a man thinks that chanting will save him from all kinds of sinful reaction deliberately committed by him, then he becomes the greatest offender. By chanting Hare Krishna certainly we become free from all sinful reactions, but that does not mean that we shall deliberately commit sins and counteract it by chanting.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "On the Absolute world there are no such relativities as success and failure. The one thing in the Absolute world is to serve Krishna. Don't care for the result. Krishna must know that we are working very seriously and that is our success of life.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Devotional service means to apply one's energy in the service of Krishna. That is the instruction of the Bhagavad-gita… we cannot understand about Krishna with our limited potency and senses, but if we engage ourselves in the service of the Lord, He will reveal Himself to the faithful servitor… The more we learn about Krishna from the authoritative sources, the more we can be attached in Krishna Consciousness.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Less intelligent persons are very much interested in dreaming life, but one who is intelligent enough searches after eternal life. The modern civilization does not understand what eternal life is. They are busy with the spot life of 50 or 100 years. Fools cannot think that one is not for 50 or 100 years, but one is for eternity. Krishna consciousness is the life of eternity.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "We should utilize our time for elevating ourselves in Krishna Consciousness than for so-called economic development. If we are satisfied with plain living, with minimum time and the balance time is engaged for elevating our Krishna Conscious program, then every man can be transferred to Goloka Vrindavana, just in this very life.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
    {
      "quote": "Any one of us can be arrested by Maya at any moment if we are not strongly attached to Krishna Consciousness. So my request to you and all others is to follow the principles of Krishna Consciousness adherently and there is no danger however strong the Maya may be.",
      "author": "A.C. Bhaktivedanta Swami Prabhupāda"
    },
  ];
} 