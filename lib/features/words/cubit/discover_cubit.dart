import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/word_models.dart';

part 'discover_state.dart';

/// Kelime Keşfet sayfasının durum yönetimi; kelime havuzu ve kategoriler
/// veri katmanı bağlanınca bu cubit üzerinden yüklenecek.
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({DiscoverState initialState = const DiscoverLoading()})
    : super(initialState);
}
