-- Seviye belirleme testi (placement) sunucu tarafı akışı.
--
-- Neden yeni fonksiyon: cevap anahtarı private.placement_question_keys
-- tablosunda ve o tablo hem ACL hem RLS (using=false/check=false) ile
-- anon+authenticated'a kapali. Yani is_correct istemcide hesaplanamaz;
-- hesaplanirse kullaniciya cevap anahtari indirilmis olur. Bu dosya
-- dogrulamayi, siradaki sorunun secimini ve seviye tahminini Postgres'e
-- tasiyan uc SECURITY DEFINER RPC kurar. Mevcut tablolarda hiçbir kolon,
-- veri veya policy degistirilmez.
--
-- Kural surumu: band_evidence_v1 (plan 12.4). Tahmin ham puandan degil
-- band-bazli kanittan uretilir; adaptive_config.routing'in "evrensel CEFR
-- cut-score yazma" uyarisina uyulur. Esilik durumunda dusuk band secilir.
-- Her attempt'in result_notes alanina hangi kanitin hangi kari verdigi
-- yazilir, boylece pilot verisiyle kalibrasyon geri okunabilir.
--
-- Oturum kurallari tablo policy'lerinde zaten duruyor: kullanici yalniz
-- kendi placement_attempts satirlarini ve kendi attempt'lerinin cevaplarini
-- gorur. Fonksiyon SECURITY DEFINER oldugu icin policy'yi atliyor; bu yuzden
-- her yazma auth.uid() ile suzulen satir uzerine yapilir, suzemezse 42501
-- ile patlar ve baska kullanicinin oturumuna dokunmaz.

begin;

-- 1) CEFR band siralamasi ve band etiketi tek kaynaktan. Alfabetik siraya
--    guvenmek sessizce bozulur; dizi indeksi acik kaynak bir sira.
create or replace function private.placement_band_rank(p_band text)
returns smallint
language sql
immutable
set search_path = ''
as $$
  select coalesce(
    array_position(
      array['A1', 'A2', 'B1', 'B2', 'C1', 'C2']::text[],
      p_band
    ),
    1
  )::smallint
$$;

-- 2) Istemciye giden soru yuku: prompt + secenekler. Anahtar ve kabul
--    edilen cevap listesi bu payload'ta YOK.
create or replace function private.placement_question_payload(p_question_id bigint)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select jsonb_build_object(
    'id', q.id,
    'code', q.question_code,
    'stage', q.stage,
    'cefr_level', q.cefr_level,
    'skill', q.skill,
    'domain', q.domain,
    'question_type', q.question_type,
    'prompt', q.prompt,
    'options', coalesce(q.options, '[]'::jsonb),
    'media_url', q.media_url,
    'explanation', q.explanation,
    'points', q.points
  )
  from public.placement_questions q
  where q.id = p_question_id
$$;

