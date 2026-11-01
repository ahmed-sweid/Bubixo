-- submit_content_test RPC'si var olmayan dört tabloya yazıyordu ve bu yüzden
-- çağrıldığında 42P01 (relation does not exist) ile patlıyordu:
--   public.content_tests, public.content_test_questions,
--   public.content_test_attempts, public.content_test_attempt_answers,
--   private.content_test_answers
-- Bu dosya o alt sistemi, function gövdesinin birebir beklediğu kolon ve
-- adlarla kurar. practice_* ailesinin mevcut desenleri örnek alındı.
-- Mevcut hiçbir tablo, kolon veya veri değiştirilmez.

begin;

-- 1) Test tanımı (katalog). Bir test bir seviyeye ya da bir derse/gramer
--    konusuna/hikâyeye bağlıdır; function bu yüzden her iki alanı da sorguluyor.
create table if not exists public.content_tests (
  id bigint generated always as identity primary key,
  level_id bigint references public.levels (id) on delete restrict,
  lesson_id bigint references public.lessons (id) on delete cascade,
  grammar_topic_id bigint references public.grammar_topics (id) on delete cascade,
  story_id bigint references public.stories (id) on delete cascade,
  title text not null,
  description text,
  test_type text not null,
  order_index integer not null,
  is_published boolean not null default false,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint content_tests_title_required check (length(btrim(title)) > 0),
  constraint content_tests_order_positive check (order_index > 0),
  constraint content_tests_type_valid check (
    test_type = any (array['level', 'lesson', 'grammar', 'story'])
  ),
  constraint content_tests_has_anchor check (
    num_nonnulls(level_id, lesson_id, grammar_topic_id, story_id) >= 1
  ),
  constraint content_tests_one_source check (
    num_nonnulls(lesson_id, grammar_topic_id, story_id) <= 1
  ),
  constraint content_tests_type_matches_anchor check (
    (test_type = 'level' and level_id is not null
      and lesson_id is null and grammar_topic_id is null and story_id is null)
    or (test_type = 'lesson' and lesson_id is not null)
    or (test_type = 'grammar' and grammar_topic_id is not null)
    or (test_type = 'story' and story_id is not null)
  )
);

create unique index if not exists content_tests_level_order_key
  on public.content_tests (level_id, order_index)
  where level_id is not null;

drop trigger if exists content_tests_set_updated_at on public.content_tests;
create trigger content_tests_set_updated_at
  before update on public.content_tests
  for each row execute function private.set_updated_at();

-- 2) Sorular. Doğru cevap bu tabloda DURMAZ; private.content_test_answers'ta.
create table if not exists public.content_test_questions (
  id bigint generated always as identity primary key,
  content_test_id bigint not null
    references public.content_tests (id) on delete cascade,
  prompt text not null,
  question_type text not null,
  options jsonb not null default '[]'::jsonb,
  media_url text,
  explanation text,
  order_index integer not null,
  created_at timestamp with time zone not null default now(),
  constraint content_test_questions_prompt_required check (length(btrim(prompt)) > 0),
  constraint content_test_questions_type_valid check (
    question_type = any (array[
      'single_choice', 'multiple_choice', 'true_false', 'fill_blank',
      'sentence_order', 'matching', 'listening_choice', 'short_answer',
      'speaking_response'
    ])
  ),
  constraint content_test_questions_options_array check (jsonb_typeof(options) = 'array'),
  constraint content_test_questions_order_positive check (order_index > 0),
  constraint content_test_questions_test_order_unique unique (content_test_id, order_index)
);

create index if not exists content_test_questions_test_order_idx
  on public.content_test_questions (content_test_id, order_index);

-- 3) Cevap anahtarı: API şemasında değil, private'da. İstemci okuyamaz.
create table if not exists private.content_test_answers (
  question_id bigint primary key
    references public.content_test_questions (id) on delete cascade,
  correct_answer jsonb not null,
  accepted_answers jsonb not null default '[]'::jsonb,
  constraint content_test_answers_accepted_array check (jsonb_typeof(accepted_answers) = 'array')
);

