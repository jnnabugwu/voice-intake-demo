import { deps } from "../lib/deps.js";
import { createSummaryHandler } from "../lib/handlers.js";
import { preflight } from "../lib/http.js";

/** POST /api/summary: the structured intake summary for the physician. */
export const POST = createSummaryHandler(deps);
export const OPTIONS = (request: Request) => preflight(request, deps.config);
