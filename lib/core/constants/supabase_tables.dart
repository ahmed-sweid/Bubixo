/// Supabase şema sözlüğü.
///
/// Kural: burada yalnızca **gerçekten var olan** tablo/görünüm/RPC adları durur.
/// Kullanılmayan sabit, şemanın olduğu gibi bırakıldığı yanılsaması yaratır;
/// var olmayanı ilan etmek ise veri kaynaklarının çalışma anında patlamasına
/// yol açar. Bu dosya canlı projeden (`ryrdgtpdxdhypxqiatfy`) şemadan okunarak
/// doğrulanmıştır (2026-11-01).
///
/// İki uyarı:
///  - **Okuma yolu çoğunlukla `v_*` görünümleridir.** Görünümler kullanıcı
///    ilerlemesini (`*_user_progress`) `auth.uid()` ile birleştirdiği için
///    sekmelerin çoğu **oturum açmış** olmadan `42501` döner. Bu bir hata değil,
///    tasarım: anon yalnızca ilerleme içermeyen ham catalog tablolarını okur.
///  - Kimlikler `uuid` değil sıralı `bigint identity`, sıralama `order_index`,
///    yayın kapısı `is_published`. Model eşleştirmeleri buna göre yapılacak (WP3+).
abstract final class SupabaseTable {
  // --- Katalog (içerik) ---
  static const String levels = 'levels';
  static const String lessons = 'lessons';
  static const String grammarTopics = 'grammar_topics';
  static const String vocabularyTopics = 'vocabulary_topics';
  static const String vocabularyWords = 'vocabulary_words';
  static const String vocabularyTopicWords = 'vocabulary_topic_words';
  static const String stories = 'stories';
  static const String storyCategories = 'story_categories';
  static const String storySentences = 'story_sentences';
  static const String storySentenceTokens = 'story_sentence_tokens';
  static const String practiceActivities = 'practice_activities';
  static const String practiceQuestions = 'practice_questions';
  static const String contentTests = 'content_tests';
  static const String contentTestQuestions = 'content_test_questions';

  // --- Kullanıcı ilerlemesi (yalnızca kendi satırı, RLS) ---
  static const String userLevelProgress = 'user_level_progress';
  static const String lessonUserProgress = 'lesson_user_progress';
  static const String grammarTopicUserProgress = 'grammar_topic_user_progress';
  static const String storyUserProgress = 'story_user_progress';
  static const String vocabularyWordProgress = 'vocabulary_word_progress';
  static const String vocabularyReviewLogs = 'vocabulary_review_logs';
  static const String practiceAttempts = 'practice_attempts';
  static const String practiceAttemptAnswers = 'practice_attempt_answers';
  static const String contentTestAttempts = 'content_test_attempts';
  static const String contentTestAttemptAnswers =
      'content_test_attempt_answers';

  // --- Profil ---
  static const String profiles = 'profiles';
}

/// İlerleme-duyarlı okuma görünümleri. Anon için kapalıdır (bkz. sınıf notu).
abstract final class SupabaseView {
  static const String lessonsCatalog = 'v_lessons_catalog';
  static const String lessonDetails = 'v_lesson_details';
  static const String grammarCatalog = 'v_grammar_catalog';
  static const String grammarDetails = 'v_grammar_details';
  static const String storiesCatalog = 'v_stories_catalog';
  static const String vocabularyCatalog = 'v_vocabulary_catalog';
  static const String vocabularyReviewQueue = 'v_vocabulary_review_queue';
  static const String topicActivityCatalog = 'v_topic_activity_catalog';
  static const String topicLearningProgress = 'v_topic_learning_progress';
  static const String learningHomeOptions = 'v_learning_home_options';
}

/// SECURITY DEFINER RPC'ler — yazma bu üç kapıdan geçer, ham `insert` ile değil.
abstract final class SupabaseRpc {
  /// SRS tekrar kartını puanlar; ilerlemeyi ve planlanan tarihi o yazar.
  static const String reviewVocabularyWord = 'review_vocabulary_word';

  /// Alıştırma denemesini + cevaplarını tek transaction'da kaydeder, puanı o hesaplar.
  static const String submitPracticeActivity = 'submit_practice_activity';

  /// Seviye/ders/gramer/hikâye testinin denemesini kaydeder, geçer/kalmaz kararını o verir.
  static const String submitContentTest = 'submit_content_test';
}

