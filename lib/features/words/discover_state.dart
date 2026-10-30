import '../../core/models/word_models.dart';

/// Kelime Keşfet sayfasının Cubit'e hazır durum kümesi.
sealed class DiscoverState {
  const DiscoverState();
}

final class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

final class DiscoverError extends DiscoverState {
  const DiscoverError();
}

final class DiscoverEmpty extends DiscoverState {
  const DiscoverEmpty();
}

final class DiscoverReady extends DiscoverState {
  const DiscoverReady({required this.words, required this.categories});

  final List<PoolWord> words;
  final List<String> categories;
}
