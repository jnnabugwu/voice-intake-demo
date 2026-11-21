import { deps } from "../lib/deps.js";
import { createChatHandler } from "../lib/handlers.js";
import { preflight } from "../lib/http.js";

/** POST /api/chat: streams the assistant's next reply as server-sent events. */
export const POST = createChatHandler(deps);
export const OPTIONS = (request: Request) => preflight(request, deps.config);