abstract final class LevelColumns {
  static const String id = 'id';
  static const String code = 'code';
  static const String title = 'title';
  static const String orderIndex = 'order_index';
  static const String createdAt = 'created_at';

  /// `levels` satırının tamamı — veri kaynaklarının `select` listesi.
  static const String all = '$id, $code, $title, $orderIndex, $createdAt';
}

abstract final class LessonColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String title = 'title';
  static const String contentMd = 'content_md';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';

  /// Liste sayfası `content_md`'yi çekmez: 62 satırda gövde taşımak gereksiz.
  static const String all =
      '$id, $levelId, $title, $contentMd, $orderIndex, $isPublished, $createdAt';
  static const String brief =
      '$id, $levelId, $title, $orderIndex, $isPublished';
}

abstract final class GrammarTopicColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String title = 'title';
  static const String contentMd = 'content_md';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $levelId, $title, $contentMd, $orderIndex, $isPublished, $createdAt';
  static const String brief = '$id, $levelId, $title, $orderIndex, $isPublished';
}

abstract final class VocabularyTopicColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String title = 'title';
  static const String titleEn = 'title_en';
  static const String descriptionMd = 'description_md';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $levelId, $title, $titleEn, $descriptionMd, $orderIndex, $isPublished, $createdAt';
  static const String brief = '$id, $levelId, $title, $titleEn, $orderIndex';
}

abstract final class VocabularyWordColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String word = 'word';
  static const String normalizedWord = 'normalized_word';
  static const String partOfSpeech = 'part_of_speech';

  /// `jsonb` — çeviriler anahtar/dil haritası (`{"tr": "…"}`).
  static const String translations = 'translations';
  static const String pronunciation = 'pronunciation';
  static const String audioUrl = 'audio_url';
  static const String definitionEn = 'definition_en';
  static const String exampleEn = 'example_en';
  static const String exampleTranslations = 'example_translations';
  static const String notes = 'notes';

  /// `text[]`.
  static const String tags = 'tags';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $levelId, $word, $normalizedWord, $partOfSpeech, $translations, $pronunciation, $audioUrl, $definitionEn, $exampleEn, $exampleTranslations, $notes, $tags, $orderIndex, $isPublished, $createdAt';

  /// Ezberleme kartı için gereken alanlar (gövdesiz, hafif liste).
  static const String card =
      '$id, $word, $normalizedWord, $partOfSpeech, $translations, $pronunciation, $definitionEn, $exampleEn, $exampleTranslations';
}

abstract final class VocabularyTopicWordColumns {
  static const String id = 'id';
  static const String topicId = 'topic_id';
  static const String wordId = 'word_id';
  static const String levelId = 'level_id';
  static const String orderIndex = 'order_index';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $topicId, $wordId, $levelId, $orderIndex, $createdAt';
}

abstract final class StoryColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String categoryId = 'category_id';

  /// `story | daily_life | …` — hikâyenin tür etiketi.
  static const String contentType = 'content_type';

  /// UI'da görünen başlık (Türkçe).
  static const String title = 'title';
  static const String titleEn = 'title_en';
  static const String summaryMd = 'summary_md';
  static const String estimatedReadingMinutes = 'estimated_reading_minutes';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String all =
      '$id, $levelId, $categoryId, $contentType, $title, $titleEn, $summaryMd, $estimatedReadingMinutes, $orderIndex, $isPublished, $createdAt, $updatedAt';
}

abstract final class StoryCategoryColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';

  /// Kendi üst kategorisi — `null` ise kök.
  static const String parentId = 'parent_id';
  static const String title = 'title';
  static const String titleEn = 'title_en';
  static const String descriptionMd = 'description_md';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $levelId, $parentId, $title, $titleEn, $descriptionMd, $orderIndex, $isPublished, $createdAt';
}

abstract final class StorySentenceColumns {
  static const String id = 'id';
  static const String storyId = 'story_id';
  static const String orderIndex = 'order_index';
  static const String textEn = 'text_en';
  static const String translationTr = 'translation_tr';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $storyId, $orderIndex, $textEn, $translationTr, $createdAt';
}

abstract final class StorySentenceTokenColumns {
  static const String id = 'id';
  static const String sentenceId = 'sentence_id';
  static const String orderIndex = 'order_index';
  static const String tokenText = 'token_text';

  /// Kelime türü etiketi (`word | punctuation | …`).
  static const String tokenType = 'token_type';

