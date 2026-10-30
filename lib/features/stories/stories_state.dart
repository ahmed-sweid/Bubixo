import '../../core/models/story_models.dart';

/// Hikâyeler sekmesinin Cubit'e hazır durum kümesi.
sealed class StoriesState {
  const StoriesState();
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
}
