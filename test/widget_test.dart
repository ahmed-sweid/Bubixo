import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:en_bubixo/core/constants/auth_content.dart';
import 'package:en_bubixo/core/constants/lessons_content.dart';
import 'package:en_bubixo/core/constants/level_content.dart';
import 'package:en_bubixo/core/constants/level_test_content.dart';
import 'package:en_bubixo/core/constants/nav_content.dart';
import 'package:en_bubixo/core/constants/onboarding_content.dart';
import 'package:en_bubixo/core/constants/practice_content.dart';
import 'package:en_bubixo/core/constants/profile_content.dart';
import 'package:en_bubixo/core/constants/splash_content.dart';
import 'package:en_bubixo/core/constants/state_content.dart';
import 'package:en_bubixo/core/constants/words_content.dart';
import 'package:en_bubixo/core/design_system.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/lesson_models.dart';
import 'package:en_bubixo/core/models/practice_models.dart';
import 'package:en_bubixo/core/models/profile_models.dart';
import 'package:en_bubixo/core/models/story_models.dart';
import 'package:en_bubixo/core/models/word_models.dart';
import 'package:en_bubixo/features/auth/login_screen.dart';
import 'package:en_bubixo/features/common/states/app_skeletons.dart';
import 'package:en_bubixo/features/level/cubit/level_test_cubit.dart';
import 'package:en_bubixo/features/level/data/models/placement_models.dart';
import 'package:en_bubixo/features/level/data/repositories/placement_repository.dart';
import 'package:en_bubixo/features/level/level_test_screen.dart';
import 'package:en_bubixo/features/lessons/lessons_screen.dart';
import 'package:en_bubixo/features/lessons/cubit/lessons_cubit.dart';
import 'package:en_bubixo/features/onboarding/onboarding_screen.dart';
import 'package:en_bubixo/features/practice/practice_detail_screen.dart';
import 'package:en_bubixo/features/practice/practice_screen.dart';
import 'package:en_bubixo/features/practice/cubit/practice_cubit.dart';
import 'package:en_bubixo/features/practice/cubit/practice_detail_cubit.dart';
import 'package:en_bubixo/features/profile/profile_screen.dart';
import 'package:en_bubixo/features/profile/cubit/profile_cubit.dart';
import 'package:en_bubixo/features/shell/home_shell.dart';
import 'package:en_bubixo/features/shell/widgets/nav_tab.dart';
import 'package:en_bubixo/features/splash/splash_screen.dart';
import 'package:en_bubixo/features/stories/stories_screen.dart';
import 'package:en_bubixo/features/stories/cubit/stories_cubit.dart';
import 'package:en_bubixo/features/words/words_screen.dart';
import 'package:en_bubixo/features/words/cubit/words_cubit.dart';

// --- Sabit test verileri ----------------------------------------------------

const LessonQuestion _lessonQuestion = LessonQuestion(
  id: 'q1',
  prompt: 'She ___ a student.',
  options: <String>['is', 'are'],
  correctIndex: 0,
);

const Lesson _grammarLesson = Lesson(
  id: 'g1',
  levelIndex: 0,
  track: LessonTrack.grammar,
  order: 1,
  title: 'Selamlaşma',
  body: <String>['Hello!'],
  questions: <LessonQuestion>[_lessonQuestion],
);

const Lesson _readingLesson = Lesson(
  id: 'r1',
  levelIndex: 0,
  track: LessonTrack.lessons,
  order: 1,
  title: 'Günlük Okuma',
  body: <String>['Good morning.'],
  questions: <LessonQuestion>[_lessonQuestion],
);

const LessonLevel _level = LessonLevel(
  levelIndex: 0,
  grammarLessons: <Lesson>[_grammarLesson],
  lessonLessons: <Lesson>[_readingLesson],
  levelTestUnlocked: true,
);

const Story _story = Story(
  id: 's1',
  title: 'The Lost Key',
  category: 'Klasik',
  levelIndex: 0,
  coverAsset: 'assets/images/Bibliophile-rafiki.png',
  sentences: <String>['Once upon a time.'],
);

const Word _word = Word(
  id: 'w1',
  term: 'apple',
  translation: 'elma',
  status: WordStatus.learning,
);

