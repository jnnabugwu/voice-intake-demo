-- Private bucket for bench clips: 10 MB per file, audio only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bench-audio', 'bench-audio', false, 10485760, array['audio/*'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Upload-only: anon may INSERT into this bucket, under a known speaker folder.
-- There is deliberately no SELECT, UPDATE or DELETE policy, so the public key
-- can't list, download or overwrite anything.
drop policy if exists "bench-audio anon insert" on storage.objects;
create policy "bench-audio anon insert"
  on storage.objects for insert to anon
  with check (
    bucket_id = 'bench-audio'
    and (storage.foldername(name))[1] in ('en_jn', 'es_cu', 'es_mx')
  );
