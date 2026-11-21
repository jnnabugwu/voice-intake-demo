# Intake proxy

Vercel functions that hold the Claude key: `POST /api/chat` (SSE) and `POST /api/summary` (JSON). Wire contract and guards: `../../ARCHITECTURE.md` § Proxy.

```sh
npm ci
npm test            # vitest
npm run typecheck   # tsc --noEmit
cp .env.example .env   # add ANTHROPIC_API_KEY
npm run dev         # needs the Vercel CLI: npm i -g vercel
```
