import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/practice_models.dart';

part 'practice_detail_state.dart';

/// Pratik detayının durum yönetimi; seçilen türün seviye kırılımı veri
/// katmanı bağlanınca bu cubit üzerinden yüklenecek.
class PracticeDetailCubit extends Cubit<PracticeDetailState> {
  PracticeDetailCubit({
    PracticeDetailState initialState = const PracticeDetailLoading(),
  }) : super(initialState);
}
