-- Kullanıcının seviyesi: elle seçim ve yerleştirme testi sonucu tek satırda.
--
-- Neden yeni kolonlar: seviye listesi (public.levels) ve test tahmini
-- (placement_attempts.estimated_level) sunucuda zaten duruyor, ama "şu anki
-- seviyem" sorusunu cevaplayan hiçbir satır yok. user_level_progress
-- kilıt/açık/tamam DEFTERİDİR; o satır completed olduğunda aktif seviye
-- adresiz kalacağı için aktif seviye deftere yıkılmaz. Bu yüzden imza
-- (kullanıcının şu an çalıştığı bant) profiles'e taşınır, defter senkron
-- tutulur.
--
-- Neden RPC: profiles owner-only UPDATE politikası kolonu doğrudan yazmaya
-- izin verirdi, ama iki yazım (imza + defter) tek istekle atomik olmaz ve
-- istemci "test bana C2 verdi" diye kendi seviyesini uydurabilirdi. Yazım
-- iki SECURITY DEFINER RPC'den geçer; apply_placement_result seviyeyi
-- İSTEMCİDEN ALMAZ, kendi completed oturumunun estimated_level satırından
-- çözer.
--
-- Kaynak (current_level_source): 'manual' ekrandan seçildi, 'placement' test
-- sonucu uygulandı. Aşağı bantlar açılır, yukarı bantlar olduğu gibi kalır:
-- seviyeyi düşürmek kazanılmış ilerlemeyi geri almaz.

begin;

-- 1) İmza kolonları. Mevcut 4 kullanıcı NULL kalır: NULL = "henüz seçim
--    yapmadı", onboarding ekranı seçimi zorunlu kılar.
alter table public.profiles
  add column if not exists current_level_id bigint,
  add column if not exists current_level_source text,
  add column if not exists current_level_at timestamptz;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_current_level_id_fkey'
  ) then
    alter table public.profiles
      add constraint profiles_current_level_id_fkey
      foreign key (current_level_id) references public.levels (id);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_current_level_source_check'
  ) then
    alter table public.profiles
      add constraint profiles_current_level_source_check
      check (current_level_source is null
             or current_level_source in ('manual', 'placement'));
  end if;

  -- Seviye varsa kaynaği da vardır; yarı yazılmış satır şemada barınamaz.
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_current_level_source_required'
  ) then
    alter table public.profiles
      add constraint profiles_current_level_source_required
      check (current_level_id is null or current_level_source is not null);
  end if;
end
$$;

comment on column public.profiles.current_level_id is
  'Kullanıcının şu anki seviyesi (public.levels.id). NULL = henüz seçmedi.';
comment on column public.profiles.current_level_source is
  'manual | placement — imzanın nasıl oluştuğu.';
comment on column public.profiles.current_level_at is
  'İmzanın son yazıldığı an.';

-- 2) Ortak yazım bloğu. public RPC'ler bunu çağırır; kendi başına çağrılmaz
--    (aşağıda yetkisi geri alınıyor). p_uid her sorguda süzgeç olarak durur:
--    SECURITY DEFINER policy'yi aştığı için sahiplik tek güvencedir.
create or replace function private.user_level_apply(
  p_uid uuid,
  p_level_id bigint,
  p_source text
)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_level public.levels;
  v_now   timestamptz := now();