-- 3) Band kaniti ve seviye tahmini (plan 12.4).
--
--    asama 1  : her bandin iki tarama sorusu. Gecici band = her iki sorusu
--               da dogru olan en yuksek band; yoksa en az bir dogru cikan en
--               yuksek band; o da yoksa A1.
--    asama 2  : gecici band + bir ust bandin dogrulama sorulari. Ust bandin
--               >=2 sorusu dogruysa tahmin bir yukari; gecici bandin >=2
--               sorusu yanlissa bir asagi.
--    asama 3  : yalniz iki komsu bandin asama-2 kaniti esitse (esik) sorulur;
--               orada da esik bozulmuyosa dusuk band kalir.
--    guven    : yukari/asagi kayma tek basina netlesirse high, esik asama 3
--               ile akilladiysa medium, esik asama 3 yazilmadan dusuk bandla
--               kapandiysa low, diger hallerde medium.
--
--    Dinen alanlar: band (gecici), final_band, up_band, down_band, tie,
--    confidence, answered, correct, points, max_points, skill_scores,
--    band_evidence.
--
--    Tek bir SQL ifadesi: band bazli toplamlar baska sorgudan okunursa CTE
--    kapsami kaybolur ve ikinci sorgu tabloyu bulamaz.
create or replace function private.placement_estimate(p_attempt_id bigint)
returns jsonb
language sql
stable
set search_path = ''
as $$
with answered_items as (
  select
    q.cefr_level,
    q.stage,
    q.skill,
    q.points,
    a.is_correct
  from public.placement_question_answers a
  join public.placement_questions q on q.id = a.question_id
  where a.attempt_id = p_attempt_id
),
band_stats as (
  select
    cefr_level as band,
    private.placement_band_rank(cefr_level) as band_rank,
    count(*) as answered,
    count(*) filter (where is_correct) as correct,
    count(*) filter (where stage = 1) as s1_answered,
    count(*) filter (where stage = 1 and is_correct) as s1_correct,
    count(*) filter (where stage = 2) as s2_answered,
    count(*) filter (where stage = 2 and is_correct) as s2_correct,
    count(*) filter (where stage = 3) as s3_answered,
    count(*) filter (where stage = 3 and is_correct) as s3_correct,
    coalesce(sum(points), 0) as max_points,
    coalesce(sum(points) filter (where is_correct), 0) as points
  from answered_items
  group by cefr_level
),
band_evidence as (
  select coalesce(jsonb_agg(to_jsonb(bs) order by bs.band_rank), '[]'::jsonb) as rows
  from band_stats bs
),
totals as (
  select
    coalesce(sum(bs.answered), 0)::integer as answered,
    coalesce(sum(bs.correct), 0)::integer as correct,
    coalesce(sum(bs.points), 0) as points,
    coalesce(sum(bs.max_points), 0) as max_points
  from band_stats bs
),
skill_evidence as (
  select
    ai.skill,
    jsonb_build_object(
      'answered', count(*),
      'correct', count(*) filter (where ai.is_correct),
      'points', coalesce(sum(ai.points) filter (where ai.is_correct), 0)
    ) as evidence
  from answered_items ai
  group by ai.skill
),
skill_scores as (
  select coalesce(jsonb_object_agg(se.skill, se.evidence), '{}'::jsonb) as value
  from skill_evidence se
),
-- Gecici band: henuz hic cevap yoksa tek satir doner ve A1'e duser.
provisional as (
  select coalesce(
    (array_agg(bs.band order by bs.band_rank desc)
      filter (where bs.s1_answered = 2 and bs.s1_correct = 2))[1],
    (array_agg(bs.band order by bs.band_rank desc)
      filter (where bs.s1_correct >= 1))[1],
    'A1'
  ) as band
  from band_stats bs
),
bands as (
  select
    p.band,
    private.placement_band_rank(p.band) as band_rank,
    case
      when private.placement_band_rank(p.band) < 6
      then (array['A1', 'A2', 'B1', 'B2', 'C1', 'C2']::text[])
        [private.placement_band_rank(p.band) + 1]
    end as up_band,
    case
      when private.placement_band_rank(p.band) > 1
      then (array['A1', 'A2', 'B1', 'B2', 'C1', 'C2']::text[])
        [private.placement_band_rank(p.band) - 1]
    end as down_band
  from provisional p
),
-- Her band satirina gecici banda gore rol verilir: kendi mi, komsumu.
marked as (
  select
    bs.*,
    b.band as prov_band,
    b.band_rank as prov_rank,
    b.up_band,
    b.down_band,
    case
      when bs.band_rank = b.band_rank then 'own'
      when bs.band = b.up_band then 'up'
    end as role
  from band_stats bs
  cross join bands b
),
-- Cevap hicsizken de tek satir donmesi icin GROUP BY yok; band alanlari
-- sabit oldugundan max() ile tasinir.
compare as (
  select
    coalesce(max(m.prov_band), 'A1') as prov_band,
    coalesce(max(m.prov_rank), 1)::smallint as prov_rank,
    max(m.up_band) as up_band,
    max(m.down_band) as down_band,
    coalesce(max(m.s2_answered) filter (where m.role = 'own'), 0) as own_s2_answered,
    coalesce(max(m.s2_correct) filter (where m.role = 'own'), 0) as own_s2_correct,
    coalesce(max(m.s3_answered) filter (where m.role = 'own'), 0) as own_s3_answered,
    coalesce(max(m.s3_correct) filter (where m.role = 'own'), 0) as own_s3_correct,
    coalesce(max(m.s2_answered) filter (where m.role = 'up'), 0) as up_s2_answered,
    coalesce(max(m.s2_correct) filter (where m.role = 'up'), 0) as up_s2_correct,
    coalesce(max(m.s3_answered) filter (where m.role = 'up'), 0) as up_s3_answered,
    coalesce(max(m.s3_correct) filter (where m.role = 'up'), 0) as up_s3_correct
  from marked m
),
rules as (
  select
    c.*,
    -- ust band tek basina tasidi
    (c.up_s2_answered >= 2 and c.up_s2_correct >= 2) as up_ok,
    -- gecici bandin en az iki sorusu yanlis
    (c.own_s2_answered >= 2 and (c.own_s2_answered - c.own_s2_correct) >= 2) as own_failed,
    (c.own_s3_answered >= 1 and c.up_s3_answered >= 1
      and c.own_s3_correct <> c.up_s3_correct) as s3_decisive
  from compare c
),
-- tie bir ust alanin bilesimi oldugu icin ayri seviyede hesaplanir: ayni
-- SELECT listesinde bir alias baska bir alias'in icinde kullanilamaz.
ties as (
  select
    r.*,
    (not r.up_ok and not r.own_failed
      and r.up_band is not null
      and r.own_s2_answered >= 2
      and r.up_s2_answered >= 2
      and r.own_s2_correct = r.up_s2_correct) as tie
  from rules r
),
decided as (
  select
    t.*,
    case
      when t.up_ok then t.up_band
      when t.own_failed then coalesce(t.down_band, t.prov_band)
      when t.tie and t.s3_decisive and t.up_s3_correct > t.own_s3_correct then t.up_band
      else t.prov_band
    end as final_band,
    -- Esik cozulmeden dusuk bandda kapandiysa low: plan 12.4 madde 5.
    case
      when t.up_ok or t.own_failed then 'high'
      when t.tie and not t.s3_decisive then 'low'
      else 'medium'
    end as confidence
  from ties t
)
select jsonb_build_object(
  'rule', 'band_evidence_v1',
  'band', d.prov_band,
  'final_band', d.final_band,
  'up_band', d.up_band,
  'down_band', d.down_band,
  'tie', d.tie,
  'confidence', d.confidence,
  'answered', t.answered,
  'correct', t.correct,
  'points', t.points,
  'max_points', t.max_points,
  'score', round(
    100 * t.points / nullif(t.max_points, 0),
    2
  ),
  'skill_scores', coalesce(ss.value, '{}'::jsonb),
  'band_evidence', coalesce(be.rows, '[]'::jsonb)
)
from decided d
cross join totals t
cross join skill_scores ss
cross join band_evidence be
$$;

