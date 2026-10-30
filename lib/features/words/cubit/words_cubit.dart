import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/word_models.dart';

part 'words_state.dart';

/// Kelimeler sekmesinin durum yönetimi; veri katmanı bağlanınca kelimeler,
/// öneriler ve çeviri sonucu bu cubit üzerinden yüklenecek.
class WordsCubit extends Cubit<WordsState> {
  WordsCubit({WordsState initialState = const WordsLoading()})
    : super(initialState);
}
