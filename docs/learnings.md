# Voice intake demo: build learnings

_Updated at the end of each session. Newest session first._

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

- The web plugin only reports **partial** results. The final arrives through the `done` status, after the plugin's own `finalTimeout` (2 s by default) promotes the last partial. The engine sets it to 700 ms.
- `done` reaches the status listener only after a final result was delivered. When Chrome stops by itself after partials, `done` is held back, so the engine needs a fallback timer after `notListening`.
- `initialize()` registers its callbacks only on the first call. Later sessions set `errorListener` / `statusListener` directly.
- On web, `partialResults: true` also sets `continuous`, so Chrome keeps listening across pauses until stop or a long silence.

### Claude API (from the `claude-api` skill, not memory)

- `@anthropic-ai/sdk` 1.12.0. Server-side refusal fallback: `betas: ["server-side-fallback-2026-07-01"], fallbacks: "default"` on `client.beta.messages.*`.
- Opus 5.5's default effort is `medium`; chat sets `low` explicitly.
- Structured outputs drop numeric bounds (`minimum`/`maximum`). `betaZodOutputFormat` strips them and validates client-side. The summary route calls `create` and validates itself, so a billed response that fails validation still counts toward the cap.
- `usage.iterations` lists every attempt, refused ones included. Sum it for the spend cap.
