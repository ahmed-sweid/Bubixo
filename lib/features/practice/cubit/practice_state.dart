part of 'practice_cubit.dart';

sealed class PracticeState extends Equatable {
  const PracticeState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

final class PracticeError extends PracticeState {
  const PracticeError();
}

final class PracticeEmpty extends PracticeState {
  const PracticeEmpty();
}

final class PracticeReady extends PracticeState {
  const PracticeReady({required this.types});

  final List<PracticeTypeProgress> types;

  @override
  List<Object?> get props => <Object?>[types];
}