  /// Sözlük kelimesine bağlandığında dolu — dokunulabilir kelime kartı buradan açılır.
  static const String vocabularyWordId = 'vocabulary_word_id';
  static const String translations = 'translations';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $sentenceId, $orderIndex, $tokenText, $tokenType, $vocabularyWordId, $translations, $createdAt';
}

abstract final class PracticeActivityColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String title = 'title';
  static const String description = 'description';

  /// `fill_blank | sentence_order | listening | speaking | …`
  static const String activityType = 'activity_type';

  /// Kaynak bağları: bir alıştırmadan yalnızca birine bağlı olabilir.
  static const String sourceLessonId = 'source_lesson_id';
  static const String sourceGrammarTopicId = 'source_grammar_topic_id';
  static const String sourceStoryId = 'source_story_id';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String all =
      '$id, $levelId, $title, $description, $activityType, $sourceLessonId, $sourceGrammarTopicId, $sourceStoryId, $orderIndex, $isPublished, $createdAt, $updatedAt';
}

/// Cevap anahtarları bu tabloda **değil**, `private.practice_answers` içinde durur;
/// istemci onları hiçbir zaman okuyamaz. Doğruluk RPC içinde hesaplanır.
abstract final class PracticeQuestionColumns {
  static const String id = 'id';
  static const String activityId = 'activity_id';
  static const String prompt = 'prompt';
  static const String questionType = 'question_type';

  /// `jsonb` dizi.
  static const String options = 'options';
  static const String mediaUrl = 'media_url';
  static const String explanation = 'explanation';
  static const String orderIndex = 'order_index';

  /// `speaking` sorularında hedef dil kodu.
  static const String speechLanguage = 'speech_language';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $activityId, $prompt, $questionType, $options, $mediaUrl, $explanation, $orderIndex, $speechLanguage, $createdAt';
}

abstract final class ContentTestColumns {
  static const String id = 'id';

  /// `test_type` hangi bağın zorunlu olduğunu belirler: `level` → `level_id`,
  /// `lesson` → `lesson_id`, `grammar` → `grammar_topic_id`, `story` → `story_id`.
  static const String levelId = 'level_id';
  static const String lessonId = 'lesson_id';
  static const String grammarTopicId = 'grammar_topic_id';
  static const String storyId = 'story_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String testType = 'test_type';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String all =
      '$id, $levelId, $lessonId, $grammarTopicId, $storyId, $title, $description, $testType, $orderIndex, $isPublished, $createdAt, $updatedAt';
}

/// Doğru cevaplar `private.content_test_answers` içinde; istemci görmez.
abstract final class ContentTestQuestionColumns {
  static const String id = 'id';
  static const String contentTestId = 'content_test_id';
  static const String prompt = 'prompt';
  static const String questionType = 'question_type';
  static const String options = 'options';
  static const String mediaUrl = 'media_url';
  static const String explanation = 'explanation';
  static const String orderIndex = 'order_index';
  static const String createdAt = 'created_at';

  /// Seviye testi sorularını çekme sırası — karıştırmayı istemci yapar.
  static const String byTest =
      '$id, $contentTestId, $prompt, $questionType, $options, $orderIndex';
}

abstract final class UserLevelProgressColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String levelId = 'level_id';

  /// `locked | unlocked | in_progress | completed`.
  /// `completed` yalnızca `submit_content_test` RPC'si ile yazılır.
  static const String status = 'status';
  static const String unlockedAt = 'unlocked_at';
  static const String completedAt = 'completed_at';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $userId, $levelId, $status, $unlockedAt, $completedAt';
}

abstract final class LessonUserProgressColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String lessonId = 'lesson_id';
  static const String status = 'status';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String lastSection = 'last_section';

  /// Kaydırma konumu — okuma yerini geri yüklemede kullanılır.
  static const String lastScrollOffset = 'last_scroll_offset';
  static const String lastOpenedAt = 'last_opened_at';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $userId, $lessonId, $status, $startedAt, $completedAt, $lastSection, $lastScrollOffset, $lastOpenedAt';
}

abstract final class GrammarTopicUserProgressColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String grammarTopicId = 'grammar_topic_id';
  static const String status = 'status';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String lastOpenedAt = 'last_opened_at';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $userId, $grammarTopicId, $status, $startedAt, $completedAt, $lastOpenedAt';
}