-- 4) Denemeler. function attempt_number/toplam/started_at yazıyor,
--    sonra score/correct_answers/passed/submitted_at güncelliyor.
create table if not exists public.content_test_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  content_test_id bigint not null
    references public.content_tests (id) on delete cascade,
  attempt_number integer not null,
  total_questions integer not null,
  correct_answers integer,
  score numeric,
  passed boolean,
  started_at timestamp with time zone not null default now(),
  submitted_at timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  constraint content_test_attempts_number_positive check (attempt_number > 0),
  constraint content_test_attempts_total_positive check (total_questions > 0),
  constraint content_test_attempts_correct_non_negative check (correct_answers >= 0),
  constraint content_test_attempts_score_range check (score >= 0 and score <= 100),
  constraint content_test_attempts_user_test_number_unique
    unique (user_id, content_test_id, attempt_number)
);

create index if not exists content_test_attempts_user_test_idx
  on public.content_test_attempts (user_id, content_test_id);

-- 5) Verilen cevapların kaydı.
create table if not exists public.content_test_attempt_answers (
  id bigint generated always as identity primary key,
  attempt_id bigint not null
    references public.content_test_attempts (id) on delete cascade,
  question_id bigint not null
    references public.content_test_questions (id) on delete cascade,
  submitted_answer jsonb not null,
  is_correct boolean,
  answered_at timestamp with time zone not null default now(),
  constraint content_test_attempt_answers_attempt_question_unique
    unique (attempt_id, question_id)
);

-- 6) RLS: içerik tarafı yalnızca yayımlanmışı görür, kullanıcı tarafı sadece kendi satırları.
alter table public.content_tests enable row level security;
alter table public.content_test_questions enable row level security;
alter table public.content_test_attempts enable row level security;
alter table public.content_test_attempt_answers enable row level security;
alter table private.content_test_answers enable row level security;

drop policy if exists "Published content tests are readable" on public.content_tests;
create policy "Published content tests are readable"
  on public.content_tests as permissive for select to anon, authenticated
  using (is_published = true);

drop policy if exists "Questions of published tests are readable" on public.content_test_questions;
create policy "Questions of published tests are readable"
  on public.content_test_questions as permissive for select to anon, authenticated
  using (
    exists (
      select 1 from public.content_tests t
      where t.id = content_test_id and t.is_published = true
    )
  );

drop policy if exists "Users can read their own test attempts" on public.content_test_attempts;
create policy "Users can read their own test attempts"
  on public.content_test_attempts as permissive for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can read answers of their own attempts"
  on public.content_test_attempt_answers;
create policy "Users can read answers of their own attempts"
  on public.content_test_attempt_answers as permissive for select to authenticated
  using (
    exists (
      select 1 from public.content_test_attempts a
      where a.id = attempt_id and a.user_id = (select auth.uid())
    )
  );

-- Cevap anahtarını istemci rolüne policy bile olsa açmıyoruz; deseni kopyalıyoruz.
drop policy if exists "Content test answer keys are inaccessible to client roles"
  on private.content_test_answers;
create policy "Content test answer keys are inaccessible to client roles"
  on private.content_test_answers as permissive for all to anon, authenticated
  using (false) with check (false);

-- 7) Yetkiler: katalog salt okunur, denemeler salt okunur.
--    Yazmayı SECURITY DEFINER olan private.submit_content_test yapar.
grant select on public.content_tests, public.content_test_questions to anon, authenticated;
grant select on public.content_test_attempts, public.content_test_attempt_answers to authenticated;
grant all on public.content_tests, public.content_test_questions,
  public.content_test_attempts, public.content_test_attempt_answers,
  private.content_test_answers to service_role;

commit;