const PracticeItem _practiceItem = PracticeItem(
  id: 'p1',
  type: PracticeType.sentenceOrder,
  levelIndex: 0,
  order: 1,
  title: 'Günlük cümleler',
);

const PracticeTypeProgress _practiceProgress = PracticeTypeProgress(
  type: PracticeType.sentenceOrder,
  completedCount: 1,
  totalCount: 2,
  levels: <PracticeLevelProgress>[
    PracticeLevelProgress(
      levelIndex: 0,
      items: <PracticeItem>[_practiceItem],
      progress: 0.5,
    ),
  ],
);

const ProfileSettings _settings = ProfileSettings(
  language: AppLanguage.turkish,
  dailyGoal: DailyGoal.normal,
  notifications: NotificationPrefs(
    practiceReminder: true,
    streakGuard: false,
    newContent: false,
  ),
  audio: AudioPrefs(readAloud: true, soundEffects: false, speed: 1),
  reading: ReadingPrefs(
    textSize: ReadingTextSize.medium,
    showTranslation: true,
    tapToTranslate: false,
  ),
);

const ProfileStats _stats = ProfileStats(
  completedLessons: 3,
  learningWords: 4,
  memorizedWords: 6,
  readStories: 2,
  completedPractices: 1,
  overallProgress: 0.4,
);

const UserProfile _profile = UserProfile(
  name: 'Ada',
  email: 'ada@bubixo.app',
  levelIndex: 0,
);

const PlacementQuestion _testQuestion1 = PlacementQuestion(
  id: '11',
  code: 'A1_S1_01',
  stage: 1,
  cefrLevel: 'A1',
  prompt: 'Pick one.',
  options: <PlacementOption>[
    PlacementOption(id: 'a', text: 'alpha'),
    PlacementOption(id: 'b', text: 'beta'),
  ],
);

const PlacementQuestion _testQuestion2 = PlacementQuestion(
  id: '22',
  code: 'A2_S1_02',
  stage: 1,
  cefrLevel: 'A2',
  prompt: 'Pick another.',
  options: <PlacementOption>[
    PlacementOption(id: 'a', text: 'charlie'),
    PlacementOption(id: 'b', text: 'delta'),
  ],
);

PlacementRoute _questionRoute(PlacementQuestion question) => PlacementRoute(
  finished: false,
  stage: question.stage,
  outcome: null,
  question: question,
);

PlacementRoute _finishedRoute(String level) => PlacementRoute(
  finished: true,
  stage: 2,
  outcome: PlacementOutcome(
    level: level,
    confidence: 'high',
    totalQuestions: 2,
    correctAnswers: 1,
    score: 50,
  ),
);

/// Seviye testi akışı sunucu güdümlü olduğu için widget testi de bir
/// `PlacementRepository` sahtesiyle beslenir: `startAttempt` ilk soruyu,
/// `submitAnswer` `steps` listesindeki sıradaki adımı döner.
class _FakePlacementRepository implements PlacementRepository {
  _FakePlacementRepository({required this.steps});

  final List<PlacementRoute> steps;
  final List<String> submittedAnswerIds = <String>[];

  @override
  Future<Either<Failure, PlacementSession?>> startAttempt() async {
    return Right<Failure, PlacementSession?>(
      PlacementSession(
        test: const PlacementTest(
          id: '1',
          code: 'default',
          title: 'Seviye Testi',
          version: 1,
        ),
        attemptId: '7',
        attemptNumber: 1,
        route: _questionRoute(_testQuestion1),
      ),
    );
  }

  @override
  Future<Either<Failure, PlacementAnswer>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  }) async {
    submittedAnswerIds.add(answerId);
    return Right<Failure, PlacementAnswer>(
      PlacementAnswer(
        isCorrect: true,
        selectedAnswerId: answerId,
        route: steps[submittedAnswerIds.length - 1],
      ),
    );
  }

  @override
  Future<Either<Failure, PlacementOutcome>> fetchResult(
    String attemptId,
  ) async => throw UnimplementedError('sonuç ekranı route ile kapanır');
}

