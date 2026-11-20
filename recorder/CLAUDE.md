# Recorder: bench clip uploader

A throwaway one-page web app. Two friends open a link on their phones, read the 21 bench lines aloud at their own pace, and each clip uploads to a Supabase Storage bucket. It lives for one weekend; then the deployment comes down.

**Scope:** the lines, a record button, an upload. Plain page, readable on a phone, no auth, no custom domain, no design work. Ship it in under an hour; the friends are waiting on the link.

## Stack

Vite + vanilla TypeScript + `@supabase/supabase-js`. One `index.html`, one `main.ts`. Its own Vercel project with root directory `recorder/`.

Jordan runs `supabase login` and `vercel login` himself. After that, use the Supabase and Vercel CLIs to do the rest end to end: create the bucket, apply the policy, set env vars, deploy.

## The page

- **Speaker** comes from the URL: `?s=en_jn`, `?s=es_cu` or `?s=es_mx`. Without one, show three buttons.
- **Lines** come from `bench/references.json` (repo root, the single source of truth). A `predev`/`prebuild` script copies it into `recorder/public/`. If the Vercel build can't see files outside `recorder/`, commit the copy and note it in the README.
- **Language:** `es_*` speakers see the Spanish `text`, `en_jn` sees the English.
- **Per line:** the line number and text in large type; Record / Stop; play back; Re-record; Upload. After an upload, mark the line ✓ and advance.
- **Progress:** a list of all 21 lines with ✓ marks, "7 of 21 uploaded." Remember progress in `localStorage` (wrapped in try/catch) so a friend can stop and come back.
- **Bonus round** after line 21: "Optional: lines 1–5 again with a TV or street noise in the background," saved with a `_noise` suffix.
- **Top of page, one line:** "Your recordings are used only to score speech-recognition tools. They won't be published."

## Recording

- `getUserMedia({ audio: { echoCancellation: false, noiseSuppression: false, autoGainControl: true } })` so engines get the raw voice.
- `MediaRecorder` with the first supported type from `audio/webm;codecs=opus` (Chrome, Android) and `audio/mp4` (iPhone Safari). Take the file extension from the type.
- **Must work in iPhone Safari and Android Chrome**, since the friends use phones. Test both before sending the link.

## Storage

- **Bucket** `bench-audio`, **private**, 10 MB per-file limit, audio MIME types only. Create it with a SQL migration in `recorder/supabase/migrations/` so it's reproducible.
- **Upload-only access:** one RLS policy on `storage.objects` letting `anon` INSERT where `bucket_id = 'bench-audio'`. Friends can upload; nobody can list or download with the public key. That keeps Jordan's promise that the audio won't be published.
- **No overwrites:** the path is `{speaker}/{speaker}_{NN}[_noise]__{unixMs}.{ext}`. A re-record uploads a new file, and the bench uses the newest file per line. That way anon never needs SELECT or UPDATE.
- **Keys:** `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in Vercel env. The anon key is safe in the browser because of the insert-only policy. The service-role key never enters this project.

## Getting the clips out

`bench/pull-audio.ts`: run locally with the service-role key from a gitignored `.env`. It downloads the newest file per `{speaker}_{NN}[_noise]` into the repo-root `audio/` as `{speaker}_{NN}[_noise].{ext}`.

## Done when

1. On an iPhone in Safari, `?s=es_cu`: record line 1, upload, and see the object in the bucket.
2. The same on Chrome.
3. With only the anon key, listing the bucket returns nothing and downloading fails.
4. `pull-audio` puts the clip in `audio/`.
5. Jordan has the three links (`?s=en_jn`, `?s=es_cu`, `?s=es_mx`).

