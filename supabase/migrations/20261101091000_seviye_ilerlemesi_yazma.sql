-- Seviye ilerlemesi istemciden yazılamıyordu: tablo RLS açık ve yalnızca
-- SELECT policy'si + SELECT yetkisi vardı. Uygulama seviye açamaz,
-- "kilitli → açık" geçişini kaydedemez.
--
-- Kural: kullanıcı kendi satırını ekleyip güncelleyebilir, ANCAK
-- status='completed' koyamaz. Seviye tamamlama yalnızca
-- submit_content_test (SECURITY DEFINER) RPC'sinin yettiği bir geçiştir;
-- böylese test çözmeden seviye geçilemez.

begin;

grant insert, update on public.user_level_progress to authenticated;

drop policy if exists user_level_progress_insert_own on public.user_level_progress;
create policy user_level_progress_insert_own
  on public.user_level_progress as permissive for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and status <> 'completed'
  );

drop policy if exists user_level_progress_update_own on public.user_level_progress;
create policy user_level_progress_update_own
  on public.user_level_progress as permissive for update to authenticated
  using ((select auth.uid()) = user_id)
  with check (
    (select auth.uid()) = user_id
    and status <> 'completed'
  );

commit;
