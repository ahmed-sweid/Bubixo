import 'package:flutter/foundation.dart';

@immutable
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.category,
    required this.levelIndex,
    required this.coverAsset,
    required this.sentences,
    this.lastReadSentenceIndex = -1,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String category;
  final int levelIndex;
  final String coverAsset;
  final List<String> sentences;
  final int lastReadSentenceIndex;
  final bool isRead;

  Story copyWith({int? lastReadSentenceIndex, bool? isRead}) {
    return Story(
      id: id,
      title: title,
      category: category,
      levelIndex: levelIndex,
      coverAsset: coverAsset,
      sentences: sentences,
      lastReadSentenceIndex:
          lastReadSentenceIndex ?? this.lastReadSentenceIndex,
      isRead: isRead ?? this.isRead,
    );
  }
}