begin
  if p_uid is null then
    raise exception 'seviye kaydetmek icin giris gerekli'
      using errcode = '42501';
  end if;

  if p_source is null or p_source not in ('manual', 'placement') then
    raise exception 'gecersiz seviye kaynagi: %', coalesce(p_source, '<null>')
      using errcode = '23514';
  end if;

  select * into v_level from public.levels where id = p_level_id;
  if not found then
    raise exception 'seviye bulunamadi: %', p_level_id
      using errcode = '23514';
  end if;

  update public.profiles
     set current_level_id = v_level.id,
         current_level_source = p_source,
         current_level_at = v_now,
         updated_at = v_now
   where user_id = p_uid;
  if not found then
    raise exception 'kullanici profili yok: %', p_uid
      using errcode = '42501';
  end if;

  -- Defter senkronu (tek ifade, tek gidiş). Defterin sözlüğü live kısıtla
  -- sınırlı: locked | unlocked | completed — 'in_progress' yok, o yüzden
  -- "aktif bant" burada değil profiles.current_level_id imzasında durur.
  --   seçilen bant  : locked ise unlocked olur, completed olduğu gibi kalır
  --   alt bantlar   : locked ise unlocked olur (önkoşullar okunabilir kalsın)
  --   üst bantlar   : dokunulmaz — seviyeyi düşürmek kazanılmışi geri almaz
  update public.user_level_progress up
     set status = case
           when up.status = 'locked'
            and (up.level_id = v_level.id or l.order_index < v_level.order_index)
             then 'unlocked'
           else up.status
         end,
         unlocked_at = case
           when up.status = 'locked'
            and (up.level_id = v_level.id or l.order_index < v_level.order_index)
             then v_now
           else up.unlocked_at
         end,
         updated_at = v_now
    from public.levels l
   where up.level_id = l.id
     and up.user_id = p_uid;

  return jsonb_build_object(
    'level_id', v_level.id,
    'code', v_level.code,
    'title', v_level.title,
    'order_index', v_level.order_index,
    'source', p_source,
    'set_at', v_now
  );
end
$$;

-- 3) Elle seçim: kullanıcının kendi profili, istediği yayında seviye.
create or replace function public.set_user_level(
  p_level_id bigint,
  p_source text default 'manual'
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  return private.user_level_apply(auth.uid(), p_level_id, p_source);
end
$$;

-- 4) Test sonucunu uygula: seviye adımı istemciden gelmez, oturumun kendi
--    estimated_level alanından çözülür. Sahiplik ve kapanış zorunlu.
create or replace function public.apply_placement_result(p_attempt_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_attempt public.placement_attempts;
  v_level   public.levels;
begin
  if v_uid is null then
    raise exception 'sonuc uygulamak icin giris gerekli'
      using errcode = '42501';
  end if;

  select * into v_attempt
  from public.placement_attempts
  where id = p_attempt_id
    and user_id = v_uid;
  if not found then
    raise exception 'oturum bulunamadi veya sana ait degil: %', p_attempt_id
      using errcode = '42501';
  end if;

  if v_attempt.status <> 'completed' then
    raise exception 'oturum henüz bitmedi: %', v_attempt.status
      using errcode = '23514';
  end if;

  if v_attempt.estimated_level is null then
    raise exception 'oturum icin seviye tahmini hesaplanmamis'
      using errcode = '23514';
  end if;

  select * into v_level
  from public.levels
  where code = v_attempt.estimated_level;
  if not found then
    raise exception 'test bandi seviye katalogunda yok: %',
      v_attempt.estimated_level
      using errcode = '23514';
  end if;

  return private.user_level_apply(v_uid, v_level.id, 'placement');
end
$$;

-- 5) Yetkiler: varsayılan EXECUTE PUBLIC üzerinden anon'a da geçtiği için
--    önce PUBLIC geri alınır, sonra yalnız authenticated verilir. Özel
--    yardımıcı hiçbir role açık kalmaz — yalnız DEFINER sahibi erişir.
revoke all on function public.set_user_level(bigint, text) from public, anon;
revoke all on function public.apply_placement_result(bigint) from public, anon;
revoke all on function private.user_level_apply(uuid, bigint, text)
  from public, anon, authenticated;

grant execute on function public.set_user_level(bigint, text) to authenticated;
grant execute on function public.apply_placement_result(bigint) to authenticated;

comment on function public.set_user_level(bigint, text) is
  'Kullanıcının seviye imzasını yazar ve ilerleme defterini senkronlar (elle seçim).';
comment on function public.apply_placement_result(bigint) is
  'Kendi completed oturumunun estimated_levelını seviye imzası olarak uygular.';
comment on function private.user_level_apply(uuid, bigint, text) is
  'İmza + defter yazımının tek yeri; sahiplik auth.uid() ile süzülür.';

commit;
