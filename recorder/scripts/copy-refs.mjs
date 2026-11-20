// Copies the single source of truth (bench/references.json) into public/.
// Vercel builds this project from recorder/ only and can't see ../bench, so the
// copy is committed and this script keeps it in sync whenever ../bench is visible.
import { copyFileSync, existsSync } from "node:fs";

const src = new URL("../../bench/references.json", import.meta.url);
const dest = new URL("../public/references.json", import.meta.url);

if (existsSync(src)) {
  copyFileSync(src, dest);
  console.log("copied bench/references.json -> public/references.json");
} else if (existsSync(dest)) {
  console.log("../bench not visible; using committed public/references.json");
} else {
  console.error("no references.json found");
  process.exit(1);
}
