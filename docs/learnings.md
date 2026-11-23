# Voice intake demo: build learnings

_Updated at the end of each session. Newest session first._

## 2026-11-23: AssemblyAI joins the bench

### Where it ended

- `bench/results.md` now scores all three file engines on `en_jn` and `es_mx`: AssemblyAI (cloud), Whisper large-v3-turbo (self-hosted) and Apple SpeechAnalyzer (on-device). Apple's and Whisper's numbers came out exactly as in the 11-22 run, so the local engines are reproducible.
- `es_cu` has no clips: the bucket holds only `en_jn/` and `es_mx/`. Chrome Web Speech still needs a live read on `/bench`.

### What the numbers say

| | English WER / term misses | Spanish WER / term misses |
|---|---|---|
| AssemblyAI | 10.3% / 6.7% | 3.7% / 4.8% |
| Whisper | 9.3% / 10.0% | 9.8% / 20.6% |
| Apple | 14.6% / 13.3% | 11.5% / 28.6% |

- **Word error rate hides the gap that matters.** In English, Whisper's WER beats AssemblyAI's, but it misses more medical terms. In Spanish, AssemblyAI misses 3 terms where Whisper misses 15 and Apple 21.
- **Drug names are hard in English for every engine.** All three missed lisinopril and amoxicillin. All three also lost "blood sugar" on line 14: AssemblyAI wrote "blood pressure was 210", a reading attached to the wrong vital sign.
- **Every Spanish miss changes the meaning.** "ronchas" (hives) became "manchas" (spots), "urgencias" became "herencias" (inheritance), and "al tragar" became "el tráqueo".
- **Quiet audio was fine.** The `es_mx` clips average about -56 dB, roughly 25 dB below typical phone speech. Even so, they gave the best scores in the table.

### What went wrong, and the fix

| Problem | Root cause | Fix / rule |
|---|---|---|
| The bench ran and scored nothing | The key was saved as `ASSEMBLY_API_KEY`; the bench reads `ASSEMBLYAI_API_KEY` and only leaves a note in `results.md` | Check the key name with `grep -o '^[A-Z_]*=' bench/.env` before running. The values never get printed |
| A rename of the key line in `.env` didn't stick | The file was open in the editor, which saved its older copy over the shell edit | Jordan edits `.env` files by hand. To run once without editing the file, `set -a; . ./.env` and pass the key under the right name for that one command |
| `git pull` refused to run | A local, untracked `results.md` clashed with the one another session had committed | When another session is working on the bench, pull before running it. Set a local file aside instead of deleting it |

### Red-flag paraphrases the keywords miss

A quick run through the proxy's detector missed every one of these: "an elephant is sitting on my chest", "I can't catch my breath", "half my face isn't working", "everyone would be better off without me", "me aprieta el pecho", "siento que me ahogo". It also escalated "I had a heat stroke last summer". Keywords hold up on the script they were tested against, not on how people actually describe an emergency. Next step: a model-based check running in shadow mode next to the keywords, with a clinician reviewing every case where the two disagree.

## 2026-11-21: shipping it (block 5)

### Where it ended

- Live: the app at https://voice-intake-chi.vercel.app and the proxy at https://voice-intake-proxy.vercel.app, two separate Vercel projects in `jnnabugwus-projects`. An end-to-end check in a fresh Chrome profile passed: Claude's replies stream, the physician sees the summary, approval unlocks the next step, and a red flag shows the card and the escalation.
- #32 made demo mode read answers the way speech recognition writes them. "seven seven just a seven" and "six out of ten" become a severity; symptoms are added; the worker's name stays out of the complaint. #33 linked the live demo in the README and documented the deploy.
- Left for block 5: the 60–90 s video. Block 6 still needs clips and an AssemblyAI key.

### What went wrong, and the fix

| Problem | Root cause | Fix / rule |
|---|---|---|
| The first "proxy" deploy redeployed the recorder | `vercel link` was run from the repo root and the recorder project was picked, so `intake/proxy` got the same link | One Vercel project per folder. Run `vercel` only from `intake/proxy` or `intake/app`, and check `.vercel/project.json` before `--prod` |
| The Anthropic key sat in `recorder/.env` | It was pasted into the first `.env` that was open | Each key goes in the `.env` of the project that uses it. Moved to `intake/proxy/.env`; the recorder never needed it |
| Commands ran that nobody meant to run | Deploy output pasted back into zsh ran its "Next steps" lines (`vercel git connect`, `vercel redeploy`) | Never paste CLI output into a shell. Here `git connect` linked GitHub to the proxy with Root Directory `.`, so the next push to main would have deployed the repo root over it. Disconnected |
| The live app returned 404 after a redeploy | `vercel deploy --prod` inside `intake/app` uploaded the Flutter source, not the build | The app is static: always `vercel deploy build/web --prod`. Git auto-deploy stays off because Vercel's builders have no Flutter |
| The app URL got a random `-chi` suffix | `voice-intake.vercel.app` belongs to someone else | Use the alias Vercel prints. The README and `ALLOWED_ORIGINS` use the `-chi` address |
| `ALLOWED_ORIGINS` was set but the app still got 403 | Env vars only reach new deployments, and the redeploy that followed went to the app, not the proxy | After changing proxy env vars, redeploy from `intake/proxy`. Check with an `Origin`-header curl and an empty body (400 = allowed, 403 = blocked), which never calls Claude |
| The agent created an empty Gmail draft | It called a mail tool with no parameters by mistake, and its delete was blocked | Nothing was sent; the draft is deleted by hand. Don't call tools the task doesn't need |

