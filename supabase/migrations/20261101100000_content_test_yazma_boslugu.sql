-- ============================================================================
-- 20261101100000 — content_test yazma boşluğu ve sekans yetkileri
--
-- Neden: Supabase'in public şeması için **default privileges** ayarı vardır;
-- yeni oluşturulan her tablo anon/authenticated'e otomatik olarak ALL yetkisi
-- devreder. `20261101090000` migration'ı eski 12 içerik tablosundaki yazma
-- yetkilerini geri aldı, ama o migration'dan SONRA kurulan content_test
-- tabloları (20261101092000) aynı boşluğu yeniden aldı. Bu migration o deliği
-- kapatır ve aynı kuralı sekanslara da uygular.
--
-- Kural (şemanın geri kalanıyla birebir aynı): istemci yalnızca okur. Deneme
-- kayıtlarını `private.submit_content_test` (SECURITY DEFINER) yazar — fonksiyon
-- owner `postgres` olarak çalıştığı için bu geri alma RPC'yi etkilemez.
-- ============================================================================

begin;

-- 1) Katalog tabloları: okuma kalır, yazma gider.
revoke insert, update, delete, truncate, references, trigger
  on public.content_tests, public.content_test_questions
  from anon, authenticated;

-- 2) Deneme tabloları: aynı kural — `practice_attempts` örneğinde olduğu gibi
--    istemci tarafı yazma yetkisi yoktur, yalnızca kendi satırını okur (RLS).
revoke insert, update, delete, truncate, references, trigger
  on public.content_test_attempts, public.content_test_attempt_answers
  from anon, authenticated;

-- 3) İstemci hiçbir bu tabloya insert yapmadığına göre sıradaki (identity)
--    değerini de talep edemez.
revoke usage, update
  on sequence public.content_tests_id_seq,
     public.content_test_questions_id_seq,
     public.content_test_attempts_id_seq,
     public.content_test_attempt_answers_id_seq,
     public.levels_id_seq,
     public.lessons_id_seq,
     public.grammar_topics_id_seq,
     public.vocabulary_topics_id_seq,
     public.vocabulary_words_id_seq,
     public.vocabulary_topic_words_id_seq,
     public.stories_id_seq,
     public.story_categories_id_seq,
     public.story_sentences_id_seq,
     public.story_sentence_tokens_id_seq,
     public.practice_activities_id_seq,
     public.practice_questions_id_seq,

     -- Pratik denemelerini de yalnızca `private.submit_practice_activity` yazar;
     -- tablolarda INSERT yetkisi zaten yoktu, sekans yetimi kalıyordu.
     public.practice_attempts_id_seq,
     public.practice_attempt_answers_id_seq
  from anon, authenticated;

-- 4) Gereksiz politikayı kaldır: `private` şemasında RLS kapalı, kapı ACL'dir ve
--    bu tablonun anon/authenticated'e zaten hiçbir ACL izni yok. Politika bu
--    yüzden hiç değerlendirilmez; `practice_answers` konvansiyonu da budur.
drop policy if exists "Content test answer keys are inaccessible to client roles"
  on private.content_test_answers;

commit;
