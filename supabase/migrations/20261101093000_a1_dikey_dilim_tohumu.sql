-- A1 dikey dilim tohumu.
--
-- Canlı şemada katalog başlıkları dolu ama GÖVDELER boş: story_sentences,
-- vocabulary_words, vocabulary_topic_words, practice_activities,
-- practice_questions ve cevap anahtarları hiç yok; ayrıca hiçbir satır
-- yayımlanmış değil (is_published = false). Bu yüzden uygulamanın Hikâyeler,
-- Kelimeler ve Pratik sekmeleri bağlı olsa bile boş kalırdı.
--
-- Bu dosya uydurma bir müfredat yazmaz: uygulamanın Dart tarafında zaten
-- yazılmış demo hikâyelerini, temel A1 kelime listelerini ve A1 kalıp
-- alıştırmalarını mevcut şemanın beklediği satırlara dönüştürür ve yalnızca
-- bu satırları yayına alır. Diğer seviyeler, 62 dersin gövdesi ve 77 gramer
-- konusu içerik üretimi işidir; burada dokunulmaz.
--
-- Tekrar çalıştırılabilir: her bölüm var olanı denetleyip atlıyor.

begin;

-- ---------------------------------------------------------------------------
-- 1) HİKÂYELER
-- ---------------------------------------------------------------------------

-- Uygulamanın "Günlük Hayat" kategorisi A1'de zaten var, yayımda değil.
update public.story_categories c
  set is_published = true
  from public.levels l
  where c.level_id = l.id and l.code = 'A1'
    and c.parent_id is null and c.title = 'Günlük Yaşam';

-- "Klasik" kategorisi yoksa A1 için açılıyor.
insert into public.story_categories (level_id, parent_id, title, title_en, order_index, is_published)
select l.id, null, 'Klasik Hikâyeler', 'Classic Stories', 90, true
  from public.levels l
  where l.code = 'A1'
    and not exists (
      select 1 from public.story_categories c
      where c.level_id = l.id and c.title = 'Klasik Hikâyeler'
    );

insert into public.stories
  (level_id, category_id, content_type, title, title_en, summary_md, estimated_reading_minutes, order_index, is_published)
select l.id, c.id, 'story', 'The Lost Key', 'Kayıp Anahtar',
  'Soğuk bir salı gecesi evine dönen Tom anahtarını bulamaz. Kısa bir tedirginlik, sonra sıcak bir bitiş.',
  2, 1, true
  from public.levels l
  join public.story_categories c on c.level_id = l.id and c.title = 'Klasik Hikâyeler'
  where l.code = 'A1'
    and not exists (select 1 from public.stories s where s.title = 'The Lost Key');

insert into public.stories
  (level_id, category_id, content_type, title, title_en, summary_md, estimated_reading_minutes, order_index, is_published)
select l.id, c.id, 'daily_life', 'A New Start in Town', 'Kasabada Yeni Bir Başlangıç',
  'Yeni bir kasabaya taşınan Anna, tanımadığı sokakları küçük günlük iyiliklerle kendi yerine dönüştürür.',
  2, 1, true
  from public.levels l
  join public.story_categories c on c.level_id = l.id and c.title = 'Günlük Yaşam'
  where l.code = 'A1'
    and not exists (select 1 from public.stories s where s.title = 'A New Start in Town');

