// VIBRA AI provider selection (docs/vibra-ai.md). With no provider
// configured this returns null: the assistant reports itself unavailable
// and nothing else in VIBRA is affected.
import type { AssistantProvider } from "./types.ts";

export type ProviderEnv = (name: string) => string | undefined;

export async function getAssistantProvider(env: ProviderEnv = (n) => Deno.env.get(n)): Promise<AssistantProvider | null> {
  if ((env("VIBRA_AI_ENABLED") ?? "true").toLowerCase() === "false") return null;
  const provider = (env("VIBRA_AI_PROVIDER") ?? "anthropic").toLowerCase();
  if (provider === "anthropic") {
    const key = env("ANTHROPIC_API_KEY");
    if (!key || key.length < 20) return null;
    // Imported lazily so the SDK is only loaded when the provider is used.
    const { AnthropicAssistant, DEFAULT_MODEL } = await import("./anthropic_provider.ts");
    return new AnthropicAssistant(key, env("VIBRA_AI_MODEL") || DEFAULT_MODEL);
  }
  return null;
}

export async function assistantAvailable(env?: ProviderEnv): Promise<boolean> {
  const e = env ?? ((n: string) => Deno.env.get(n));
  if ((e("VIBRA_AI_ENABLED") ?? "true").toLowerCase() === "false") return false;
  const provider = (e("VIBRA_AI_PROVIDER") ?? "anthropic").toLowerCase();
  return provider === "anthropic" && (e("ANTHROPIC_API_KEY")?.length ?? 0) >= 20;
}