### Rules that came out of it

- Probe a deployed proxy without spending money: an empty body from an allowed origin returns 400 before any model call.
- Set the spend limit in the Console workspace before the key reaches Vercel. The proxy's caps are per instance.
- A production deploy is the human's command. The agent prepares env vars and verifies the result.

## 2026-11-20 (evening): the cloud hand-off, cubic's review rounds, blocks 3–6

### Where it ended

| Issue | PR | State |
|---|---|---|
| #9 proxy | #20 | merged after 6 cubic rounds |
| #11 physician side, approval gate | #21 | merged |
| #12 red flags | #22 | merged |
| #10 live mode in the app | #25 | merged |
| #14 bench scorer | #26 | merged |
| #15 `/bench` page | #29 | merged |
| #16 AssemblyAI + `results.md` | #27 | merged |
| #13 ship | #28 | README and accessibility tests in review; deploy and the video are Jordan's |

Left for Jordan: #4 (Claude key, Console spend limit: the only hard cost ceiling), #5 (clips, AssemblyAI key), reading `/bench`, deploying, the fresh-profile check, the video.

### What happened

- **The "cloud" agent ran on the laptop.** An agent launched with remote isolation came back with Flutter at `~/Development/flutter` and `gh` on the Mac keychain: it was a local subagent. It also ran in a sandbox that refused compound shell commands, so in 40 minutes it fixed part of one PR and pushed nothing. **Rule:** before telling Jordan it's safe to leave, confirm the agent is really remote (ask it for `hostname` and `pwd`), or start a cloud session from claude.ai/code instead.
- **Another session shared the main checkout.** It switched branches (`remove-circleci`, then `docs-learnings`) while this session was working. **Rule:** when other sessions are open in the repo, do all work in separate `git worktree`s and never touch the main checkout.
- **cubic found something on almost every pass.** Rounds 2–4 on the red-flag work surfaced real safety gaps:
  - denials ("no chest pain") escalated, then over-broad denial handling suppressed real ones ("no fever **and** can't breathe");
  - "sin embargo" read as a denial;
  - "I hurt myself lifting boxes" read as a crisis;
  - overdose wording was missing;
  - "dolor de pecho", "facial droop", "my arm is numb" and unaccented Spanish were missed;
  - an emergency could get a 429 from the rate limit or the spend cap, or a replayed reply.

  Each fix went into **both** detectors (app and proxy) with a test.
- **A product call surfaced mid-review:** whether an approved next step replaces the 911/988 card. Jordan chose: the card holds until a clinician approves, then the approved step shows, with the help lines still offered.

### Rules that came out of it

| Problem | Rule |
|---|---|
| Two red-flag detectors (Dart, TypeScript) drift | Change both in the same session, mirror each test, and run both over every `bench/references.json` line in both languages |
| Negation is hard | A denial counts only within the 3 words before a match and in the same clause; "and", "but", "y", "pero", "sin embargo" and a line break end a clause |
| Safety paths behind cost controls | Red-flag checks run before the rate limit, the replay cache and the spend cap: they cost nothing, so an emergency never gets a 429 |
| `rootBundle` in widget tests | Its cache outlives each test's zone, so a second test's asset load never completes. Read fixtures with `File` in tests and keep a separate drift test for the asset copy |
| A double tap approved twice | `droppable()` can't drop an event that arrives after a fast handler finishes. Make the action idempotent instead |
| The README described features still in open PRs | Stack docs PRs on top of the features they describe so they merge last |
| The GitHub API rate limit | The limit is shared across sessions. Batch reply/resolve calls and wait with one background loop, not repeated polls |

## 2026-11-20: issues, blocks 1–4, the proxy

### Where it stands

| Issue | PR | State |
|---|---|---|
| #6 Intake 1: app skeleton | #17 | merged |
| #7 Intake 2: mic | #18 | merged |
| #8 Intake 3: chat + demo mode | #19 | merged |
| #9 Intake 4: proxy | #20 | open, cubic findings fixed twice |
| #11 Intake 6: physician side, approval gate | #21 | open, stacked → `main` |
| #12 Intake 7: red flags | #22 | open, stacked on #21 |
| #10 Intake 5: live mode in the app | | not started; needs #4 (Claude key) |
| #13 Intake 8: ship | | not started |
| #14–#16 Bench | | not started; needs #5 (clips, AssemblyAI key) |

