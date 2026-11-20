import { createClient } from "@supabase/supabase-js";

type LangText = { text: string };
type Line = { n: number; en: LangText; es: LangText };
type Speaker = { id: string; who: string };
type Refs = { speakers: Speaker[]; lines: Line[] };

/** One thing to record: a bench line, or a bonus re-read of it with background noise. */
type Item = { key: string; n: number; noise: boolean; text: string };

const BUCKET = "bench-audio";
const BONUS_LINES = [1, 2, 3, 4, 5];
const MIME_TYPES = ["audio/webm;codecs=opus", "audio/mp4"];

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  { auth: { persistSession: false } },
);

const app = document.getElementById("app")!;
const pad = (n: number) => String(n).padStart(2, "0");
const esc = (s: string) =>
  s.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

// ---------- progress (localStorage, never trusted to exist) ----------

function loadDone(speaker: string): Set<string> {
  try {
    const raw = localStorage.getItem(`recorder:${speaker}`);
    return new Set(raw ? (JSON.parse(raw) as string[]) : []);
  } catch {
    return new Set();
  }
}

function saveDone(speaker: string, done: Set<string>) {
  try {
    localStorage.setItem(`recorder:${speaker}`, JSON.stringify([...done]));
  } catch {
    /* private mode etc.: progress just won't survive a reload */
  }
}

// ---------- microphone ----------

let stream: MediaStream | null = null;

async function getStream(): Promise<MediaStream> {
  if (stream && stream.getAudioTracks().every((t) => t.readyState === "live")) {
    return stream;
  }
  stream = await navigator.mediaDevices.getUserMedia({
    audio: { echoCancellation: false, noiseSuppression: false, autoGainControl: true },
  });
  return stream;
}

// The mic is held only while a take is starting or recording, then released,
// so the browser's mic indicator goes off during playback and upload (and
// iOS doesn't route playback through the call-volume path).
function releaseStream() {
  stream?.getTracks().forEach((t) => t.stop());
  stream = null;
}

function pickMime(): string | undefined {
  if (typeof MediaRecorder === "undefined") return undefined;
  return MIME_TYPES.find((t) => MediaRecorder.isTypeSupported(t));
}

/** "audio/webm;codecs=opus" -> { contentType: "audio/webm", ext: "webm" } */
function fileType(mime: string) {
  const contentType = mime.split(";")[0].trim() || "audio/webm";
  return { contentType, ext: contentType.split("/")[1] };
}

// ---------- state ----------

let speaker = "";
let items: Item[] = [];
let done = new Set<string>();
let idx = 0;
let mediaRecorder: MediaRecorder | null = null;
/** True while waiting for the mic, so a second tap can't start a second recorder. */
let starting = false;
let recStart = 0;
let timer = 0;
let blob: Blob | null = null;
let blobUrl = "";
let busy = false;
let status = "";
let statusErr = false;

const mainCount = () => items.filter((i) => !i.noise && done.has(i.key)).length;
const mainTotal = () => items.filter((i) => !i.noise).length;

function setStatus(msg: string, err = false) {
  status = msg;
  statusErr = err;
}

function clearTake() {
  if (blobUrl) URL.revokeObjectURL(blobUrl);
  blob = null;
  blobUrl = "";
}

