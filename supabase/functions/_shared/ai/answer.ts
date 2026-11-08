// VIBRA AI final answer (docs/vibra-ai.md). The model returns JSON in this
// shape; the server then keeps as "verified" only refs a tool returned in
// this request, and drops everything else. Ideas never name an artist,
// album or event: those must be verified.
import type { AssistantAnswer, Idea, VerifiedItem } from "./types.ts";
import type { Registry } from "./tools.ts";

export const ANSWER_SCHEMA = {
  type: "object",
  properties: {
    answer: {
      type: "string",
      description: "A short, friendly answer in the user's language (max ~150 words). Plain text, no markdown tables.",
    },
    highlights: {
      type: "array",
      description: "Things to show as cards. Each ref must be copied exactly from a tool result in this conversation.",
      items: {
        type: "object",
        properties: {
          ref: { type: "string" },
          note: { type: "string", description: "One sentence: why this is relevant to the user." },
        },
        required: ["ref", "note"],
        additionalProperties: false,
      },
    },
    ideas: {
      type: "array",
      description: "Optional generated ideas that are not facts (a genre to explore, a listening tip). Never artists, albums or events.",
      items: {
        type: "object",
        properties: {
          title: { type: "string" },
          kind: { type: "string", enum: ["genre", "listening_tip", "other"] },
          note: { type: "string" },
        },
        required: ["title", "kind", "note"],
        additionalProperties: false,
      },
    },
  },
  required: ["answer", "highlights", "ideas"],
  additionalProperties: false,
} as const;

const clip = (v: unknown, max: number) => (typeof v === "string" ? v.trim().slice(0, max) : "");

export function finalizeAnswer(raw: unknown, registry: Registry): AssistantAnswer {
  // deno-lint-ignore no-explicit-any
  const r = (raw && typeof raw === "object" ? raw : {}) as any;
  const verified: VerifiedItem[] = [];
  const seen = new Set<string>();
  let dropped = 0;
  for (const h of Array.isArray(r.highlights) ? r.highlights : []) {
    const ref = clip(h?.ref, 120);
    const item = registry.items.get(ref);
    if (!item) {
      dropped++;
      continue;
    }
    if (seen.has(ref) || verified.length >= 12) continue;
    seen.add(ref);
    verified.push({ ...item, note: clip(h?.note, 240) || null });
  }
  const ideas: Idea[] = [];
  for (const i of Array.isArray(r.ideas) ? r.ideas : []) {
    const kind = ["genre", "listening_tip", "other"].find((k) => k === i?.kind) as Idea["kind"] | undefined;
    const title = clip(i?.title, 80);
    if (!kind || !title || ideas.length >= 5) continue;
    ideas.push({ title, kind, note: clip(i?.note, 240) });
  }
  return { answer: clip(r.answer, 2000), verified, ideas, dropped, status: "ok" };
}

/** Recent turns only, as plain text: the app keeps the conversation. */
export function cleanHistory(raw: unknown): { role: "user" | "assistant"; content: string }[] | null {
  if (!Array.isArray(raw)) return null;
  const turns = raw
    .filter((t) => t && (t.role === "user" || t.role === "assistant") && typeof t.content === "string" && t.content.trim())
    .map((t) => ({ role: t.role as "user" | "assistant", content: String(t.content).trim().slice(0, 2000) }))
    .slice(-10);
  // Must start and end with the user (a provider requirement and a sanity check).
  while (turns.length && turns[0].role !== "user") turns.shift();
  if (!turns.length || turns[turns.length - 1].role !== "user") return null;
  return turns;
}
