part of 'discover_cubit.dart';

sealed class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => const <Object?>[];
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

  @override
  List<Object?> get props => <Object?>[words, categories];
}
