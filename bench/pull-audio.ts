// Downloads the newest clip per {speaker}_{NN}[_noise] from the private
// bench-audio bucket into repo-root audio/ as {speaker}_{NN}[_noise].{ext}.
// Needs SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in bench/.env (gitignored).
import { StorageClient } from "@supabase/storage-js";
import { mkdirSync, readdirSync, readFileSync, unlinkSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const here = (p: string) => fileURLToPath(new URL(p, import.meta.url));
try {
  process.loadEnvFile(here(".env"));
} catch {
  /* fall back to the shell environment */
}
const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in bench/.env");
  process.exit(1);
}

const BUCKET = "bench-audio";
const NAME = /^(?<stem>[a-z]{2}_[a-z]{2}_\d{2}(?:_noise)?)__(?<ms>\d+)\.(?<ext>[a-z0-9]+)$/;
const outDir = here("../audio/");
const refs = JSON.parse(readFileSync(here("references.json"), "utf8")) as { speakers: { id: string }[] };
// Storage-only client: supabase-js's realtime client needs a WebSocket Node 20 lacks.
const storage = new StorageClient(`${SUPABASE_URL}/storage/v1`, {
  apikey: SUPABASE_SERVICE_ROLE_KEY,
  Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
});

mkdirSync(outDir, { recursive: true });
let pulled = 0;

const PAGE = 1000;

/** Every object name in a speaker's folder; Storage lists at most PAGE per call. */
async function listAll(folder: string): Promise<string[]> {
  const names: string[] = [];
  for (let offset = 0; ; offset += PAGE) {
    const { data, error } = await storage.from(BUCKET).list(folder, { limit: PAGE, offset });
    if (error) throw error;
    names.push(...(data ?? []).map((o) => o.name));
    if (!data || data.length < PAGE) return names;
  }
}

for (const { id } of refs.speakers) {
  const newest = new Map<string, { file: string; ms: number; ext: string }>();
  for (const name of await listAll(id)) {
    const m = NAME.exec(name)?.groups;
    if (!m) continue;
    // Storage only checks the folder, so anyone with the anon key could drop
    // es_cu/en_jn_01__….webm. Accept only files named for this folder's speaker.
    if (!m.stem.startsWith(`${id}_`)) {
      console.warn(`skipped ${id}/${name}: name doesn't match its speaker folder`);
      continue;
    }
    const ms = Number(m.ms);
    if ((newest.get(m.stem)?.ms ?? -1) < ms) newest.set(m.stem, { file: name, ms, ext: m.ext });
  }

  for (const [stem, { file, ext }] of [...newest].sort()) {
    const { data: blob, error: dlErr } = await storage.from(BUCKET).download(`${id}/${file}`);
    if (dlErr) throw dlErr;
    // Drop an older pull of the same line saved under a different extension.
    for (const old of readdirSync(outDir)) {
      if (old.startsWith(`${stem}.`) && old !== `${stem}.${ext}`) unlinkSync(outDir + old);
    }
    writeFileSync(`${outDir}${stem}.${ext}`, Buffer.from(await blob.arrayBuffer()));
    console.log(`${stem}.${ext}  <-  ${id}/${file}`);
    pulled++;
  }
}
console.log(`${pulled} clip(s) in audio/`);
