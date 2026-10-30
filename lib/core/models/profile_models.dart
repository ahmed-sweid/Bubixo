import 'package:flutter/foundation.dart';

/// Profil modülü veri modelleri.
///
/// Supabase karşılığı:
/// - [UserProfile]   -> users(id, name, email, avatar_url, level_index)
/// - tercihler       -> user_settings(user_id, app_language, daily_goal,
///                                    notifications jsonb, audio jsonb,
///                                    reading jsonb)
/// - istatistikler   -> ders/kelime/hikâye/pratik ilerleme tablolarından
///                      türetilir, ayrıca saklanmaz
/// TODO(backend): kimlik doğrulama bağlanınca profil ve tercihler bu
/// tablolardan okunacak; şimdilik yerinde (in-memory) tutulur.
enum AppLanguage {
  turkish,
  english;

  String get storageValue => switch (this) {
    AppLanguage.turkish => 'tr',
    AppLanguage.english => 'en',
  };
}

/// Günlük çalışma hedefi: tamamlanacak etkinlik sayısı.
enum DailyGoal {
  light(1),
  normal(3),
  strong(5),
  expert(10);

  const DailyGoal(this.count);

  final int count;

  String get storageValue => 'goal_$name';
}

/// Hikâye okuma ekranındaki yazı boyutu tercihi.
enum ReadingTextSize {
  small,
  medium,
  large;

  String get storageValue => 'text_$name';

  double get fontSize => switch (this) {
    ReadingTextSize.small => 18,
    ReadingTextSize.medium => 22,
    ReadingTextSize.large => 26,
  };
}

@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.levelIndex,
    this.avatarAsset,
  });

  final String name;
  final String email;

  /// `LevelContent.cefrLevels` indeksi.
  final int levelIndex;

  /// Yalnızca kullanıcı portresi yüklendiğinde dolu; boşken adın
  /// baş harfleriyle avatar çizilir.
  final String? avatarAsset;

  String get initials {
    final List<String> words = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((String word) => word.isEmpty);
    if (words.isEmpty) {
      return '?';
    }
    if (words.length == 1) {
      final String word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    int? levelIndex,
    String? avatarAsset,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      levelIndex: levelIndex ?? this.levelIndex,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}

/// Öğrenme istatistikleri — diğer modüllerin ilerleme verisinden türetilir.
@immutable
class ProfileStats {
  const ProfileStats({
    required this.completedLessons,
    required this.learningWords,
    required this.memorizedWords,
    required this.readStories,
    required this.completedPractices,
    required this.overallProgress,
  });

  final int completedLessons;
  final int learningWords;
  final int memorizedWords;
  final int readStories;
  final int completedPractices;

  /// 0.0–1.0 arası genel öğrenme ilerlemesi.
  final double overallProgress;

  int get wordTotal => learningWords + memorizedWords;
}

@immutable
class NotificationPrefs {
  const NotificationPrefs({
    required this.practiceReminder,
    required this.streakGuard,
    required this.newContent,
  });

  final bool practiceReminder;
  final bool streakGuard;
  final bool newContent;

  NotificationPrefs copyWith({
    bool? practiceReminder,
    bool? streakGuard,
    bool? newContent,
  }) {
    return NotificationPrefs(
      practiceReminder: practiceReminder ?? this.practiceReminder,
      streakGuard: streakGuard ?? this.streakGuard,
      newContent: newContent ?? this.newContent,
    );
  }
}

@immutable
class AudioPrefs {
  const AudioPrefs({
    required this.readAloud,
    required this.soundEffects,
    required this.speed,
  });

  /// Kelimeler ve hikâyeler sesli okunsun mu.
  final bool readAloud;
  final bool soundEffects;

  /// Sesli okuma hızı çarpanı.
  final double speed;

  AudioPrefs copyWith({bool? readAloud, bool? soundEffects, double? speed}) {
    return AudioPrefs(
      readAloud: readAloud ?? this.readAloud,
      soundEffects: soundEffects ?? this.soundEffects,
      speed: speed ?? this.speed,
    );
  }
}

@immutable
class ReadingPrefs {
  const ReadingPrefs({
    required this.textSize,
    required this.showTranslation,
    required this.tapToTranslate,
  });

  final ReadingTextSize textSize;

  /// Hikâye okumada Türkçe çeviri varsayılan olarak açık gelsin mi.
  final bool showTranslation;
  final bool tapToTranslate;

  ReadingPrefs copyWith({
    ReadingTextSize? textSize,
    bool? showTranslation,
    bool? tapToTranslate,
  }) {
    return ReadingPrefs(
      textSize: textSize ?? this.textSize,
      showTranslation: showTranslation ?? this.showTranslation,
      tapToTranslate: tapToTranslate ?? this.tapToTranslate,
    );
  }
}

/// Kullanıcının uygulama tercihleri tek modelde toplanır.
@immutable
class ProfileSettings {
  const ProfileSettings({
    required this.language,
    required this.dailyGoal,
    required this.notifications,
    required this.audio,
    required this.reading,
  });

  final AppLanguage language;
  final DailyGoal dailyGoal;
  final NotificationPrefs notifications;
  final AudioPrefs audio;
  final ReadingPrefs reading;

  ProfileSettings copyWith({
    AppLanguage? language,
    DailyGoal? dailyGoal,
    NotificationPrefs? notifications,
    AudioPrefs? audio,
    ReadingPrefs? reading,
  }) {
    return ProfileSettings(
      language: language ?? this.language,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notifications: notifications ?? this.notifications,
      audio: audio ?? this.audio,
      reading: reading ?? this.reading,
    );
  }
}