abstract final class StoryUserProgressColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String storyId = 'story_id';
  static const String status = 'status';

  /// Okunan son cümlenin `order_index`'i — "kaldığın yerden devam".
  static const String lastSentenceOrder = 'last_sentence_order';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String lastOpenedAt = 'last_opened_at';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $userId, $storyId, $status, $lastSentenceOrder, $startedAt, $completedAt, $lastOpenedAt';
}

abstract final class VocabularyWordProgressColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String wordId = 'word_id';

  /// `en_to_translation | translation_to_en | cloze` — benzersiz anahtar
  /// `(user_id, word_id, card_direction)`, yani kelime başına birden çok satır
  /// olabilir ve her kart yönü kendi SRS planını taşır.
  static const String cardDirection = 'card_direction';

  /// `new | learning | review | mastered | suspended`.
  static const String status = 'status';
  static const String dueAt = 'due_at';
  static const String lastReviewedAt = 'last_reviewed_at';
  static const String repetitions = 'repetitions';
  static const String lapses = 'lapses';

  /// Leitner kutusu: 1 (yeni/zor) … 5 (iyi öğrenilmiş).
  static const String boxLevel = 'box_level';

  /// Satırın planlayıcısı; yeni satırlar `leitner` default'u ile doğar.
  static const String schedulerVersion = 'scheduler_version';

  /// `jsonb` — planlayıcıya özel durum, şema sözlüğü alanı yorumlamaz.
  static const String schedulerState = 'scheduler_state';
  static const String createdAt = 'created_at';

  static const String all =
      '$id, $userId, $wordId, $cardDirection, $status, $dueAt, $lastReviewedAt, $repetitions, $lapses, $boxLevel, $schedulerVersion';
}

abstract final class ProfileColumns {
  /// `auth.users.id` referansı ve aynı zamanda birincil anahtar.
  /// Tablo RLS ile **yalnızca sahibi**ne açıktır; bu bir eksik değil tasarımdır.
  static const String userId = 'user_id';
  static const String displayName = 'display_name';

  /// Uygulama arayüzünün dili.
  static const String uiLanguage = 'ui_language';

  /// Öğrenilen dil — bu proje için `en`.
  static const String learningLanguage = 'learning_language';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String all =
      '$userId, $displayName, $uiLanguage, $learningLanguage, $createdAt, $updatedAt';
}

/// Catalog görünümleri — sekmelerin liste sayfaları buradan okur.
abstract final class LessonsCatalogColumns {  static const String lessonId = 'lesson_id';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String levelTitle = 'level_title';
  static const String title = 'title';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';

  /// Gövde doldurulmuş mu — taslak dersleri UI'da ayırmaya yarar.
  static const String hasContent = 'has_content';
  static const String userStatus = 'user_status';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String lastOpenedAt = 'last_opened_at';
  static const String lastSection = 'last_section';
  static const String lastScrollOffset = 'last_scroll_offset';

  static const String all =
      '$lessonId, $levelId, $levelCode, $levelTitle, $title, $orderIndex, $isPublished, $hasContent, $userStatus, $startedAt, $completedAt, $lastOpenedAt, $lastSection, $lastScrollOffset';
}

/// Gramer konularının catalog görünümü — ders görünümüyle aynı sözleşim,
/// yalnız anahtar adı farklı.
abstract final class GrammarCatalogColumns {
  static const String grammarTopicId = 'grammar_topic_id';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String levelTitle = 'level_title';
  static const String title = 'title';
  static const String orderIndex = 'order_index';
  static const String isPublished = 'is_published';
  static const String hasContent = 'has_content';
  static const String userStatus = 'user_status';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String lastOpenedAt = 'last_opened_at';

  static const String all =
      '$grammarTopicId, $levelId, $levelCode, $levelTitle, $title, $orderIndex, $isPublished, $hasContent, $userStatus, $startedAt, $completedAt, $lastOpenedAt';
}

abstract final class StoriesCatalogColumns {
  static const String storyId = 'story_id';
  static const String title = 'title';
  static const String titleEn = 'title_en';
  static const String summaryMd = 'summary_md';
  static const String contentType = 'content_type';
  static const String estimatedReadingMinutes = 'estimated_reading_minutes';
  static const String storyOrder = 'story_order';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String levelTitle = 'level_title';
  static const String categoryId = 'category_id';
  static const String categoryTitle = 'category_title';
  static const String categoryTitleEn = 'category_title_en';
  static const String categoryParentId = 'category_parent_id';
  static const String sentenceCount = 'sentence_count';
  static const String userStatus = 'user_status';
  static const String lastSentenceOrder = 'last_sentence_order';
  static const String lastOpenedAt = 'last_opened_at';
  static const String startedAt = 'started_at';
  static const String completedAt = 'completed_at';
  static const String progressPercent = 'progress_percent';

