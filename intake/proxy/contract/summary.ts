import { z } from "zod";

/**
 * What the model fills in. `language` and `transcript` are not asked of the
 * model: the proxy sets them from the request, so the transcript is never
 * rewritten.
 */
export const ModelSummary = z.object({
  chief_complaint: z.string().nullable().describe("The main reason for the request, in the worker's words, in English. Null if not said."),
  duration: z.string().nullable().describe("How long it has been going on, as said (e.g. '3 days'). Null if not said."),
  severity: z.number().int().min(1).max(10).nullable().describe("1-10 only if the worker gave a number. Null otherwise."),
  symptoms: z.array(z.string()).describe("Symptoms the worker said, in English. Empty if none."),
  medications: z.array(z.string()).describe("Medications and doses exactly as said. Empty if none."),
  allergies: z.array(z.string()).describe("Allergies as said. Empty if none."),
  red_flags: z.array(z.string()).describe("Emergency or crisis signs the worker said: chest pain, trouble breathing, stroke signs, self-harm or suicide language. Empty if none."),
  open_questions: z.array(z.string()).describe("What a clinician should still ask, in English. Empty if nothing."),
});

export const IntakeSummary = ModelSummary.extend({
  language: z.enum(["en", "es"]),
  transcript: z.string(),
});

export type IntakeSummary = z.infer<typeof IntakeSummary>;