insert into public.story_sentences (story_id, order_index, text_en, translation_tr)
select s.id, v.ord, v.en, v.tr
  from public.stories s
  cross join (values
    (1, 'Tom came home late on a cold Tuesday night.', 'Tom soğuk bir salı gecesi eve geç geldi.'),
    (2, 'He put his bag down and looked for his key.', 'Çantasını bıraktı ve anahtarını aradı.'),
    (3, 'The key was not in his pocket.', 'Anahtar cebinde değildi.'),
    (4, 'He checked his bag, but it was empty too.', 'Çantasını kontrol etti ama o da boştu.'),
    (5, 'The street lamp lit the small garden in front of him.', 'Fener, önündeki küçük bahçeyi aydınlattı.'),
    (6, 'Then he heard a sound behind the old door.', 'Sonra eski kapının arkasından bir ses duydu.'),
    (7, 'It was his cat, sitting on a soft brown box.', 'Bu, yumuşak kahverengi bir kutunun üzerinde oturan kedisiydi.'),
    (8, 'Under the box lay the key, quiet and safe.', 'Kutunun altında anahtar yatıyordu, sessiz ve güvende.')
  ) as v(ord, en, tr)
  where s.title = 'The Lost Key'
    and not exists (select 1 from public.story_sentences ss where ss.story_id = s.id);

insert into public.story_sentences (story_id, order_index, text_en, translation_tr)
select s.id, v.ord, v.en, v.tr
  from public.stories s
  cross join (values
    (1, 'Anna moved to a new town last week.', 'Anna geçen hafta yeni bir kasabaya taşındı.'),
    (2, 'She does not know any street or any name yet.', 'Henüz hiçbir sokağı ya da ismi bilmiyor.'),
    (3, 'In the morning she buys warm bread and coffee.', 'Sabahları sıcak ekmek ve kahve alıyor.'),
    (4, 'The baker smiles and says her name correctly.', 'Fırıncı gülümsüyor ve ismini doğru söylüyor.'),
    (5, 'After class she walks home through the park.', 'Dersten sonra parkın içinden yürüyerek eve dönüyor.'),
    (6, 'Now the town feels a little bit like hers.', 'Artık kasaba biraz onun gibi hissettiriyor.')
  ) as v(ord, en, tr)
  where s.title = 'A New Start in Town'
    and not exists (select 1 from public.story_sentences ss where ss.story_id = s.id);

-- ---------------------------------------------------------------------------
-- 2) KELİMELER (A1: Selamlaşma, Aile, Renkler konuları)
-- ---------------------------------------------------------------------------

insert into public.vocabulary_words
  (level_id, word, part_of_speech, translations, pronunciation, example_en,
   example_translations, tags, order_index, is_published)
