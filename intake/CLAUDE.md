# Intake: voice intake demo

A Flutter web prototype of voice-first care intake. A worker speaks (English or Spanish), sees their words live, and gets short streamed replies. A physician reviews a structured summary and approves before the worker sees any next step. A speech **bench** scores engines on the same care-request script.

Two readers judge this repo: a non-technical founder who opens a link in Chrome, and a physician-engineer who clones it and reads the code and bench results. Build for both: the link works on the first try, and the code reads cleanly.

**Deadline: ship tonight.** Work the blocks below in order. When a block's check passes, commit and move on. Polish only after block 5 is done.

## Guardrails (product rules, enforced in code and prompt)

- **The assistant gathers, the physician decides.** Replies acknowledge, ask one follow-up question at a time (how long, how bad, what else), and stop. Diagnosis, medication advice and doses belong to the physician tab.
- **Red flags stop the chat.** Chest pain, trouble breathing, stroke signs, self-harm or suicide language (English or Spanish) → a full-screen card with 911 (emergencies) and 988 (crisis), in the conversation's language. Check with a keyword pass on the transcript *before* calling the model, and again on the model's summary flag.
- **Approval gate.** The worker's "next step" stays locked until the physician taps Approve or edits it.
- **Demo data only.** The UI says "Demo, don't enter real health information." Bench audio lives in the repo-root `audio/` and stays out of git.
- **Keys live in the proxy.** The Flutter app knows a proxy URL, never an API key.
- **Chrome.** The page shows "Best in Chrome on a laptop," and the mic button explains itself when `SpeechRecognition` is missing (Firefox, Brave, some in-app browsers).

## Layout

```
intake/app/     Flutter web app (also builds for iOS/Android; web is the target tonight)
intake/proxy/   TypeScript serverless functions, its own Vercel project (root: intake/proxy)
bench/          repo root: references.json (scoring key), scorer, results.md
audio/          repo root, gitignored: clips pulled from the recorder's bucket
```

## Build blocks

Each block ends on its check.

1. **Mic.** Flutter web app with `speech_to_text`: mic button, live partial words, EN/ES toggle (`en-US`, `es-US`; fall back to whatever `locales()` offers).
   *Check:* `flutter run -d chrome`; speak both languages; partial words appear while speaking.
2. **Chat.** Chat UI with streamed assistant bubbles. **Demo mode** is the default when no `PROXY_URL` is set: scripted replies driven by keywords, so a clean clone runs with zero keys.
   *Check:* fresh clone + `flutter run -d chrome` runs a full intake with no keys.
3. **Proxy.** Vercel functions:
   - `POST /api/chat` streams the reply over SSE.
   - `POST /api/summary` returns the structured summary (schema below).
   - Daily spend cap, per-IP rate limit, CORS allowlist for the deployed origin and localhost.
   *Check:* the app with `--dart-define=PROXY_URL=...` streams real replies; over the cap returns 429 and the app shows a friendly message.
4. **Physician tab.** Summary card, full transcript, Approve / Edit; plus the red-flag card.
   *Check:* the chest-pain line (references.json line 20) triggers the card in both languages; Approve unlocks the worker's next step.
5. **Ship.** `flutter build web`, deploy app and proxy, record the 60–90 s video.
   *Check:* the link works in a Chrome profile that has never visited it.
6. **Bench.** See below.
   *Check:* `bench/results.md` has the table, every engine and speaker that ran, the weak results included.

## Claude API

Load the `claude-api` skill before writing proxy code; take SDK names and parameters from it, not from memory. Use the official `@anthropic-ai/sdk`.

- Model from env `CLAUDE_MODEL`, default `claude-opus-5-5`. Effort `low` for chat turns (latency matters); default effort for the summary.
- Stream chat replies. Use structured outputs for the summary.
- Enable the server-side refusal fallback the skill describes, and handle `stop_reason: "refusal"` with a calm "Let me connect you with a clinician" message.
- The system prompt lives in `proxy/prompts/`, one file per prompt, so a reviewer can read it.

Summary schema: `chief_complaint`, `duration`, `severity` (1–10 or null), `symptoms[]`, `medications[]`, `allergies[]`, `red_flags[]`, `language`, `open_questions[]`, `transcript`. Null when the worker didn't say it; never inferred.

## Bench

`bench/references.json` is the source of truth: 21 lines × 3 speakers, key medical terms with accepted variants (`|`-separated), and the expected red-flag lines. Its `scoring` field defines normalization; implement it once in `bench/` and reuse it everywhere.

- **Metrics:** WER (after normalization), **medical-term miss rate** (key term counts as found if any variant appears), and latency.
- **Chrome Web Speech (live only):** a Bench tab in the app shows line *n*, Jordan reads it, the app records the transcript plus timestamps (mic on, first partial, final) and exports JSON. Score English this way.
- **Cloud engine on files:** start with AssemblyAI (`ASSEMBLYAI_API_KEY`; self-serve BAA, Spanish support). Run all three speakers from `audio/`. Add a second engine only if block 6 finishes early.
- **Audio format:** clips come from the recorder as `.webm` (Chrome) or `.mp4` (iPhone Safari), not the `.m4a` names in references.json. Match files by the `{speaker}_{NN}` stem and accept any audio extension.
- **Honest reporting:** live latency and batch processing time are different measures, so label them separately. Note the sample (21 lines, one speaker per accent, read speech). Publish scores, never the friends' audio.
- `npm run bench` (in `bench/`) reads `audio/`, calls engines, merges the Chrome JSON exports, writes `bench/results.md`.

## README (written in block 5)

Lead with what it does for a worker, then a "Use Chrome" line, the live link, the video, `flutter run -d chrome` (demo mode), the env vars for live mode, and the bench table. Include the privacy note: Chrome's default recognition sends audio to Google, so the demo isn't for real patient data; production would use a BAA-covered engine or on-device recognition.

## Working notes

- Commit after each block with a message naming the block.
- Run `flutter analyze` and `dart format` before each commit, and `tsc --noEmit` in `intake/proxy/`.
- The private plan and research (with sources) live outside this repo: `/Users/jordannnabugwu/Development/interview-coach-skill/interviews/atmos_clinic/voice_demo_plan.md`. Read it for context; keep its contents out of this public repo.
