import seedRuns from "../../data/seeds/demo-runs.json";
import type { CrawlMode, ProviderName, RawOffer, SeedKeywordPreset } from "../../shared/types";

interface SeedRunPayload {
  id: string;
  mode: CrawlMode;
  startedAt: string;
  finishedAt: string;
  keywords: string[];
  providers: ProviderName[];
  offers: RawOffer[];
}

interface SeedDataPayload {
  keywords: SeedKeywordPreset[];
  demoRuns: SeedRunPayload[];
}

const typedSeedRuns = seedRuns as SeedDataPayload;

export function getSeedKeywords(): SeedKeywordPreset[] {
  return typedSeedRuns.keywords;
}

export function getSeedRuns(): SeedRunPayload[] {
  return typedSeedRuns.demoRuns;
}

export function getLatestSeedRun(): SeedRunPayload {
  return typedSeedRuns.demoRuns[typedSeedRuns.demoRuns.length - 1];
}