select l.id, v.word, v.pos,
  jsonb_build_object('tr', v.tr), v.pron, v.example, jsonb_build_object('tr', v.example_tr),
  v.tags, v.ord, true
  from public.levels l
  cross join (values
    ('hello'::text, 'interjection'::text, 'merhaba'::text, '/həˈloʊ/'::text,
      'Hello, how are you?'::text, 'Merhaba, nasılsın?'::text, array['greeting']::text[], 1),
    ('goodbye', 'interjection', 'hoşça kal', '/ˌɡʊdˈbaɪ/',
      'Goodbye, see you tomorrow.', 'Hoşça kal, yarın görüşürüz.', array['greeting']::text[], 2),
    ('good morning', 'phrase', 'günaydın', '/ˌɡʊd ˈmɔːrnɪŋ/',
      'Good morning, everyone!', 'Herkese günaydın!', array['greeting']::text[], 3),
    ('please', 'interjection', 'lütfen', '/pliːz/',
      'One coffee, please.', 'Bir kahve, lütfen.', array['polite']::text[], 4),
    ('thank you', 'phrase', 'teşekkür ederim', '/ˈθæŋk juː/',
      'Thank you for your help.', 'Yardımın için teşekkür ederim.', array['polite']::text[], 5),
    ('sorry', 'adjective', 'üzgün', '/ˈsɒri/',
      'Sorry, I am late.', 'Üzgünüm, geç kaldım.', array['polite']::text[], 6),
    ('name', 'noun', 'isim', '/neɪm/',
      'My name is Anna.', 'Benim adım Anna.', array['people']::text[], 7),
    ('meet', 'verb', 'tanışmak', '/miːt/',
      'Nice to meet you.', 'Tanıştığımıza memnun oldum.', array['people']::text[], 8),
    ('mother', 'noun', 'anne', '/ˈmʌðər/',
      'My mother works at a school.', 'Annem bir okulda çalışıyor.', array['family']::text[], 9),
    ('father', 'noun', 'baba', '/ˈfɑːðər/',
      'His father drives a bus.', 'Onun babası otobüs kullanıyor.', array['family']::text[], 10),
    ('sister', 'noun', 'kız kardeş', '/ˈsɪstər/',
      'She has one older sister.', 'Onun bir ablası var.', array['family']::text[], 11),
    ('brother', 'noun', 'erkek kardeş', '/ˈbrʌðər/',
      'My brother is eleven years old.', 'Erkek kardeşim on bir yaşında.', array['family']::text[], 12),
    ('family', 'noun', 'aile', '/ˈfæməli/',
      'I have a small family.', 'Küçük bir ailem var.', array['family']::text[], 13),
    ('grandmother', 'noun', 'büyükanne', '/ˈɡrænmʌðər/',
      'My grandmother tells good stories.', 'Büyükanne güzel hikâyeler anlatır.', array['family']::text[], 14),
    ('grandfather', 'noun', 'büyükbaba', '/ˈɡrænfɑːðər/',
      'My grandfather reads the paper every day.', 'Büyükbabam her gün gazete okur.', array['family']::text[], 15),
    ('aunt', 'noun', 'hala', '/ɑːnt/',
      'My aunt lives in Ankara.', 'Halam Ankara''da yaşıyor.', array['family']::text[], 16),
    ('uncle', 'noun', 'amca', '/ˈʌŋkl/',
      'My uncle is a doctor.', 'Amcam bir doktordur.', array['family']::text[], 17),
    ('red', 'adjective', 'kırmızı', '/red/',
      'The apple is red.', 'Elma kırmızıdır.', array['colour']::text[], 18),
    ('blue', 'adjective', 'mavi', '/bluː/',
      'The sky is blue today.', 'Gökyüzü bugün mavi.', array['colour']::text[], 19),
    ('green', 'adjective', 'yeşil', '/ɡriːn/',
      'I like green tea.', 'Yeşil çayı severim.', array['colour']::text[], 20),
    ('yellow', 'adjective', 'sarı', '/ˈjeloʊ/',
      'The sun looks yellow.', 'Güneş sarı görünür.', array['colour']::text[], 21),
    ('black', 'adjective', 'siyah', '/blæk/',
      'My cat is black.', 'Kedim siyahtır.', array['colour']::text[], 22),
    ('white', 'adjective', 'beyaz', '/waɪt/',
      'She wears a white shirt.', 'Beyaz bir gömlek giyiyor.', array['colour']::text[], 23),
    ('brown', 'adjective', 'kahverengi', '/braʊn/',
      'The box is brown.', 'Kutu kahverengidir.', array['colour']::text[], 24),
    ('orange', 'adjective', 'turuncu', '/ˈɒrɪndʒ/',
      'I drink orange juice.', 'Portakal suyu içiyorum.', array['colour']::text[], 25),
    ('pink', 'adjective', 'pembe', '/pɪŋk/',
      'Her bag is pink.', 'Onun çantası pembe.', array['colour']::text[], 26),
    ('grey', 'adjective', 'gri', '/ɡreɪ/',
      'The road is grey.', 'Yol gridir.', array['colour']::text[], 27)
  ) as v(word, pos, tr, pron, example, example_tr, tags, ord)
  where l.code = 'A1'
    and not exists (
      select 1 from public.vocabulary_words w
      where w.level_id = l.id and w.word = v.word
    );

