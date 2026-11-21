# Voice intake

A worker who needs care opens a link, taps the mic and says what's wrong, in English or Spanish. Their words appear as they speak. A short assistant reply acknowledges what they said and asks one follow-up at a time: how long, how bad, what else, medications and allergies. It never diagnoses or advises. When they tap Finish, a physician gets a structured summary and the full transcript, writes the next step and approves it. Only then does the worker see it. If the worker mentions chest pain, trouble breathing, stroke signs, or self-harm or suicide, the chat stops at once and a full-screen card offers 911 or 988, in their language.

**Use Chrome on a laptop.** Firefox, Brave and some in-app browsers (Gmail, LinkedIn) don't support browser speech recognition. The page says so and offers typing instead.

- **Live demo:** _link coming with block 5 (#13)_
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
npm run dev                 # vercel dev on :3000, needs the Vercel CLI

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

Results: [`bench/results.md`](bench/results.md) _(table coming with block 6)_. Chrome Web Speech is scored live on `/bench`; file engines (AssemblyAI first) run with `npm run bench` in `bench/`. Live latency and batch processing time are reported separately. The sample is small and read aloud, so treat it as directional. Scores are published; the recordings are not.
