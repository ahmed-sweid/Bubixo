import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/stories_content.dart';
import '../../../core/models/story_models.dart';

part 'stories_state.dart';

/// Hikâyeler sekmesinin durum yönetimi.
///
/// Veri katmanı henüz bağlı değil: [load] demo kataloğunu kısa bir gecikmeyle
/// döndürür, böylece yükleme durumu gerçek bir ağ isteği gibi görünür.
/// Repository bağlandığında yalnızca [load] gövdesi değişir.
class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit({StoriesState initialState = const StoriesLoading()})
    : super(initialState);

  Future<void> load() async {
    emit(const StoriesLoading());
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;

    final List<Story> stories = StoriesContent.demoStories;
    emit(
      StoriesReady(
        stories: stories,
        categories: stories
            .map((Story story) => story.category)
            .toSet()
            .toList(growable: false),
        continueStory: _unfinishedStory(stories),
      ),
    );
  }

  Story? _unfinishedStory(List<Story> stories) {
    for (final Story story in stories) {
      if (!story.isRead && story.lastReadSentenceIndex >= 0) return story;
    }
    return null;
  }
}
