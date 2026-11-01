import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/word_models.dart';
import '../data/repositories/word_repository.dart';

part 'words_state.dart';

/// Kelimeler sekmesinin durum yönetimi: kullanıcının ezber listesi ve öneri
/// havuzu tek `WordSnapshot` okumasıyla gelir.
///
/// [repository] üretimde DI'dan gelir. Widget testleri ekranı veri katmanı
/// olmadan render ettiği için null olabilir; o durumda [load] sessiz kalır ve
/// ekranda yükleme iskeleti görünür.
class WordsCubit extends Cubit<WordsState> {
  WordsCubit({
    this.repository,
    WordsState initialState = const WordsLoading(),
  }) : super(initialState);

  final WordRepository? repository;

  Future<void> load() async {
    final WordRepository? source = repository;
    if (source == null) return;

    emit(const WordsLoading());
    final result = await source.fetchSnapshot();
    if (isClosed) return;

    result.fold(
      ifLeft: (failure) => emit(WordsError(message: failure.errorMessage)),
      ifRight: (snapshot) {
        emit(
          snapshot.isEmpty
              ? const WordsEmpty()
              : WordsReady(
                  words: snapshot.words,
                  suggestedWords: snapshot.suggestedWords,
                ),
        );
      },
    );
  }

  /// Hızlı çeviri, ekrandaki listelerde arama yapar: kelime hazinesi zaten
  /// elde, tek bir sözcük için yeniden ağa çıkmak gerekmez.
  void translate(String term) {
    final WordsReady? current = _ready;
    if (current == null) return;

    final String query = term.trim().toLowerCase();
    if (query.isEmpty) return;

    emit(
      current.copyWith(
        translation: WordTranslation(
          term: term.trim(),
          translation: _lookup(current, query, current.enToTr),
        ),
      ),
    );
  }

  /// Yön değişince sonuç sıfırlanır: eski yönün cevabı yeni yön için yanlış
  /// bir sonuçtur. (`copyWith` null'ı "değişmedi" saydığı için durum burada
  /// doğudan kurulur.)
  void swapDirection() {
    final WordsReady? current = _ready;
    if (current == null) return;
    emit(
      WordsReady(
        words: current.words,
        suggestedWords: current.suggestedWords,
        enToTr: !current.enToTr,
      ),
    );
  }

  WordsReady? get _ready {
    final WordsState current = state;
    return current is WordsReady ? current : null;
  }

  String? _lookup(WordsReady state, String query, bool enToTr) {
    for (final PoolWord word in state.suggestedWords) {
      if ((enToTr ? word.term : word.translation).toLowerCase() == query) {
        return enToTr ? word.translation : word.term;
      }
    }
    for (final Word word in state.words) {
      if ((enToTr ? word.term : word.translation).toLowerCase() == query) {
        return enToTr ? word.translation : word.term;
      }
    }
    return null;
  }
}
