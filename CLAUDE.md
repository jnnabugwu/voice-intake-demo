# voice-intake-demo

Two separate projects in one repo, sharing one speech bench. Each project has its own CLAUDE.md, dependencies and Vercel project. Read the one for the folder you're working in.

| Folder | Project | Read |
|---|---|---|
| `recorder/` | Throwaway page where friends record the bench lines and upload them to Supabase Storage | `recorder/CLAUDE.md` |
| `intake/` | The voice intake demo: Flutter web app (`intake/app`) + Claude proxy (`intake/proxy`) | `intake/CLAUDE.md`, then `ARCHITECTURE.md` |
| `bench/` | Shared: `references.json` (the scoring key both projects read), the scorer, `pull-audio`, results | `intake/CLAUDE.md` § Bench |
| `audio/` | Clips pulled from the bucket. Gitignored; friends' voices never get committed | |

## Order tonight

1. **Recorder first** (under an hour), so the friends can record while the rest gets built. Done when Jordan has the three speaker links.
2. **Intake blocks 1–5.**
3. **Bench** (intake block 6) once the clips are in.

## Shared rules

- `bench/references.json` is the single source of truth for line text, key terms and file stems. Projects read it (or a build-time copy); nothing edits a copy.
- Projects never import from each other. The only shared thing is `bench/`.
- Secrets live in gitignored `.env` files and Vercel env vars. The service-role key and the Anthropic and AssemblyAI keys stay server-side or local.
- Commit after each completed block, with a message naming the project and block, e.g. `recorder: upload works on iPhone Safari`.