-- 4) Siradaki soru ve asama ilerlemesi.
--
--    Asama 1 tum bankayi tarar (band gozetmez). Asama 2 ve 3 yalniz gecici
--    bandin ve bir ustunun sorularini sorar. Asama 1 bitince asama 2'ye,
--    asama 2 bitip kanit esitse asama 3'e gecilir; asama 3'te soru yoksa
--    oturum burada kapanir. Aday kalmadiysa attempt 'completed' olarak
--    kapatilir ve tahmin alanlarina islenir.
--
--    Bu fonksiyon placement_attempts uzerine UPDATE yazdigi icin VOLATILE
--    kalmali: stable işaretli bir fonksiyon veri degistiremez.
create or replace function private.placement_route(p_attempt_id bigint)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_attempt   public.placement_attempts;
  v_estimate  jsonb;
  v_band      text;
  v_window    text[];
  v_question  public.placement_questions;
  v_stage     smallint;
  v_next_stage smallint;
begin
  select * into v_attempt
  from public.placement_attempts
  where id = p_attempt_id;

  if not found then
    return jsonb_build_object('finished', true, 'question', null);
  end if;

  v_estimate := private.placement_estimate(p_attempt_id);
  v_band := v_estimate ->> 'band';
  v_stage := v_attempt.current_stage;

  <<next_stage>>
  loop
    v_window := case
      when v_stage = 1
        then array['A1', 'A2', 'B1', 'B2', 'C1', 'C2']::text[]
      else array[v_band, v_estimate ->> 'up_band']::text[]
    end;
    v_window := array_remove(v_window, null);

    select q.* into v_question
    from public.placement_questions q
    where q.placement_test_id = v_attempt.placement_test_id
      and q.is_active
      and q.stage = v_stage
      and q.cefr_level = any (v_window)
      and not exists (
        select 1
        from public.placement_question_answers a
        where a.attempt_id = p_attempt_id
          and a.question_id = q.id
      )
    -- Gecici bandin dogrulama sorulari once gelir; ust band ancak o bittikten
    -- sonra sorulur.
    order by
      (q.cefr_level = v_band) desc,
      q.order_index
    limit 1;

    if found then
      return jsonb_build_object(
        'finished', false,
        'stage', v_stage,
        'question', private.placement_question_payload(v_question.id),
        'level', v_estimate ->> 'final_band',
        'confidence', v_estimate ->> 'confidence'
      );
    end if;

    -- Asamanin adayi bitti: bir sonrasi var mi?
    v_next_stage := case
      when v_stage = 1 then 2
      when v_stage = 2
           and coalesce((v_estimate ->> 'tie')::boolean, false)
           and v_estimate ->> 'up_band' is not null
      then 3
      else null
    end;

    if v_next_stage is not null
       and exists (
         select 1
         from public.placement_questions q
         where q.placement_test_id = v_attempt.placement_test_id
           and q.is_active
           and q.stage = v_next_stage
           and q.cefr_level = any (v_window)
       ) then
      v_stage := v_next_stage;
      update public.placement_attempts
        set current_stage = v_stage
        where id = p_attempt_id;
      continue next_stage;
    end if;

    exit next_stage;
  end loop;

  -- Aday kalmadi: sonucu yaz ve oturumu kapat.
  update public.placement_attempts
  set
    status = 'completed',
    submitted_at = now(),
    current_stage = v_stage,
    estimated_level = v_estimate ->> 'final_band',
    confidence = v_estimate ->> 'confidence',
    total_questions = (v_estimate ->> 'answered')::integer,
    correct_answers = (v_estimate ->> 'correct')::integer,
    score = coalesce((v_estimate ->> 'score')::numeric, 0),
    skill_scores = v_estimate -> 'skill_scores',
    result_notes = jsonb_build_object(
      'rule', v_estimate ->> 'rule',
      'screening_band', v_estimate -> 'band',
      'estimated_band', v_estimate -> 'final_band',
      'adjacent_band', v_estimate -> 'up_band',
      'tie', v_estimate -> 'tie',
      'band_evidence', v_estimate -> 'band_evidence'
    )
  where id = p_attempt_id
  returning * into v_attempt;

  return jsonb_build_object(
    'finished', true,
    'stage', v_attempt.current_stage,
    'question', null,
    'level', v_attempt.estimated_level,
    'confidence', v_attempt.confidence,
    'answered', v_attempt.total_questions,
    'correct', v_attempt.correct_answers,
    'score', v_attempt.score,
    'skill_scores', v_attempt.skill_scores,
    'attempt_number', v_attempt.attempt_number
  );
