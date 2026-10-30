part of 'practice_detail_cubit.dart';

sealed class PracticeDetailState extends Equatable {
  const PracticeDetailState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PracticeDetailLoading extends PracticeDetailState {
  const PracticeDetailLoading();
}

final class PracticeDetailError extends PracticeDetailState {
  const PracticeDetailError();
}

final class PracticeDetailEmpty extends PracticeDetailState {
  const PracticeDetailEmpty();
}

final class PracticeDetailReady extends PracticeDetailState {
  const PracticeDetailReady({required this.progress});

  final PracticeTypeProgress progress;

  @override
  List<Object?> get props => <Object?>[progress];
}
