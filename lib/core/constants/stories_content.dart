import '../models/story_models.dart';

/// Hikâyeler sekmesi içerik verisi — metinler ve katalog tek noktadan
/// yönetilir. [demoStories] veri katmanı bağlanana kadar ekranı dolu
/// gösteren yer tutucu katalogdur.
abstract final class StoriesContent {
  static const List<Story> demoStories = <Story>[
    Story(
      id: 'story-lost-key',
      title: 'The Lost Key',
      category: 'Klasik',
      levelIndex: 0,
      coverAsset: 'assets/images/Bibliophile-rafiki.png',
      lastReadSentenceIndex: 2,
      sentences: <String>[
        'Tom came home late on a cold Tuesday night.',
        'He put his bag down and looked for his key.',
        'The key was not in his pocket.',
        'He checked his bag, but it was empty too.',
        'The street lamp lit the small garden in front of him.',
        'Then he heard a sound behind the old door.',
        'It was his cat, sitting on a soft brown box.',
        'Under the box lay the key, quiet and safe.',
      ],
    ),
    Story(
      id: 'story-new-start',
      title: 'A New Start in Town',
      category: 'Günlük Hayat',
      levelIndex: 0,
      coverAsset: 'assets/images/Welcome-rafiki.png',
      sentences: <String>[
        'Anna moved to a new town last week.',
        'She does not know any street or any name yet.',
        'In the morning she buys warm bread and coffee.',
        'The baker smiles and says her name correctly.',
        'After class she walks home through the park.',
        'Now the town feels a little bit like hers.',
      ],
    ),
    Story(
      id: 'story-english-teacher',
      title: 'The English Teacher',
      category: 'Günlük Hayat',
      levelIndex: 1,
      coverAsset: 'assets/images/English teacher-rafiki.png',
      sentences: <String>[
        'Mr. Reed teaches English at a small school.',
        'He never writes long rules on the board.',
        'Instead he asks his students to tell short stories.',
        'At first nobody wants to speak in front of class.',
        'Then a shy girl named Lena reads two sentences.',
        'The whole room claps, and the lesson changes forever.',
        'Today every student brings one page of their own story.',
      ],
    ),
    Story(
      id: 'story-morning-office',
      title: 'Morning at the Office',
      category: 'İş Yaşamı',
      levelIndex: 1,
      coverAsset: 'assets/images/Work time-rafiki.png',
      isRead: true,
      sentences: <String>[
        'The office opens at eight thirty on weekdays.',
        'Kerem always arrives first and turns on the lights.',
        'By nine, the phones start ringing one by one.',
        'His manager sends a short message about the new plan.',
        'They meet at ten and share the tasks for the week.',
        'Lunch is quiet, and everybody reads something on a screen.',
        'At six the lights go off, and the day is finished.',
      ],
    ),
    Story(
      id: 'story-job-interview',
      title: 'The Job Interview',
      category: 'İş Yaşamı',
      levelIndex: 2,
      coverAsset: 'assets/images/Customer Survey-rafiki.png',
      sentences: <String>[
        'Selin waited in a bright room with two chairs.',
        'She practised her answers on the way to the building.',
        'The interviewer asked why she left her previous job.',
        'She spoke slowly, because she wanted to be clear.',
        'Then they talked about a project that had failed badly.',
        'She explained what she learned from that mistake.',
        'Outside, she realised that she had actually enjoyed it.',
      ],
    ),
    Story(
      id: 'story-two-languages',
      title: 'Two Languages, One Meaning',
      category: 'Günlük Hayat',
      levelIndex: 2,
      coverAsset: 'assets/images/Online translator-rafiki.png',
      sentences: <String>[
        'A translator carries meaning, not only words.',
        'Deniz learned this the hard way at the airport.',
        'He had to explain a medical form to a doctor.',
        'The machine gave a funny but useless sentence.',
        'So he used simple words and drew a small map.',
        'The doctor understood, and the patient got help.',
      ],
    ),
    Story(
      id: 'story-seven-days',
      title: 'Around the World in Seven Days',
      category: 'Seyahat',
      levelIndex: 2,
      coverAsset: 'assets/images/To the stars-rafiki.png',
      sentences: <String>[
        'The trip began with a delay of four hours.',
        'Mert had never slept in an airport before that night.',
        'In the morning he flew to a city built on hills.',
        'Every street smelled of salt, bread and petrol.',
        'He wrote one postcard a day and never sent them.',
        'On the last day he read all seven cards at once.',
        'They described a person he would like to become.',
      ],
    ),
    Story(
      id: 'story-vowels',
      title: 'Vowels and Other Strange Creatures',
      category: 'Macera',
      levelIndex: 3,
      coverAsset: 'assets/images/Vowels-rafiki.png',
      sentences: <String>[
        'The five vowels lived in a small wooden box.',
        'Each of them insisted on being the most useful.',
        'One morning the box fell and they ran away separately.',
        'Without them, the consonants could only make noise.',
        'The alphabet stopped, and the dictionary went silent.',
        'A patient librarian searched under every desk.',
        'She found them humming softly inside an open book.',
      ],
    ),
    Story(
      id: 'story-goal-on-wall',
      title: 'The Goal on the Wall',
      category: 'Macera',
      levelIndex: 3,
      coverAsset: 'assets/images/Goal-rafiki.png',
      isRead: true,
      sentences: <String>[
        'A single sheet of paper hung above Elif\u2019s desk.',
        'On it she had written one sentence she refused to say.',
        'For two years the sentence stayed, faded and untidy.',
        'She kept postponing it with work that seemed urgent.',
        'One winter evening she finally started typing.',
        'The finished file was smaller than she had imagined.',
        'She took the paper down and pinned up a blank one.',
      ],
    ),
    Story(
      id: 'story-starting-something',
      title: 'Starting Something Small',
      category: 'İş Yaşamı',
      levelIndex: 3,
      coverAsset: 'assets/images/Starting a business project-rafiki.png',
      sentences: <String>[
        'Nobody in the team believed the idea would work.',
        'They had twenty days and no budget at all.',
        'Can built a rough version that only did one thing.',
        'It broke twice a day, and users kept forgiving it.',
        'The second version was faster, the third one honest.',
        'By the last week a stranger paid for it happily.',
        'The lesson was smaller than the story they expected.',
      ],
    ),
    Story(
      id: 'story-message',
      title: 'The Message That Never Arrived',
      category: 'Klasik',
      levelIndex: 4,
      coverAsset: 'assets/images/Sent Message-rafiki.png',
      sentences: <String>[
        'The letter travelled for three weeks before it returned.',
        'It came back sealed, as if nobody had opened it.',
        'Hasan read the address again and recognised the street.',
        'It was the house where he had grown up years ago.',
        'He wrote a second letter and posted it himself.',
        'This time a neighbour answered, saying the house was empty.',
        'Some messages are written only for the person who sends them.',
      ],
    ),
    Story(
      id: 'story-choice',
      title: 'The Choice Nobody Made',
      category: 'Klasik',
      levelIndex: 5,
      coverAsset: 'assets/images/Choose-rafiki.png',
      sentences: <String>[
        'The committee met every Thursday for four years.',
        'They agreed on everything except the one decision.',
        'Each member privately assumed that someone else would choose.',
        'The budget grew, the building aged, the plan stayed vague.',
        'When the last member retired, nobody replaced her.',
        'The room became a store for chairs nobody sits on.',
        'Some failures are not fights, only endless polite waiting.',
      ],
    ),
  ];

  static const String searchHint = 'Hikâye ara';
  static const String filterTooltip = 'Kategori filtresi';
  static const String categoriesLabel = 'KATEGORİLER';
  static const String applyFiltersLabel = 'FİLTREYİ UYGULA';
  static const String continueSectionLabel = 'KALDIĞIN YERDEN DEVAM ET';
  static const String allStoriesLabel = 'TÜM HİKÂYELER';
  static const String continueCtaLabel = 'DEVAM ET';
  static const String progressTemplate = '{current} / {total} cümle';

  static const List<double> playbackSpeeds = <double>[0.75, 1, 1.25, 1.5];

  static const String previousSentenceTooltip = 'Önceki cümle';
  static const String nextSentenceTooltip = 'Sonraki cümle';
  static const String playTooltip = 'Sesli okumayı başlat';
  static const String pauseTooltip = 'Sesli okumayı duraklat';
  static const String speedTooltip = 'Okuma hızını değiştir';
  static const String speedTemplate = '{value}x';
  static const String readingProgressTemplate = '{current} / {total}';
  static const String finishedMessage = 'Hikâyenin sonuna geldin.';
}