end
$$;

-- 5) Testi baslat ya da suren oturuma don. Yayinlanmis test yoksa hata degil
--    test: null doner; UI bos durumu gosterir.
create or replace function public.placement_start_attempt()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_test    public.placement_tests;
  v_attempt public.placement_attempts;
  v_route   jsonb;
begin
  if v_uid is null then
    raise exception 'seviye testi oturumu icin giris gerekli'
      using errcode = '42501';
  end if;

  select * into v_test
  from public.placement_tests
  where is_published
  order by version desc, id desc
  limit 1;

  if not found then
    return jsonb_build_object('test', null);
  end if;

  select * into v_attempt
  from public.placement_attempts
  where user_id = v_uid
    and placement_test_id = v_test.id
    and status = 'in_progress'
  order by id desc
  limit 1;

  if not found then
    insert into public.placement_attempts (
      user_id, placement_test_id, attempt_number, status,
      current_stage, total_questions, correct_answers
    )
    values (
      v_uid,
      v_test.id,
      coalesce(
        (
          select max(a.attempt_number)
          from public.placement_attempts a
          where a.user_id = v_uid
            and a.placement_test_id = v_test.id
        ),
        0
      ) + 1,
      'in_progress',
      1,
      0,
      0
    )
    returning * into v_attempt;
  end if;

  v_route := private.placement_route(v_attempt.id);

  return jsonb_build_object(
    'test', jsonb_build_object(
      'id', v_test.id,
      'code', v_test.code,
      'title', v_test.title,
      'description', v_test.description,
      'version', v_test.version
    ),
    'attempt', jsonb_build_object(
      'id', v_attempt.id,
      'attempt_number', v_attempt.attempt_number,
      'status', v_attempt.status,
      'stage', v_route -> 'stage'
    ),
    'route', v_route
  );