function goTo(i: number) {
  if (mediaRecorder || starting || busy) return;
  clearTake();
  setStatus("");
  idx = i;
  render();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function nextUndone(from: number): number {
  for (let k = 1; k <= items.length; k++) {
    const j = (from + k) % items.length;
    if (!done.has(items[j].key)) return j;
  }
  return -1;
}

// ---------- actions ----------

async function startRecording() {
  if (starting || mediaRecorder || busy) return;
  starting = true;
  clearTake();
  setStatus("Starting the microphone…");
  render(); // disables Record until the take has started or failed
  try {
    await beginTake();
  } catch (e) {
    releaseStream();
    setStatus((e as Error).message, true);
  } finally {
    starting = false;
    render();
  }
}

/** Acquires the mic and starts a MediaRecorder; throws a user-facing message on failure. */
async function beginTake() {
  let s: MediaStream;
  try {
    s = await getStream();
  } catch (e) {
    throw new Error(`Microphone blocked: ${(e as Error).message}. Allow mic access and try again.`);
  }
  const mime = pickMime();
  let rec: MediaRecorder;
  try {
    rec = mime ? new MediaRecorder(s, { mimeType: mime }) : new MediaRecorder(s);
  } catch (e) {
    throw new Error(`Recording isn't supported here: ${(e as Error).message}`);
  }
  const chunks: Blob[] = [];
  rec.ondataavailable = (ev) => {
    if (ev.data.size > 0) chunks.push(ev.data);
  };
  rec.onstop = () => {
    clearInterval(timer);
    releaseStream();
    const type = rec.mimeType || mime || chunks[0]?.type || "audio/webm";
    blob = new Blob(chunks, { type });
    blobUrl = URL.createObjectURL(blob);
    mediaRecorder = null;
    setStatus(blob.size ? "Listen back, then upload or re-record." : "Nothing was recorded. Try again.", !blob.size);
    if (!blob.size) clearTake();
    render();
  };
  rec.start();
  mediaRecorder = rec;
  recStart = Date.now();
  setStatus("Recording… 0s");
  timer = window.setInterval(() => {
    const el = document.getElementById("status");
    if (el) el.textContent = `Recording… ${Math.floor((Date.now() - recStart) / 1000)}s`;
  }, 250);
}

function stopRecording() {
  mediaRecorder?.stop();
}

async function upload() {
  if (!blob || busy) return;
  const item = items[idx];
  const { contentType, ext } = fileType(blob.type);
  const path = `${speaker}/${speaker}_${item.key}__${Date.now()}.${ext}`;
  busy = true;
  setStatus("Uploading…");
  render();
  const { error } = await supabase.storage
    .from(BUCKET)
    .upload(path, blob, { contentType, upsert: false });
  busy = false;
  if (error) {
    setStatus(`Upload failed: ${error.message}. Check your connection and tap Upload again.`, true);
    return render();
  }
  done.add(item.key);
  saveDone(speaker, done);
  clearTake();
  const next = nextUndone(idx);
  if (next === -1) {
    setStatus("All done. Thank you!");
  } else {
    idx = next;
    setStatus(`Line ${item.n}${item.noise ? " (noise)" : ""} uploaded ✓`);
  }
  render();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

// ---------- rendering ----------

function listHtml(noise: boolean) {
  return items
    .map((it, i) => ({ it, i }))
    .filter(({ it }) => it.noise === noise)
    .map(
      ({ it, i }) => `<li><button data-go="${i}" class="${i === idx ? "current" : ""}">
        <span class="mark">${done.has(it.key) ? "✓" : ""}</span>
        <span>${it.n}.</span><span class="t">${esc(it.text)}</span></button></li>`,
    )
    .join("");
}

function render() {
  const item = items[idx];
  const recording = mediaRecorder !== null;
  const bonusDone = items.filter((i) => i.noise && done.has(i.key)).length;

  let controls: string;
  if (recording) {
    controls = `<button class="rec" data-act="stop">■ Stop</button>`;
  } else if (blob) {
    controls = `<button class="primary" data-act="upload" ${busy ? "disabled" : ""}>Upload</button>
      <button data-act="record" ${busy || starting ? "disabled" : ""}>Re-record</button>`;
  } else {
    controls = `<button class="rec" data-act="record" ${starting ? "disabled" : ""}>● ${done.has(item.key) ? "Record again" : "Record"}</button>`;
  }

  app.innerHTML = `
    ${item.noise ? `<div class="bonus">Optional: lines 1–5 again with a TV or street noise in the background.</div>` : ""}
    <div class="num">Line ${item.n} of ${mainTotal()}${item.noise ? " · with background noise" : ""}${done.has(item.key) ? " · ✓ uploaded" : ""}</div>
    <div class="text">${esc(item.text)}</div>
    <div class="controls">${controls}</div>
    ${blobUrl && !recording ? `<audio controls playsinline src="${blobUrl}"></audio>` : ""}
    <div id="status" class="status ${statusErr ? "err" : ""}">${esc(status)}</div>

    <h2>${mainCount()} of ${mainTotal()} uploaded</h2>
    <ol>${listHtml(false)}</ol>
    <h2>Bonus, with background noise (${bonusDone} of ${BONUS_LINES.length})</h2>
    <ol>${listHtml(true)}</ol>
  `;
}

app.addEventListener("click", (ev) => {
  const btn = (ev.target as HTMLElement).closest("button");
  if (!btn) return;
  if (btn.dataset.go) return goTo(Number(btn.dataset.go));
  const act = btn.dataset.act;
  if (act === "record") void startRecording();
  else if (act === "stop") stopRecording();
  else if (act === "upload") void upload();
});

// ---------- boot ----------

async function boot() {
  const refs: Refs = await fetch("/references.json").then((r) => r.json());
  const s = new URLSearchParams(location.search).get("s") ?? "";
  if (!refs.speakers.some((sp) => sp.id === s)) {
    app.innerHTML = `<p>Who's recording?</p><div class="speakers">${refs.speakers
      .map((sp) => `<a href="?s=${sp.id}">${sp.id} · ${esc(sp.who)}</a>`)
      .join("")}</div>`;
    return;
  }
  speaker = s;
  const lang = s.startsWith("es") ? "es" : "en";
  const lines = [...refs.lines].sort((a, b) => a.n - b.n);
  items = [
    ...lines.map((l) => ({ key: pad(l.n), n: l.n, noise: false, text: l[lang].text })),
    ...lines
      .filter((l) => BONUS_LINES.includes(l.n))
      .map((l) => ({ key: `${pad(l.n)}_noise`, n: l.n, noise: true, text: l[lang].text })),
  ];
  done = loadDone(s);
  const first = items.findIndex((i) => !done.has(i.key));
  idx = first === -1 ? 0 : first;
  if (first === -1) setStatus("All done. Thank you!");
  render();
}

boot().catch((e) => {
  app.innerHTML = `<p class="err">Couldn't load the lines: ${esc(String(e))}</p>`;
});
