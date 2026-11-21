import { readdirSync } from "node:fs";
import { join } from "node:path";

const AUDIO = /\.(webm|mp4|m4a|wav|mp3|ogg|aac)$/i;
const STEM = /^[a-z]{2}_[a-z]{2}_\d{2}(_noise)?$/;

/**
 * Clips in [dir] by stem `{speaker}_{NN}` (or `{speaker}_{NN}_noise`), any
 * audio extension. The recorder writes .webm (Chrome) or .mp4 (iPhone), not
 * the .m4a names in references.json.
 */
export function findClips(dir: string): Map<string, string> {
  const clips = new Map<string, string>();
  let files: string[] = [];
  try {
    files = readdirSync(dir);
  } catch {
    return clips;
  }
  for (const file of files.sort()) {
    if (!AUDIO.test(file)) continue;
    const name = file.replace(AUDIO, "");
    if (!STEM.test(name)) continue; // unrelated audio never enters scoring
    clips.set(name, join(dir, file));
  }
  return clips;
}

export const stem = (speaker: string, line: number) => `${speaker}_${String(line).padStart(2, "0")}`;