end
$$;

-- 6) Cevabi dogrula, kaydet ve siradaki soruyu dondur.
--
--    Anahtar yalniz burada okunur: tek_secenek gibi objektif tiplerde
--    submitted_answer ile correct_answer id alani karsilastirilir ve
--    accepted_answers listesi de ek kabul olarak gecer.
--    writing_prompt/speaking_prompt objektif degil; adaptive_config.scoring
--    bunlar için rubrik istiyor, bu yuzden tahmin edilip yanlis sayilmazlar:
--    is_correct null birakilir, puanlari kanit havuzuna girmez.
--    Kullanicinin kendi sectigi id ve aciklama doner; anahtar donmez.
create or replace function public.placement_submit_answer(
  p_attempt_id bigint,
  p_question_id bigint,
  p_answer jsonb,
  p_response_time_ms integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := auth.uid();
  v_attempt   public.placement_attempts;
  v_question  public.placement_questions;
  v_key       private.placement_question_keys;
  v_correct   boolean;
  v_points    numeric;
  v_route     jsonb;
begin
  if v_uid is null then
    raise exception 'seviye testi cevabi icin giris gerekli'
      using errcode = '42501';
  end if;

  select * into v_attempt
  from public.placement_attempts
  where id = p_attempt_id
    and user_id = v_uid;

  if not found then
    raise exception 'oturum bulunamadi ya da sana ait degil'
      using errcode = '42501';
  end if;

  if v_attempt.status <> 'in_progress' then
    raise exception 'kapali oturuma cevap yazilamaz'
      using errcode = '23514';
  end if;

  select * into v_question
  from public.placement_questions
  where id = p_question_id
    and placement_test_id = v_attempt.placement_test_id
    and is_active;

  if not found then
    raise exception 'soru bu testin aktif sorusu degil'
      using errcode = '23503';
  end if;

  if exists (
    select 1
    from public.placement_question_answers a
    where a.attempt_id = v_attempt.id
      and a.question_id = v_question.id
  ) then
    raise exception 'bu soru bu oturumda zaten cevaplanmis'
      using errcode = '23505';
  end if;

  select * into v_key
  from private.placement_question_keys
  where question_id = v_question.id;

  if v_question.question_type in ('writing_prompt', 'speaking_prompt') then
    v_correct := null;
    v_points  := null;
  elsif found then
    v_correct := (
      p_answer ->> 'id' = v_key.correct_answer ->> 'id'
      or exists (
        select 1
        from jsonb_array_elements(v_key.accepted_answers) accepted
        where accepted ->> 'id' = p_answer ->> 'id'
      )
    );
    v_points := case when v_correct then v_question.points else 0 end;
  else
    -- Anahtarsiz soru dogrulanamaz: bu icerik hatasi, kullanicinin puanlari
    -- degil. Cevap kaydedilir ama kanit sayilmaz.
    v_correct := null;
    v_points  := null;
  end if;

  insert into public.placement_question_answers (
    attempt_id, question_id, submitted_answer, is_correct,
    points_awarded, response_time_ms
  )
  values (
    v_attempt.id,
    v_question.id,
    p_answer,
    v_correct,
    v_points,
    greatest(coalesce(p_response_time_ms, 0), 0)
  );

  update public.placement_attempts a
  set
    total_questions = s.answered,
    correct_answers = s.correct
  from (
    select
      count(*) as answered,
      count(*) filter (where x.is_correct) as correct
    from public.placement_question_answers x
    where x.attempt_id = v_attempt.id
  ) s
  where a.id = v_attempt.id;

  v_route := private.placement_route(v_attempt.id);

  return jsonb_build_object(
    'is_correct', v_correct,
    'points_awarded', v_points,
    'question_id', v_question.id,
    'selected_answer_id', p_answer -> 'id',
    'explanation', v_question.explanation,
    'route', v_route
  );
end
$$;

-- 7) Sonucu yeniden oku (uygulama yeniden acildiginda ya da profil "tekrar
--    test" akisindan). Yalniz kendi oturumun ozeti doner.
create or replace function public.placement_get_result(p_attempt_id bigint)
returns jsonb
language plpgsql
stable
set search_path = ''
as $$
declare
  v_attempt public.placement_attempts;
begin
  select * into v_attempt
  from public.placement_attempts
  where id = p_attempt_id
    and user_id = auth.uid();

  if not found then
    raise exception 'oturum bulunamadi ya da sana ait degil'
      using errcode = '42501';
  end if;

  return jsonb_build_object(
    'attempt_id', v_attempt.id,
    'status', v_attempt.status,
    'stage', v_attempt.current_stage,
    'attempt_number', v_attempt.attempt_number,
    'level', v_attempt.estimated_level,
    'confidence', v_attempt.confidence,
    'answered', v_attempt.total_questions,
    'correct', v_attempt.correct_answers,
    'score', v_attempt.score,
    'skill_scores', v_attempt.skill_scores,
    'result_notes', v_attempt.result_notes,
    'started_at', v_attempt.started_at,
    'submitted_at', v_attempt.submitted_at
  );
end
$$;

-- 8) Yetkiler: varsayilan EXECUTE hak PUBLIC uzerinden anon'a da gectigi
--    icin once PUBLIC geri alinir, sonra yalniz authenticated verilir.
--    private.asamadaki yardimci fonksiyonlar hicsiz kullanicidan cagrilmaz
--    (SECURITY DEFINER sahibi postgres calistirir), onlara hak verilmez.
revoke all on function public.placement_start_attempt() from public, anon;
revoke all on function public.placement_submit_answer(bigint, bigint, jsonb, integer) from public, anon;
revoke all on function public.placement_get_result(bigint) from public, anon;

grant execute on function public.placement_start_attempt() to authenticated;
grant execute on function public.placement_submit_answer(bigint, bigint, jsonb, integer) to authenticated;
grant execute on function public.placement_get_result(bigint) to authenticated;

comment on function public.placement_start_attempt() is
  'Yayinlanmis seviye testini baslatir ya da suren oturumu geri verir; anahtar tasimaz.';
comment on function public.placement_submit_answer(bigint, bigint, jsonb, integer) is
  'Cevabi private anahtarla dogrular, kaydeder ve adaptif siradaki soruyu doner.';
comment on function public.placement_get_result(bigint) is
  'Oturumun seviye tahminini, guvenini ve beceri kanitlarini okur.';
comment on function private.placement_route(bigint) is
  'Asama ilerlemesi ve soru secimi; aday kalmayinca attempti completed kapatir.';
comment on function private.placement_estimate(bigint) is
  'band_evidence_v1: cevap kanitindan gecici band, nihai band ve guven uretir.';

commit;