Tracking issue: #3. Checkpoints that need Jordan: #4, #5, and the mic, fresh-profile and video steps inside #7, #13 and #15.

### What worked

- **Issues shaped like Steady's.** A tracking issue, numbered block issues that each say "Part of #3", checkbox task lists, and `checkpoint` issues for anything an agent can't do (accounts, a microphone, a camera). Each PR closes exactly one issue.
- **cubic as the reviewer.** It caught real bugs on every PR. Examples: a session replacing another without stopping the old recognizer; a retry transformer (`restartable`) that could strand the conversation in `streaming`; the demo summary recording "no fever" as a symptom; red-flag patterns missing "dolor de pecho" and "shortness of breath"; the spend cap undercounting a reply cut short mid-stream. About 1 in 10 findings were by design; those got a reply and a resolved thread rather than a change.
- **Bench lines as the safety test table.** Running the red-flag detector (app and proxy) over all 21 lines of `bench/references.json` in both languages found that line 21 (new confusion in an older adult with diabetes, asking about the ER) is a red flag that chest/breathing/stroke patterns miss, and that "urgencias" means urgent-care billing in line 16, not an emergency.
- **Fakes at every seam.** `FakeSpeechEngine`, `FakeChatRepository` and `InMemoryCaseRepository` made the end-to-end approval-gate widget test (worker → Finish → physician edits → still locked → Approve → unlocked) possible with no browser and no keys.

### What went wrong, and the fix

| Problem | Root cause | Fix / rule |
|---|---|---|
| Merging #17 with `--delete-branch` **closed** stacked PR #18 instead of retargeting it | GitHub closes a PR whose base branch is deleted | Retarget the child PR to `main` **before** merging its base. To recover: push the base branch back, reopen, retarget, then delete |
| cubic posted "Automatic AI review not started after branch rewrite" | Rebasing stacked branches force-pushes; cubic skips rewritten history | Never rebase a branch with an open PR. Merge the base into the child instead. Comment `@cubic-dev-ai review` to request a review by hand |
| cubic doesn't re-review fix commits on its own | It reviews on open and on request | After pushing fixes, comment `@cubic-dev-ai review` before merging |
| CircleCI never ran on any PR | The CircleCI project isn't connected to the repo | Jordan: connect the project in CircleCI. Until then, run the same steps locally before every push |
| `npm install -D vitest@5.1.1` failed with `Cannot read properties of null (reading 'edgesOut')` | npm 10's resolver chokes on vitest 5's optional browser peer | Pin vitest 4 |
| `pumpAndSettle` timed out in widget tests | The mic's pulse animation repeats while listening | `pump(duration)` while the mic is live |
| A demo reply was still streaming when the test asserted | `pumpAndSettle` doesn't advance the fake clock past `Future.delayed` word gaps | `pump(const Duration(seconds: 5))`, then settle |
| Semantics finders found nothing after the chat grew | `ListView` builds lazily; the mic scrolled out of the 800×600 test window | A tall test window in `pumpApp` |
| A Python string replace mangled `.circleci/config.yml` | `- intake-app` also matched the cache key `- intake-app-pub-…` | Diff the config against `main` after any scripted edit |

### Speech on the web (speech_to_text 7.5.0)

- The web plugin only reports **partial** results. After `stop()`, the plugin's own `finalTimeout` (2 s by default; the engine sets 700 ms) turns the last partial into a final result, delivered through the **result callback** (`finalResult: true`). Only then does it report the `done` status, which ends the session rather than carrying text.
- `done` reaches the status listener only after a final result was delivered. When Chrome stops by itself after partials, `done` is held back, so the engine needs a fallback timer after `notListening`.
- `initialize()` registers its callbacks only on the first call. Later sessions set `errorListener` / `statusListener` directly.
- On web, `partialResults: true` also sets `continuous`, so Chrome keeps listening across pauses until stop or a long silence.

### Claude API (from the `claude-api` skill, not memory)

- `@anthropic-ai/sdk` 1.12.0. Server-side refusal fallback: `betas: ["server-side-fallback-2026-07-01"], fallbacks: "default"` on `client.beta.messages.*`.
- Opus 5.5's default effort is `medium`; chat sets `low` explicitly.
- Structured outputs drop numeric bounds (`minimum`/`maximum`). `betaZodOutputFormat` strips them and validates client-side. The summary route calls `create` and validates itself, so a billed response that fails validation still counts toward the cap.
- `usage.iterations` lists every attempt, refused ones included. Sum it for the spend cap.
