-- Güvenlik sertleştirmesi: içerik (katalog) tabloları ve okuma view'ları
-- yalnızca SELECT görmelidir. Daha önce anon ve authenticated rollerine
-- INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER de verilmişti; RLS
-- policy'leri yazmayı reddetse de bu, savunma katmanlarını zayıflatıyordu:
-- policy'lerden biri yanlışlıkla gevşetilirse anon içerği silebilirdi.
-- Bu dosya yalnızca yetki DARALTIR, hiçbir veriye dokunmaz.

begin;

-- İçerik tabloları: yazma yetkileri geri alınıyor.
revoke insert, update, delete, truncate, references, trigger
  on public.levels from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.lessons from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.grammar_topics from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.vocabulary_topics from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.vocabulary_words from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.vocabulary_topic_words from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.stories from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.story_categories from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.story_sentences from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.story_sentence_tokens from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.practice_activities from anon, authenticated;
revoke insert, update, delete, truncate, references, trigger
  on public.practice_questions from anon, authenticated;

-- Okuma view'ları: view üzerinden dolaylı yazma denemesi de kapatılıyor.
revoke insert, update, delete, truncate, references, trigger
  on public.v_grammar_catalog, public.v_grammar_details,
    public.v_lesson_details, public.v_lessons_catalog,
    public.v_stories_catalog, public.v_topic_activity_catalog,
    public.v_topic_learning_progress, public.v_learning_home_options,
    public.v_vocabulary_catalog, public.v_vocabulary_review_queue
  from anon, authenticated;

-- Yalnızca okuma hakkı kaldığını açıkça yeniden tanımlıyoruz.
grant select on public.levels, public.lessons, public.grammar_topics,
  public.vocabulary_topics, public.vocabulary_words,
  public.vocabulary_topic_words, public.stories, public.story_categories,
  public.story_sentences, public.story_sentence_tokens,
  public.practice_activities, public.practice_questions
  to anon, authenticated;

commit;
