# Recorder

A one-page app where friends read the 21 bench lines aloud and upload each clip to a private Supabase bucket. It's a weekend throwaway.

**Live:** https://voice-intake-recorder.vercel.app

- English: https://voice-intake-recorder.vercel.app/?s=en_jn
- Cuban Spanish: https://voice-intake-recorder.vercel.app/?s=es_cu
- Mexico City Spanish: https://voice-intake-recorder.vercel.app/?s=es_mx

## Run locally

```sh
cp .env.example .env   # fill in VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
npm install
npm run dev            # serves on your LAN too (--host), but phones need HTTPS for the mic
```

## The committed `public/references.json`

`bench/references.json` is the source of truth. `predev` and `prebuild` copy it into `public/`. The Vercel project's root is `recorder/`, so the Vercel build can't see `../bench`. That's why the copy is committed, and the copy script keeps it when `../bench` isn't there. Edit the file in `bench/`, run `npm run build` here, and commit both.

## Supabase

- Project `voice-intake-demo` (ref `ufiokbmbsbuxmjzvomgw`). The bucket and policy come from [supabase/migrations/](supabase/migrations/) and are applied with `supabase db push`.
- `bench-audio` is private, has a 10 MB limit and takes `audio/*` only. The only policy lets `anon` INSERT under `en_jn/`, `es_cu/` or `es_mx/`. The public key can't list, download, sign or overwrite.
- Paths look like `{speaker}/{speaker}_{NN}[_noise]__{unixMs}.{ext}`. A re-record adds a new file, and `bench/pull-audio.ts` keeps the newest file per line.

## Deploy

Vercel project `voice-intake-recorder` (jnnabugwu's projects). Run `vercel deploy --prod` from this folder. Env: `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (production, type config, because the anon key is public by design).

## Teardown

When the bench is done, run `vercel remove voice-intake-recorder`, delete the clips from the bucket, and keep the bucket private.