// --- Yardımcılar ------------------------------------------------------------

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1170, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
    await tester.pump();
  }

  Future<void> advance(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Splash marka bloğunu ve CTA çiftini gösterir', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const SplashScreen());
    await advance(tester);

    expect(find.text(SplashContent.appName), findsOneWidget);
    expect(find.text(SplashContent.startCtaLabel), findsOneWidget);
    expect(find.text(SplashContent.loginCtaLabel), findsOneWidget);
  });

  testWidgets('Onboarding CTA ile ikinci sayfaya geçer', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const OnboardingScreen());

    expect(find.text(OnboardingContent.pages.first.title), findsOneWidget);
    expect(find.text(OnboardingContent.pages.first.ctaLabel), findsOneWidget);

    await tester.tap(find.text(OnboardingContent.pages.first.ctaLabel));
    await advance(tester);

    expect(find.text(OnboardingContent.pages[1].title), findsOneWidget);
  });

  testWidgets('Login boş gönderimde doğrulama hatalarını gösterir', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const LoginScreen());

    expect(find.text(LoginContent.title), findsOneWidget);
    expect(find.text(LoginContent.ctaLabel), findsOneWidget);
    expect(find.text(LoginContent.googleCtaLabel), findsOneWidget);
    expect(find.text(LoginContent.dividerLabel), findsOneWidget);

    await tester.ensureVisible(find.text(LoginContent.ctaLabel));
    await tester.pump();
    await tester.tap(find.text(LoginContent.ctaLabel));
    await tester.pump();

    expect(find.text(AuthContent.requiredField), findsNWidgets(2));
  });

  testWidgets('Alt bar beş sekmeyi gösterir ve seçim değişir', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const HomeShell());

    expect(find.byType(NavTab), findsNWidgets(5));
    expect(find.byType(LessonsSkeleton), findsOneWidget);

    final Finder storiesTab = find.byKey(
      ValueKey<String>('nav-${NavContent.storiesLabel}'),
    );
    await tester.tap(storiesTab);
    await advance(tester);

    expect(tester.widget<NavTab>(storiesTab).selected, isTrue);
    expect(
      tester.widget<IndexedStack>(find.byType(IndexedStack).first).index,
      1,
    );

    final Finder profileTab = find.byKey(
      ValueKey<String>('nav-${NavContent.profileLabel}'),
    );
    await tester.tap(profileTab);
    await advance(tester);

    expect(tester.widget<NavTab>(profileTab).selected, isTrue);
    expect(
      tester.widget<IndexedStack>(find.byType(IndexedStack).first).index,
      4,
    );
  });

  group('Dersler', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const LessonsScreen());
      expect(find.byType(LessonsSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda tekrar dene çalışır', (
      WidgetTester tester,
    ) async {
      int retries = 0;
      await pumpScreen(
        tester,
        LessonsScreen(
          cubit: LessonsCubit(initialState: const LessonsError()),
          onRetry: () => retries++,
        ),
      );

      expect(find.text(StateContent.errorTitle), findsOneWidget);

      await tester.ensureVisible(find.text(StateContent.retryLabel));
      await tester.pump();
      await tester.tap(find.text(StateContent.retryLabel));

      expect(retries, 1);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        LessonsScreen(cubit: LessonsCubit(initialState: const LessonsEmpty())),
      );
      expect(find.text(StateContent.lessonsEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda sekmeler ve ders başlıkları görünür', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        LessonsScreen(
          cubit: LessonsCubit(
            initialState: const LessonsReady(levels: <LessonLevel>[_level]),
          ),
        ),
      );

      expect(find.text(NavContent.lessonsTitle), findsOneWidget);
      expect(find.text(LessonsContent.grammarTabLabel), findsOneWidget);
      expect(find.text(LessonsContent.lessonsTabLabel), findsOneWidget);
      expect(find.text('A1'), findsOneWidget);

      await tester.tap(find.text('A1'));
      await advance(tester);

      expect(find.text(_grammarLesson.title), findsOneWidget);
      expect(find.text(LessonsContent.levelTestTileLabel), findsOneWidget);

      await tester.tap(find.text(LessonsContent.lessonsTabLabel));
      await advance(tester);

      expect(find.text(_grammarLesson.title), findsNothing);

      await tester.tap(find.text('A1'));
      await advance(tester);

      expect(find.text(_readingLesson.title), findsOneWidget);
    });
  });

  group('Hikâyeler', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const StoriesScreen());
      expect(find.byType(StoriesSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        StoriesScreen(cubit: StoriesCubit(initialState: const StoriesError())),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        StoriesScreen(cubit: StoriesCubit(initialState: const StoriesEmpty())),
      );
      expect(find.text(StateContent.storiesEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda hikâye kartını gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        StoriesScreen(
          cubit: StoriesCubit(
            initialState: const StoriesReady(
              stories: <Story>[_story],
              categories: <String>['Klasik'],
            ),
          ),
        ),
      );

      expect(find.text(NavContent.storiesTitle), findsOneWidget);
      expect(find.text(_story.title), findsOneWidget);
      expect(find.text(NavContent.storiesDescription), findsOneWidget);
    });
  });

  group('Kelimeler', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const WordsScreen());
      expect(find.byType(WordsSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        WordsScreen(cubit: WordsCubit(initialState: const WordsError())),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        WordsScreen(cubit: WordsCubit(initialState: const WordsEmpty())),
      );
      expect(find.text(StateContent.wordsEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda istatistik ve çeviri bölümlerini gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        WordsScreen(
          cubit: WordsCubit(
            initialState: const WordsReady(words: <Word>[_word]),
          ),
        ),
      );

      expect(find.text(NavContent.wordsTitle), findsOneWidget);
      expect(find.text(WordsContent.learningLabel), findsOneWidget);
      expect(find.text(WordsContent.memorizedLabel), findsOneWidget);
      expect(find.text(WordsContent.translateSectionLabel), findsOneWidget);
      expect(find.text(WordsContent.startCtaLabel), findsOneWidget);
    });
  });

  group('Pratikler', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const PracticeScreen());
      expect(find.byType(PracticeSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeScreen(
          cubit: PracticeCubit(initialState: const PracticeError()),
        ),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeScreen(
          cubit: PracticeCubit(initialState: const PracticeEmpty()),
        ),
      );
      expect(find.text(StateContent.practiceEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda tür kartını gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeScreen(
          cubit: PracticeCubit(
            initialState: const PracticeReady(
              types: <PracticeTypeProgress>[_practiceProgress],
            ),
          ),
        ),
      );

      expect(find.text(NavContent.practiceTitle), findsOneWidget);
      expect(
        find.text(PracticeContent.typeTitles[PracticeType.sentenceOrder]!),
        findsOneWidget,
      );
      expect(
        find.text(
          PracticeContent.progressTemplate
              .replaceFirst('{done}', '1')
              .replaceFirst('{total}', '2'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Pratik detayı', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const PracticeDetailScreen(type: PracticeType.sentenceOrder),
      );
      expect(find.byType(PracticeDetailSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeDetailScreen(
          type: PracticeType.sentenceOrder,
          cubit: PracticeDetailCubit(initialState: const PracticeDetailError()),
        ),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeDetailScreen(
          type: PracticeType.sentenceOrder,
          cubit: PracticeDetailCubit(initialState: const PracticeDetailEmpty()),
        ),
      );
      expect(find.text(StateContent.practiceEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda seviye kartı ve içerik satırını gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        PracticeDetailScreen(
          type: PracticeType.sentenceOrder,
          cubit: PracticeDetailCubit(
            initialState: const PracticeDetailReady(
              progress: _practiceProgress,
            ),
          ),
        ),
      );

      expect(
        find.text(PracticeContent.typeTitles[PracticeType.sentenceOrder]!),
        findsOneWidget,
      );
      expect(
        find.text(
          PracticeContent.itemCountTemplate
              .replaceFirst('{done}', '1')
              .replaceFirst('{total}', '2'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('A1'));
      await advance(tester);

      expect(find.text(_practiceItem.title), findsOneWidget);
    });
  });

  group('Profil', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const ProfileScreen());
      expect(find.byType(ProfileSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        ProfileScreen(cubit: ProfileCubit(initialState: const ProfileError())),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        ProfileScreen(cubit: ProfileCubit(initialState: const ProfileEmpty())),
      );
      expect(find.text(StateContent.profileEmptyTitle), findsOneWidget);
    });

    testWidgets('hazır durumda kimlik, seviye ve ayarları gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        ProfileScreen(
          cubit: ProfileCubit(
            initialState: const ProfileReady(
              profile: _profile,
              settings: _settings,
              stats: _stats,
              doneToday: 1,
            ),
          ),
        ),
      );

      expect(find.text(NavContent.profileTitle), findsOneWidget);
      expect(find.text(_profile.name), findsOneWidget);
      expect(find.text(_profile.email), findsOneWidget);
      expect(find.text(ProfileContent.statsSectionLabel), findsOneWidget);
      expect(find.text(ProfileContent.currentLevelLabel), findsOneWidget);
      expect(
        find.text(ProfileContent.languageLabels[AppLanguage.turkish]!),
        findsOneWidget,
      );
      expect(find.text(ProfileContent.settingsSectionLabel), findsOneWidget);
      expect(find.text(ProfileContent.accountSectionLabel), findsOneWidget);
    });
  });

  group('Seviye testi', () {
    testWidgets('yükleme durumunda iskelet gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const LevelTestScreen());
      expect(find.byType(LevelTestSkeleton), findsOneWidget);
    });

    testWidgets('hata durumunda hata metni ve tekrar dene gösterilir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        LevelTestScreen(
          cubit: LevelTestCubit(
            initialState: const LevelTestError(message: 'Sunucu cevap vermiyor'),
          ),
        ),
      );
      expect(find.text(StateContent.errorTitle), findsOneWidget);
      expect(find.text('Sunucu cevap vermiyor'), findsOneWidget);
      expect(find.text(StateContent.retryLabel), findsOneWidget);
    });

    testWidgets('boş durumda boş görünümü gösterir', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        LevelTestScreen(
          cubit: LevelTestCubit(initialState: const LevelTestEmpty()),
        ),
      );
      expect(find.text(StateContent.levelTestEmptyTitle), findsOneWidget);
    });

    testWidgets('cevaplar sunucuya gider, sıradaki soru ve sunucu seviyesi gelir', (
      WidgetTester tester,
    ) async {
      final _FakePlacementRepository repository = _FakePlacementRepository(
        steps: <PlacementRoute>[
          _questionRoute(_testQuestion2),
          _finishedRoute('B1'),
        ],
      );
      // Cubit'i kendimiz kapatmayız: BlocProvider `create` ile sahiplenir ve
      // ağaç sökülken kapatır. addTearDown(cubit.close) testi sonlandurmaz.
      final LevelTestCubit cubit = LevelTestCubit(repository: repository);
      await cubit.start();

      int? completedLevel;
      await pumpScreen(
        tester,
        LevelTestScreen(
          cubit: cubit,
          onCompleted: (int levelIndex) => completedLevel = levelIndex,
        ),
      );

      // Aşamanın üst sınırı çizilir: sunucu kaç soru geleceğini önceden bildirmez.
      expect(
        find.text(
          LevelTestContent.questionProgressTemplate
              .replaceFirst('{index}', '1')
              .replaceFirst('{total}', '${LevelTestContent.stageQuestionCap(1)}'),
        ),
        findsOneWidget,
      );
      expect(find.text(_testQuestion1.prompt), findsOneWidget);

      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, LevelTestContent.ctaLabel),
            )
            .onPressed,
        isNull,
        reason: 'seçim yapılmadan devam edilemez',
      );

      await tester.tap(find.text(_testQuestion1.options[0].text));
      await advance(tester);
      await tester.tap(find.text(LevelTestContent.ctaLabel));
      await advance(tester);

      expect(find.text(_testQuestion2.prompt), findsOneWidget);
      expect(
        find.text(
          LevelTestContent.questionProgressTemplate
              .replaceFirst('{index}', '2')
              .replaceFirst('{total}', '${LevelTestContent.stageQuestionCap(1)}'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(_testQuestion2.options[1].text));
      await advance(tester);
      await tester.tap(find.text(LevelTestContent.ctaLabel));
      await advance(tester);

      expect(
        repository.submittedAnswerIds,
        <String>[_testQuestion1.options[0].id, _testQuestion2.options[1].id],
        reason: 'seçeneğin metni değil id\'si gönderilir',
      );
      expect(find.text(LevelTestContent.resultBadgeLabel), findsOneWidget);
      expect(find.text('B1'), findsOneWidget);
      expect(
        find.text(LevelTestContent.resultInfos[LevelContent.cefrLevels.indexOf('B1')]),
        findsOneWidget,
      );

      await tester.tap(find.text(LevelTestContent.confirmLabel));
      await tester.pump();

      expect(completedLevel, LevelContent.cefrLevels.indexOf('B1'));
    });
  });
}
