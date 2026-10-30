part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileError extends ProfileState {
  const ProfileError();
}

final class ProfileEmpty extends ProfileState {
  const ProfileEmpty();
}

final class ProfileReady extends ProfileState {
  const ProfileReady({
    required this.profile,
    required this.settings,
    required this.stats,
    required this.doneToday,
  });

  final UserProfile profile;
  final ProfileSettings settings;
  final ProfileStats stats;

  /// Bugün tamamlanan etkinlik sayısı — günlük hedef halkasını besler.
  final int doneToday;

  @override
  List<Object?> get props => <Object?>[profile, settings, stats, doneToday];
}
