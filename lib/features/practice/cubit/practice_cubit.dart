import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/practice_models.dart';

part 'practice_state.dart';

/// Pratikler sekmesinin durum yönetimi; veri katmanı bağlanınca türler ve
/// ilerlemeler bu cubit üzerinden yüklenecek.
class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({PracticeState initialState = const PracticeLoading()})
    : super(initialState);
}