-- Kelimeleri mevcut A1 konularına bağla.
insert into public.vocabulary_topic_words (topic_id, word_id, level_id, order_index)
select t.id, w.id, t.level_id,
  row_number() over (partition by t.id order by w.order_index)
  from public.vocabulary_topics t
  join public.vocabulary_words w
    on w.level_id = t.level_id
   and (
     (t.title = 'Selamlaşma ve Ayrılma'
       and w.word in ('hello', 'goodbye', 'good morning', 'please', 'thank you', 'sorry', 'name', 'meet'))
     or (t.title = 'Aile'
       and w.word in ('mother', 'father', 'sister', 'brother', 'family', 'grandmother', 'grandfather', 'aunt', 'uncle'))
     or (t.title = 'Renkler'
       and w.word in ('red', 'blue', 'green', 'yellow', 'black', 'white', 'brown', 'orange', 'pink', 'grey'))
   )
  where not exists (
    select 1 from public.vocabulary_topic_words tw
    where tw.topic_id = t.id and tw.word_id = w.id
  );

-- Kelimesi bağlanmış konuları yayına al.
update public.vocabulary_topics t
  set is_published = true
  where t.title in ('Selamlaşma ve Ayrılma', 'Aile', 'Renkler')
    and exists (select 1 from public.vocabulary_topic_words tw where tw.topic_id = t.id);

-- ---------------------------------------------------------------------------
-- 3) PRATİK (A1): boşluk doldurma + cümle dizilimi
-- ---------------------------------------------------------------------------

insert into public.practice_activities
  (level_id, title, description, activity_type, source_lesson_id, order_index, is_published)
select l.id, 'Tanışma Kalıpları', 'Selamlaşma cümlelerinde doğru kelimeyi seç.', 'fill_blank', ls.id, 1, true
  from public.levels l
  join public.lessons ls on ls.level_id = l.id and ls.order_index = 1
  where l.code = 'A1'
    and not exists (select 1 from public.practice_activities a where a.title = 'Tanışma Kalıpları');

insert into public.practice_activities
  (level_id, title, description, activity_type, order_index, is_published)
select l.id, 'Cümle Dizilimi', 'Karışmış kelimeleri doğru sıraya koy.', 'sentence_order', 2, true
  from public.levels l
  where l.code = 'A1'
    and not exists (select 1 from public.practice_activities a where a.title = 'Cümle Dizilimi');

insert into public.practice_questions (activity_id, prompt, question_type, options, explanation, order_index)
select a.id, v.prompt, v.qtype, v.options::jsonb, v.explanation, v.ord
  from public.practice_activities a
  cross join (values
    ('Doğru selamı seç: "___ morning, Anna!"'::text, 'single_choice'::text,
      '["Good","Well","Nice","Many"]'::text, 'Sabah selamı "Good morning".'::text, 1),
    ('Doğru olanı seç: "Nice ___ you."', 'single_choice',
      '["to meet","meeting","meet","met"]', 'Kalıp: "Nice to meet you".', 2),
    ('Boşluğu doldur: My ___ is Ahmed.', 'fill_blank',
      '[]', 'Kendini tanıtırken "My name is ..." denir.', 3),
    ('"Goodbye" ayrılırken kullanılır.', 'true_false',
      '["true","false"]', 'Goodbye bir veda kalıbıdır.', 4)
  ) as v(prompt, qtype, options, explanation, ord)
  where a.title = 'Tanışma Kalıpları'
    and not exists (select 1 from public.practice_questions q where q.activity_id = a.id);

insert into public.practice_questions (activity_id, prompt, question_type, options, explanation, order_index)
select a.id, v.prompt, v.qtype, v.options::jsonb, v.explanation, v.ord
  from public.practice_activities a
  cross join (values
    ('Düzelt: is / name / My / Ahmed'::text, 'sentence_order'::text,
      '["My","name","is","Ahmed"]'::text, 'Bildiri cümle: My name is Ahmed.'::text, 1),
    ('Düzelt: you / How / are', 'sentence_order',
      '["How","you","are"]', 'Soru yapısı: How are you?', 2),
    ('Düzelt: a / she / cat / has', 'sentence_order',
      '["she","a","cat","has"]', 'Özne-fiil-nesne: She has a cat.', 3)
  ) as v(prompt, qtype, options, explanation, ord)
  where a.title = 'Cümle Dizilimi'
    and not exists (select 1 from public.practice_questions q where q.activity_id = a.id);

