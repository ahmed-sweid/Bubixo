part of 'stories_cubit.dart';

sealed class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class StoriesLoading extends StoriesState {
  const StoriesLoading();
}

final class StoriesError extends StoriesState {
  const StoriesError();
}

final class StoriesEmpty extends StoriesState {
  const StoriesEmpty();
}

final class StoriesReady extends StoriesState {
  const StoriesReady({
    required this.stories,
    required this.categories,
    this.continueStory,
  });

  final List<Story> stories;
  final List<String> categories;
  final Story? continueStory;

  @override
  List<Object?> get props => <Object?>[stories, categories, continueStory];
}
