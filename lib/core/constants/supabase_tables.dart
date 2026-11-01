/// Supabase şema sözlüğü.
///
/// Kural: burada yalnızca **gerçekten var olan** ve **kodun gerçekten çağırdığı**
/// tablo/kolon adları durur. Kullanılmayan sabit, şemanın olduğu gibi bırakıldığı
/// yanılsaması yaratır; o yüzden WP1'de oluşturulacak tablolar burada ilan edilmedi.
///
/// Durum (2026-11-01, salt-okunur keşifle doğrulandı — proje `ryrdgtpdxdhypxqiatfy`):
///  - `levels`          VAR, satır var (id, code, title, order_index, created_at)
///  - `lessons`         VAR, 0 satır (id, level_id, title, order_index, created_at, is_published)
///  - `stories`         VAR, 0 satır (+ updated_at)
///  - `story_sentences` VAR, 0 satır (id, story_id, order_index, text_en, created_at)
///  - `profiles`        VAR, anon SELECT yetkisi yok (401/42501) — kolonlar kısmen görünüyor
///  - `words, word_reviews, lesson_questions, level_test_questions, practices,
///     practice_items, lesson_progress, daily_stats, settings, topics` YOK
///
/// Dikkat: mevcut tablolar `uuid` değil sıralı `id` ve `order_index` kullanıyor;
/// `sort_order`/`cefr_code` gibi raporlardaki isimler **uygulanmadı**. Model
/// eşleştirmeleri bu gerçeğe göre yapılacak (WP3+). WP1 SQL'i yalnız eksik
/// kolon/tabloları ekler, mevcut olanı silmez veya yeniden yaratmaz.
abstract final class SupabaseTable {
  static const String levels = 'levels';
  static const String lessons = 'lessons';
  static const String stories = 'stories';
  static const String storySentences = 'story_sentences';
  static const String profiles = 'profiles';
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
  static const String orderIndex = 'order_index';
  static const String createdAt = 'created_at';
  static const String isPublished = 'is_published';

  static const String all =
      '$id, $levelId, $title, $orderIndex, $createdAt, $isPublished';
}

abstract final class StoryColumns {
  static const String id = 'id';
  static const String levelId = 'level_id';
  static const String title = 'title';
  static const String orderIndex = 'order_index';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isPublished = 'is_published';

  static const String all =
      '$id, $levelId, $title, $orderIndex, $createdAt, $updatedAt, $isPublished';
}

abstract final class StorySentenceColumns {
  static const String id = 'id';
  static const String storyId = 'story_id';
  static const String orderIndex = 'order_index';
  static const String textEn = 'text_en';
  static const String createdAt = 'created_at';

  static const String all = '$id, $storyId, $orderIndex, $textEn, $createdAt';
}

abstract final class ProfileColumns {
  /// `auth.users.id` referansı; `profiles` tablosunun birincil anahtarı `id`
  /// değil bu kolon üzerinden tanımlı (anon okuma kapalı olduğu için WP1'de
  /// kesinleştirilecek).
  static const String userId = 'user_id';
  static const String displayName = 'display_name';
  static const String learningLanguage = 'learning_language';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