-- Cevap anahtarları. objective soruların anahtarı yoksa
-- submit_practice_activity "missing its answer key" ile patlar.
insert into private.practice_answers (question_id, correct_answer, accepted_answers)
select pq.id, q.correct::jsonb, q.accepted::jsonb
  from (values
    ('Tanışma Kalıpları'::text, 1::int, '"Good"'::text, '[]'::text),
    ('Tanışma Kalıpları', 2, '"to meet"', '[]'),
    ('Tanışma Kalıpları', 3, '"name"', '["Name"]'),
    ('Tanışma Kalıpları', 4, 'true', '["True","TRUE"]'),
    ('Cümle Dizilimi', 1, '["My","name","is","Ahmed"]', '[]'),
    ('Cümle Dizilimi', 2, '["How","are","you"]', '[]'),
    ('Cümle Dizilimi', 3, '["She","has","a","cat"]', '[]')
  ) as q(activity, ord, correct, accepted)
  join public.practice_activities a on a.title = q.activity
  join public.practice_questions pq on pq.activity_id = a.id and pq.order_index = q.ord
  where not exists (select 1 from private.practice_answers pa where pa.question_id = pq.id);

-- ---------------------------------------------------------------------------
-- 4) SEVİYE TESTİ (A1) — submit_content_test artık çalışsın diye
-- ---------------------------------------------------------------------------

insert into public.content_tests
  (level_id, title, description, test_type, order_index, is_published)
select l.id, 'A1 Seviye Testi', 'Temel kalıpları bildiğini doğrula; geçince A2 açılır.', 'level', 1, true
  from public.levels l
  where l.code = 'A1'
    and not exists (select 1 from public.content_tests t where t.title = 'A1 Seviye Testi');

insert into public.content_test_questions (content_test_id, prompt, question_type, options, explanation, order_index)
select t.id, v.prompt, 'single_choice', v.options::jsonb, v.explanation, v.ord
  from public.content_tests t
  cross join (values
    ('"I ___ a student."'::text, '["am","is","are","be"]'::text, 'Özne "I" ile "am" kullanılır.'::text, 1),
    ('"___ is that man?" — doğru soru kelimesi hangisi?', '["What","Who","Where","When"]', 'Kişi sorusuna "Who".', 2),
    ('"child" kelimesinin çoğulu hangisi?', '["childs","children","childrens","childes"]', 'Düzensiz çoğul: children.', 3),
    ('"She ___ to school every day."', '["go","goes","going","is go"]', 'Özne "she" → "goes".', 4),
    ('"There ___ two books on the table."', '["is","are","was","been"]', 'Çokluk öznesi → "are".', 5),
    ('"expensive" kelimesinin zıddı hangisi?', '["cheap","big","free","fast"]', 'Ucuz = cheap.', 6),
    ('"I ___ like coffee."', '["don''t","doesn''t","not","no"]', 'Olumsuz: I don''t like.', 7),
    ('Aşağıdakilerden hangisi bir selam?', '["Good night","See you later","Hello","Bye"]', 'Hello karşılaşırken söylenir.', 8)
  ) as v(prompt, options, explanation, ord)
  where t.title = 'A1 Seviye Testi'
    and not exists (select 1 from public.content_test_questions q where q.content_test_id = t.id);

insert into private.content_test_answers (question_id, correct_answer, accepted_answers)
select q2.id, q.correct::jsonb, '[]'::jsonb
  from (values
    (1::int, '"am"'::text), (2, '"Who"'), (3, '"children"'), (4, '"goes"'),
    (5, '"are"'), (6, '"cheap"'), (7, '"don''t"'), (8, '"Hello"')
  ) as q(ord, correct)
  join public.content_tests t on t.title = 'A1 Seviye Testi'
  join public.content_test_questions q2
    on q2.content_test_id = t.id and q2.order_index = q.ord
  where not exists (select 1 from private.content_test_answers a where a.question_id = q2.id);

commit;
