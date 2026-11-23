# Voice intake

A worker who needs care opens a link, taps the mic and says what's wrong, in English or Spanish. Their words appear as they speak. A short assistant reply acknowledges what they said and asks one follow-up at a time: how long, how bad, what else, medications and allergies. It never diagnoses or advises. When they tap Finish, a physician gets a structured summary and the full transcript, writes the next step and approves it. Only then does the worker see it. If the worker mentions chest pain, trouble breathing, stroke signs, or self-harm or suicide, the chat stops at once and a full-screen card offers 911 or 988, in their language.

**Use Chrome on a laptop.** Firefox, Brave and some in-app browsers (Gmail, LinkedIn) don't support browser speech recognition. The page says so and offers typing instead.

- **Live demo:** https://voice-intake-chi.vercel.app (live mode: Claude through the proxy at `voice-intake-proxy.vercel.app`)
- **Video (60–90 s):** _coming with block 5 (#13)_

> Demo data only. Chrome's default speech recognition sends audio to Google, so this demo isn't for real patient information. A production build would use a speech engine covered by a BAA, or on-device recognition. See [the bench](#speech-bench) for how engines compare.

## Run it

Demo mode needs no keys. Replies and the summary come from keyword scripts.

```sh
cd intake/app
flutter run -d chrome
```

Flutter 3.47 or later. "Viewing as: Worker | Physician" at the top switches sides; an approval on one side shows up on the other at once.

### Live mode (Claude)

The proxy in `intake/proxy` holds the Claude key and streams replies. The app only knows its URL.

Before using a real key, set a monthly **spend limit** and a usage alert on its Claude Console workspace. That is the only hard ceiling; the proxy's own limits are best effort.

```sh
# Terminal 1: the proxy (stays running)
cd intake/proxy
npm ci
cp .env.example .env        # ANTHROPIC_API_KEY=...
npm i -g vercel             # once: the Vercel CLI
npm run dev                 # vercel dev on :3000

# Terminal 2: the app
cd intake/app
flutter run -d chrome --dart-define=PROXY_URL=http://localhost:3000
```

| Variable (proxy) | Default | |
|---|---|---|
| `ANTHROPIC_API_KEY` | | Required. Keep it in Vercel env vars or `.env`, never in the app |
| `CLAUDE_MODEL` | `claude-opus-5-5` | |
| `DAILY_SPEND_CAP_USD` | `5` | Per server instance, best effort. Vercel can run several instances, so the hard ceiling is the Console workspace limit |
| `RATE_LIMIT_PER_MIN` | `20` | Per IP, per server instance, best effort |
| `ALLOWED_ORIGINS` | | The deployed app's origin(s); localhost is always allowed |

### Deploy

The app and the proxy are two separate Vercel projects. Deploy each one from its own folder, and never from the repo root, which is linked to the recorder.

```sh
# 1. Proxy (Vercel project voice-intake-proxy)
cd intake/proxy
vercel env add ANTHROPIC_API_KEY production
vercel deploy --prod

# 2. App: a static build that has the proxy URL compiled in (Vercel project voice-intake)
cd ../app
flutter build web --release --dart-define=PROXY_URL=https://voice-intake-proxy.vercel.app
vercel deploy build/web --prod

# 3. Allow the app's origin, then redeploy the proxy so the setting takes effect
cd ../proxy
vercel env add ALLOWED_ORIGINS production    # https://voice-intake-chi.vercel.app
vercel deploy --prod
```

Git auto-deploy is off on purpose. Vercel's builders have no Flutter, and a proxy build from the repo root would replace the proxy with the wrong files. Redeploy by hand after a change.

## How it's built

- **One Flutter app, two sides.** The worker side (`speech`, `conversation`, `next_step`) and the physician side (`case_review`) never import each other. They exchange only the case, through `CaseRepository`. A boundary script enforces this. [ARCHITECTURE.md](ARCHITECTURE.md) covers the folders, Blocs, typed routes, the `shadcn_ui` design system, and the safety path.
- **Safety runs before the model.** A keyword pass in English and Spanish runs on every message before any model call, in the app and again in the proxy, and the summary's red flags are checked too. Both detectors are tested against every line of the bench script.
- **The assistant gathers, the physician decides.** The system prompts are in [`intake/proxy/prompts/`](intake/proxy/prompts/). The summary uses structured outputs, and a field is null when the worker didn't say it.
- **The proxy** streams over SSE and has a CORS allowlist, a per-IP rate limit, a daily spend cap, and Claude's server-side refusal fallback. It logs metadata only, never transcripts.

```sh
(cd intake/app && flutter analyze && flutter test && tool/check_boundaries.sh)
(cd intake/proxy && npm ci && npx tsc --noEmit && npx vitest run)
(cd bench && npm ci && npm test)
```

## Speech bench

Accuracy comes from the recognition engine, not the UI framework: Flutter, native and React Native all wrap the same system recognizers. So the bench scores engines on a 21-line care-request script ([`bench/references.json`](bench/references.json)), read by three speakers: native English, native Spanish, and Spanish as a second language. It measures word error rate, the **medical-term miss rate** (drug names, doses, numbers, symptoms), and latency.

Results: [`bench/results.md`](bench/results.md). Live latency and batch processing time are reported separately. The sample is small and read aloud, so treat it as directional. Scores are published; the recordings are not.

| Engine | Where it runs | How it's scored |
|---|---|---|
| Chrome Web Speech | Google's servers, through the browser | Live, read aloud on the app's `/bench` page |
| Apple SpeechAnalyzer | On the device (Apple's newest engine, iOS 26 and macOS 26) | On the recorded clips, through a Swift CLI on macOS |
| Apple SFSpeechRecognizer | Apple's older engine: by default Apple picks the device or its servers; also scored on-device only | On the recorded clips, through a small Swift app on macOS |
| Whisper large-v3-turbo | Self-hosted with whisper.cpp | On the recorded clips |
| AssemblyAI | Cloud, with a BAA available | On the recorded clips |

SpeechAnalyzer isn't the engine today's iPhone apps get. Flutter's `speech_to_text` (the package this app uses) and React Native's `expo-speech-recognition` both call Apple's older `SFSpeechRecognizer`. That engine can send audio to Apple's servers unless the app asks for on-device recognition. Reaching SpeechAnalyzer takes a small native plugin, in either framework. The bench scores `SFSpeechRecognizer` in both modes: the packages' default, and on-device only (`onDevice: true`).

```sh
cd bench && npm ci
npm run pull-audio          # clips from the recorder's bucket into audio/ (needs bench/.env)
brew install whisper-cpp ffmpeg
curl -L --create-dirs -o ~/.cache/whisper-models/ggml-large-v3-turbo.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
npm run bench               # writes bench/results.md; engines that can't run here are skipped with a note
```

Apple's engines need macOS 26 or later with Xcode. `SFSpeechRecognizer` runs as a small app (`bench/.cache/bin/SFSpeech.app`), because macOS checks the launching app for a speech-recognition usage description. If macOS asks, allow "Speech bench" to use speech recognition. AssemblyAI needs `ASSEMBLYAI_API_KEY` in `bench/.env`.