  static const String all =
      '$storyId, $title, $titleEn, $summaryMd, $contentType, $estimatedReadingMinutes, $storyOrder, $levelId, $levelCode, $levelTitle, $categoryId, $categoryTitle, $categoryTitleEn, $categoryParentId, $sentenceCount, $userStatus, $lastSentenceOrder, $lastOpenedAt, $startedAt, $completedAt, $progressPercent';
}

abstract final class VocabularyCatalogColumns {
  static const String topicId = 'topic_id';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String levelTitle = 'level_title';
  static const String topicTitle = 'topic_title';
  static const String topicTitleEn = 'topic_title_en';
  static const String descriptionMd = 'description_md';
  static const String topicOrderIndex = 'topic_order_index';

  /// Yalnızca `is_published` kelimeler sayılır.
  static const String publishedWordCount = 'published_word_count';

  static const String all =
      '$topicId, $levelId, $levelCode, $levelTitle, $topicTitle, $topicTitleEn, $descriptionMd, $topicOrderIndex, $publishedWordCount';
}

abstract final class ReviewQueueColumns {
  static const String userId = 'user_id';
  static const String wordId = 'word_id';
  static const String cardDirection = 'card_direction';
  static const String status = 'status';
  static const String dueAt = 'due_at';
  static const String lastReviewedAt = 'last_reviewed_at';
  static const String repetitions = 'repetitions';
  static const String lapses = 'lapses';
  static const String boxLevel = 'box_level';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String word = 'word';
  static const String translations = 'translations';
  static const String partOfSpeech = 'part_of_speech';
  static const String pronunciation = 'pronunciation';
  static const String exampleEn = 'example_en';
  static const String exampleTranslations = 'example_translations';
  static const String wordOrderIndex = 'word_order_index';

  /// Ezberleme ekranı bu tek görünümle hem kartı hem planı çizer.
  static const String all =
      '$wordId, $cardDirection, $status, $dueAt, $repetitions, $lapses, $boxLevel, $levelId, $levelCode, $word, $translations, $partOfSpeech, $pronunciation, $exampleEn, $exampleTranslations';
}

abstract final class TopicActivityCatalogColumns {
  static const String sourceType = 'source_type';
  static const String sourceId = 'source_id';
  static const String levelId = 'level_id';
  static const String levelCode = 'level_code';
  static const String sourceTitle = 'source_title';
  static const String activityId = 'activity_id';
  static const String activityTitle = 'activity_title';
  static const String activityType = 'activity_type';
  static const String activityOrder = 'activity_order';
  static const String activityIsPublished = 'activity_is_published';
  static const String questionCount = 'question_count';

  /// Dikkat: görünüme yalnızca **yayınlanmış bir derse/gramer konusuna bağlı**
  /// aktiviteler girer; kaynaksız aktivite burada görünmez.
  static const String all =
      '$sourceType, $sourceId, $levelId, $levelCode, $sourceTitle, $activityId, $activityTitle, $activityType, $activityOrder, $questionCount';
}

abstract final class LearningHomeOptionsColumns {
  /// `lesson | grammar | story | vocabulary | practice`.
  static const String optionType = 'option_type';
  static const String contentType = 'content_type';
  static const String contentId = 'content_id';
  static const String title = 'title';
  static const String levelCode = 'level_code';
  static const String levelTitle = 'level_title';
  static const String lastOpenedAt = 'last_opened_at';

  /// Kelimeler sekmesi için: bugün çalışılacak kart sayısı.
  static const String dueCount = 'due_count';
  static const String sortOrder = 'sort_order';
  static const String lastSection = 'last_section';
  static const String lastScrollOffset = 'last_scroll_offset';

  /// Ana sayfanın "devam et" kartları tek sorgu ile buradan gelir.
  static const String all =
      '$optionType, $contentType, $contentId, $title, $levelCode, $levelTitle, $lastOpenedAt, $dueCount, $sortOrder, $lastSection, $lastScrollOffset';
}
