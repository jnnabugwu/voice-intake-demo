import { describe, expect, it, vi } from "vitest";
import type { ReplyEvent, ReplyStream, Summarize } from "../lib/claude.js";
import { guardConfig, RateLimiter, SpendMeter } from "../lib/guards.js";
import { createChatHandler, createSummaryHandler, type Deps } from "../lib/handlers.js";

vi.spyOn(console, "log").mockImplementation(() => {});

const usage = { input: 100, output: 20, cacheWrite: 0, cacheRead: 0 };

function replyWith(...events: ReplyEvent[]): ReplyStream {
  return async function* () {
    for (const e of events) yield e;
  };
}

function deps(overrides: Partial<Deps> = {}): Deps {
  const config = guardConfig({ ALLOWED_ORIGINS: "https://app.example" });
  return {
    config,
    limiter: new RateLimiter(100),
    meter: new SpendMeter(5),
    reply: replyWith({ type: "text", text: "How " }, { type: "text", text: "long?" }, { type: "end", refused: false, usage }),
    summarize: async () => ({ type: "refused", usage }),
    ...overrides,
  };
}

const chatBody = {
  conversationId: "c_1",
  turnId: "t_1",
  language: "en",
  messages: [{ role: "user", text: "My throat hurts" }],
};

function post(body: unknown, origin = "https://app.example", ip = "1.2.3.4") {
  return new Request("https://proxy.example/api/chat", {
    method: "POST",
    headers: { "content-type": "application/json", origin, "x-forwarded-for": ip },
    body: JSON.stringify(body),
  });
}

