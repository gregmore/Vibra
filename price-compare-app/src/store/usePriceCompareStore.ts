import { create } from "zustand";
import type {
  CrawlMode,
  CrawlResult,
  HistoryPoint,
  ProviderName,
  SeedKeywordPreset,
} from "../../shared/types";

interface PriceCompareState {
  presets: SeedKeywordPreset[];
  result: CrawlResult | null;
  history: Record<string, HistoryPoint[]>;
  loading: boolean;
  error: string | null;
  mode: CrawlMode;
  activeKeyword: string;
  keywordsInput: string;
  providers: ProviderName[];
  limitPerProvider: number;
  bootstrap: () => Promise<void>;
  setKeywordsInput: (value: string) => void;
  setMode: (value: CrawlMode) => void;
  setActiveKeyword: (value: string) => void;
  toggleProvider: (provider: ProviderName) => void;
  setLimitPerProvider: (value: number) => void;
  applyPreset: (keyword: string) => void;
  runCrawl: () => Promise<void>;
  loadHistory: (keyword: string) => Promise<void>;
}

async function fetchJson<T>(input: RequestInfo, init?: RequestInit): Promise<T> {
  const response = await fetch(input, init);

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || "Request failed");
  }

  return response.json() as Promise<T>;
}

export const usePriceCompareStore = create<PriceCompareState>((set, get) => ({
  presets: [],
  result: null,
  history: {},
  loading: false,
  error: null,
  mode: "demo",
  activeKeyword: "wireless earbuds",
  keywordsInput: "wireless earbuds\ngaming mouse\nportable power bank",
  providers: ["jd", "taobao", "pinduoduo"],
  limitPerProvider: 3,
  bootstrap: async () => {
    set({ loading: true, error: null });

    try {
      const [seedResponse, latestResponse] = await Promise.all([
        fetchJson<{ keywords: SeedKeywordPreset[]; sampleResult: CrawlResult }>("/api/seeds"),
        fetchJson<{ success: boolean; data: CrawlResult | null }>("/api/runs/latest"),
      ]);

      set({
        presets: seedResponse.keywords,
        result: latestResponse.data ?? seedResponse.sampleResult,
        activeKeyword: (latestResponse.data ?? seedResponse.sampleResult).summary[0]?.keyword ?? "wireless earbuds",
        loading: false,
      });
    } catch (error) {
      set({
        loading: false,
        error: error instanceof Error ? error.message : "Unable to load initial data",
      });
    }
  },
  setKeywordsInput: (keywordsInput) => set({ keywordsInput }),
  setMode: (mode) => set({ mode }),
  setActiveKeyword: (activeKeyword) => set({ activeKeyword }),
  toggleProvider: (provider) => {
    const current = get().providers;
    const providers = current.includes(provider)
      ? current.filter((item) => item !== provider)
      : [...current, provider];

    set({
      providers: providers.length > 0 ? providers : current,
    });
  },
  setLimitPerProvider: (limitPerProvider) => set({ limitPerProvider }),
  applyPreset: (keyword) => {
    const currentKeywords = get()
      .keywordsInput
      .split("\n")
      .map((value) => value.trim())
      .filter(Boolean);

    if (!currentKeywords.includes(keyword)) {
      set({
        keywordsInput: [...currentKeywords, keyword].join("\n"),
      });
    }
  },
  runCrawl: async () => {
    const keywords = get()
      .keywordsInput
      .split("\n")
      .map((value) => value.trim())
      .filter(Boolean);

    if (keywords.length === 0) {
      set({ error: "Enter at least one keyword before running the collector." });
      return;
    }

    set({ loading: true, error: null });

    try {
      const payload = await fetchJson<{ success: boolean; data: CrawlResult }>("/api/crawl", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          keywords,
          providers: get().providers,
          limitPerProvider: get().limitPerProvider,
          mode: get().mode,
        }),
      });

      set({
        result: payload.data,
        activeKeyword: payload.data.summary[0]?.keyword ?? get().activeKeyword,
        loading: false,
      });
    } catch (error) {
      set({
        loading: false,
        error: error instanceof Error ? error.message : "Unable to complete run",
      });
    }
  },
  loadHistory: async (keyword) => {
    if (get().history[keyword]) {
      return;
    }

    try {
      const payload = await fetchJson<{ success: boolean; data: HistoryPoint[] }>(
        `/api/runs/history?keyword=${encodeURIComponent(keyword)}`,
      );

      set({
        history: {
          ...get().history,
          [keyword]: payload.data,
        },
      });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : "Unable to load history",
      });
    }
  },
}));
