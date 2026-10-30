import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/story_models.dart';

part 'stories_state.dart';

/// Hikâyeler sekmesinin durum yönetimi; veri katmanı bağlanınca hikâyeler
/// ve kategoriler bu cubit üzerinden yüklenecek.
class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit({StoriesState initialState = const StoriesLoading()})
    : super(initialState);
}