describe("POST /api/chat", () => {
  it("streams deltas then done, with CORS for the app's origin", async () => {
    const res = await createChatHandler(deps())(post(chatBody));
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    expect(res.headers.get("access-control-allow-origin")).toBe("https://app.example");
    expect(await res.text()).toBe(
      'event: delta\ndata: {"text":"How "}\n\nevent: delta\ndata: {"text":"long?"}\n\nevent: done\ndata: {}\n\n',
    );
  });

  it("a refusal ends with a refusal event", async () => {
    const res = await createChatHandler(
      deps({ reply: replyWith({ type: "text", text: "Par" }, { type: "end", refused: true, usage }) }),
    )(post(chatBody));
    expect(await res.text()).toMatch(/event: refusal\ndata: \{\}\n\n$/);
  });

  it("an upstream failure mid-stream ends with an error event", async () => {
    const reply: ReplyStream = async function* () {
      yield { type: "text", text: "Hi" };
      throw new Error("overloaded");
    };
    const res = await createChatHandler(deps({ reply }))(post(chatBody));
    expect(await res.text()).toMatch(/event: error\ndata: \{"code":"upstream"\}\n\n$/);
  });

  it("a red flag answers with red_flag and never calls the model", async () => {
    const reply = vi.fn(replyWith({ type: "end", refused: false, usage }));
    const res = await createChatHandler(deps({ reply }))(
      post({ ...chatBody, messages: [{ role: "user", text: "Tengo un dolor en el pecho y me falta el aire" }] }),
    );
    expect(await res.text()).toBe('event: red_flag\ndata: {"kind":"emergency"}\n\n');
    expect(reply).not.toHaveBeenCalled();
  });

  it("a reply cut short by an upstream error still meters what it generated", async () => {
    const meter = new SpendMeter(5);
    const reply: ReplyStream = async function* ({ onUsage }) {
      onUsage?.({ input: 1000, output: 500, cacheWrite: 0, cacheRead: 0 });
      yield { type: "text", text: "Hi" };
      throw new Error("overloaded");
    };
    await (await createChatHandler(deps({ reply, meter }))(post(chatBody))).text();
    expect(meter.spent).toBeGreaterThan(0);
  });

  it("a client that disconnects aborts the upstream request", async () => {
    let signal: AbortSignal | undefined;
    const reply: ReplyStream = async function* (input) {
      signal = input.signal;
      yield { type: "text", text: "Hi" };
      await new Promise((r) => setTimeout(r, 20));
      yield { type: "end", refused: false, usage };
    };
    const res = await createChatHandler(deps({ reply }))(post(chatBody));
    const reader = res.body!.getReader();
    await reader.read();
    await reader.cancel();
    expect(signal?.aborted).toBe(true);
  });

  it("an answered turn ID replays without calling the model again", async () => {
    const reply = vi.fn(replyWith({ type: "text", text: "Once" }, { type: "end", refused: false, usage }));
    const handler = createChatHandler(deps({ reply }));
    await (await handler(post(chatBody))).text();
    const again = await (await handler(post(chatBody))).text();
    expect(reply).toHaveBeenCalledTimes(1);
    expect(again).toContain('{"text":"Once"}');
    expect(again).toContain("event: done");
  });

  it("a reused turn ID with a new emergency message is checked, not replayed", async () => {
    const handler = createChatHandler(deps());
    await (await handler(post(chatBody))).text();
    const res = await handler(post({ ...chatBody, messages: [{ role: "user", text: "I have chest pain" }] }));
    expect(await res.text()).toContain("event: red_flag");
  });

  it("a duplicate of a turn still streaming doesn't call the model again", async () => {
    let release!: () => void;
    const gate = new Promise<void>((r) => (release = r));
    const reply = vi.fn(async function* () {
      yield { type: "text" as const, text: "Hi" };
      await gate;
      yield { type: "end" as const, refused: false, usage };
    });
    const handler = createChatHandler(deps({ reply }));
    const first = await handler(post(chatBody));
    const reader = first.body!.getReader();
    await reader.read();
    const second = await handler(post(chatBody));
    expect(second.status).toBe(429);
    expect(reply).toHaveBeenCalledTimes(1);
    release();
    while (!(await reader.read()).done) {}
    expect(await (await handler(post(chatBody))).text()).toContain("event: done");
  });

  it("an earlier red flag in the history is caught, even if the newest message is benign", async () => {
    const reply = vi.fn(replyWith({ type: "end", refused: false, usage }));
    const res = await createChatHandler(deps({ reply }))(
      post({
        ...chatBody,
        messages: [
          { role: "user", text: "I have chest pain" },
          { role: "assistant", text: "How long?" },
          { role: "user", text: "an hour" },
        ],
      }),
    );
    expect(await res.text()).toContain("event: red_flag");
    expect(reply).not.toHaveBeenCalled();
  });

  it("a refused turn replays its refusal instead of calling the model again", async () => {
    const reply = vi.fn(replyWith({ type: "end", refused: true, usage }));
    const handler = createChatHandler(deps({ reply }));
    await (await handler(post(chatBody))).text();
    expect(await (await handler(post(chatBody))).text()).toContain("event: refusal");
    expect(reply).toHaveBeenCalledTimes(1);
  });

  it("an answered turn still replays after the cap closes", async () => {
    const meter = new SpendMeter(0.0001);
    const handler = createChatHandler(deps({ meter }));
    await (await handler(post(chatBody))).text();
    expect(meter.isOverCap()).toBe(true);
    const replay = await handler(post(chatBody));
    expect(replay.status).toBe(200);
    expect(await replay.text()).toContain("event: done");
  });

  it("over the per-IP rate limit returns 429 rate_limited", async () => {
    const handler = createChatHandler(deps({ limiter: new RateLimiter(1) }));
    expect((await handler(post({ ...chatBody, turnId: "a" }))).status).toBe(200);
    const res = await handler(post({ ...chatBody, turnId: "b" }));
    expect(res.status).toBe(429);
    expect(await res.json()).toEqual({ code: "rate_limited" });
  });

  it("a red flag is answered even when the IP is rate limited", async () => {
    const handler = createChatHandler(deps({ limiter: new RateLimiter(1) }));
    await (await handler(post(chatBody))).text();
    const res = await handler(post({ ...chatBody, turnId: "t_9", messages: [{ role: "user", text: "chest pain" }] }));
    expect(res.status).toBe(200);
    expect(await res.text()).toContain("event: red_flag");
  });

  it("a red flag is answered even after the spend cap closes", async () => {
    const res = await createChatHandler(deps({ meter: new SpendMeter(0) }))(
      post({ ...chatBody, messages: [{ role: "user", text: "I have chest pain" }] }),
    );
    expect(res.status).toBe(200);
    expect(await res.text()).toContain("event: red_flag");
  });

  it("over the daily spend cap returns 429 spend_cap", async () => {
    const res = await createChatHandler(deps({ meter: new SpendMeter(0) }))(post(chatBody));
    expect(res.status).toBe(429);
    expect(await res.json()).toEqual({ code: "spend_cap" });
    expect(res.headers.get("access-control-allow-origin")).toBe("https://app.example");
  });

  it("spending is recorded, so the cap closes after enough turns", async () => {
    const meter = new SpendMeter(0.0001);
    const handler = createChatHandler(deps({ meter }));
    await (await handler(post(chatBody))).text();
    expect((await handler(post({ ...chatBody, turnId: "t_2" }))).status).toBe(429);
  });

  it("a malformed request is a 400", async () => {
    const handler = createChatHandler(deps());
    expect((await handler(post({ ...chatBody, language: "fr" }))).status).toBe(400);
    expect((await handler(post({ ...chatBody, messages: [{ role: "assistant", text: "hi" }] }))).status).toBe(400);
    expect((await handler(post("a json string, not an object"))).status).toBe(400);
    const raw = new Request("https://proxy.example/api/chat", {
      method: "POST",
      headers: { "content-type": "application/json", origin: "https://app.example" },
      body: "{not json",
    });
    expect((await handler(raw)).status).toBe(400);
  });

  it("an origin that isn't allowed is a 403", async () => {
    expect((await createChatHandler(deps())(post(chatBody, "https://evil.example"))).status).toBe(403);
  });
});

describe("POST /api/summary", () => {
  const summaryBody = { conversationId: "c_1", language: "es", transcript: "Worker: Me duele la garganta." };
  const model = {
    chief_complaint: "Sore throat",
    duration: null,
    severity: null,
    symptoms: ["sore throat"],
    medications: [],
    allergies: [],
    red_flags: [],
    open_questions: ["How long?"],
  };

  it("returns the model's fields plus the request's language and untouched transcript", async () => {
    const summarize: Summarize = async () => ({ type: "ok", summary: model, usage });
    const res = await createSummaryHandler(deps({ summarize }))(post(summaryBody));
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ...model, language: "es", transcript: summaryBody.transcript });
  });

  it("a refusal or a failure is a 502 upstream", async () => {
    expect((await createSummaryHandler(deps())(post(summaryBody))).status).toBe(502);
    const throwing: Summarize = async () => {
      throw new Error("boom");
    };
    const res = await createSummaryHandler(deps({ summarize: throwing }))(post(summaryBody));
    expect(res.status).toBe(502);
    expect(await res.json()).toEqual({ code: "upstream" });
  });
});
