import {
  buildRunSummary,
  deduplicateOffers,
  enrichOffers,
  normalizeOffer,
} from "../../shared/scoring";
import type {
  CrawlRequest,
  CrawlResult,
  HistoryPoint,
  LatestRunResponse,
  NormalizedOffer,
  RawOffer,
  SeedResponse,
} from "../../shared/types";
import {
  countRuns,
  getLatestRunRow,
  getKeywordOffers,
  getRunMetadata,
  getRunOffers,
  insertRun,
} from "../lib/database";
import { getLatestSeedRun, getSeedKeywords, getSeedRuns } from "../lib/seed-data";
import { searchMarketplace } from "./adapters";

let initialized = false;

function createRunId(): string {
  return `run-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function median(values: number[]): number {
  if (values.length === 0) {
    return 0;
  }

  const sorted = [...values].sort((left, right) => left - right);
  const midpoint = Math.floor(sorted.length / 2);

  return sorted.length % 2 === 0
    ? Number(((sorted[midpoint - 1] + sorted[midpoint]) / 2).toFixed(2))
    : sorted[midpoint];
}

function groupHistory(offers: Array<NormalizedOffer & { runId: string }>): HistoryPoint[] {
  const grouped = new Map<string, Array<NormalizedOffer & { runId: string }>>();

  for (const offer of offers) {
    const bucket = grouped.get(offer.runId) ?? [];
    bucket.push(offer);
    grouped.set(offer.runId, bucket);
  }

  return Array.from(grouped.entries()).map(([runId, runOffers]) => {
    const prices = runOffers.map((item) => item.price);
    const averagePrice = prices.reduce((sum, value) => sum + value, 0) / prices.length;

    return {
      runId,
      keyword: runOffers[0]?.keyword ?? "",
      capturedAt: runOffers[0]?.scrapedAt ?? new Date().toISOString(),
      minPrice: Math.min(...prices),
      averagePrice: Number(averagePrice.toFixed(2)),
      medianPrice: median(prices),
    };
  });
}

function buildResultPayload(input: {
  runId: string;
  mode: CrawlResult["mode"];
  startedAt: string;
  finishedAt: string;
  keywords: string[];
  providers: CrawlRequest["providers"];
  offers: NormalizedOffer[];
  warnings: string[];
  historyPreview: HistoryPoint[];
}): CrawlResult {
  return {
    runId: input.runId,
    mode: input.mode,
    startedAt: input.startedAt,
    finishedAt: input.finishedAt,
    keywords: input.keywords,
    providers: input.providers,
    offers: input.offers,
    summary: buildRunSummary(input.offers),
    warnings: input.warnings,
    historyPreview: input.historyPreview,
  };
}

function processRawOffers(rawOffers: RawOffer[]): NormalizedOffer[] {
  const normalized = rawOffers
    .map((offer) => normalizeOffer(offer))
    .filter((offer): offer is NormalizedOffer => offer !== null);

  return enrichOffers(deduplicateOffers(normalized));
}

async function persistRun(result: CrawlResult): Promise<void> {
  await insertRun({
    runId: result.runId,
    mode: result.mode,
    startedAt: result.startedAt,
    finishedAt: result.finishedAt,
    keywords: result.keywords,
    providers: result.providers,
    offers: result.offers,
  });
}

export async function initializePriceCompareService(): Promise<void> {
  if (initialized) {
    return;
  }

  const runCount = await countRuns();

  if (runCount === 0) {
    for (const seedRun of getSeedRuns()) {
      const offers = processRawOffers(seedRun.offers);

      await persistRun(buildResultPayload({
        runId: seedRun.id,
        mode: seedRun.mode,
        startedAt: seedRun.startedAt,
        finishedAt: seedRun.finishedAt,
        keywords: seedRun.keywords,
        providers: seedRun.providers,
        offers,
        warnings: [],
        historyPreview: [],
      }));
    }
  }

  initialized = true;
}

export async function runPriceComparison(request: CrawlRequest): Promise<CrawlResult> {
  await initializePriceCompareService();

  const startedAt = new Date().toISOString();
  const warnings = new Set<string>();
  const rawOffers: RawOffer[] = [];

  for (const keyword of request.keywords) {
    for (const provider of request.providers) {
      const result = await searchMarketplace({
        keyword,
        provider,
        mode: request.mode,
        limit: request.limitPerProvider ?? 3,
      });

      result.warnings.forEach((warning) => warnings.add(warning));
      rawOffers.push(...result.offers);
    }
  }

  const offers = processRawOffers(rawOffers);
  const finishedAt = new Date().toISOString();
  const runId = createRunId();

  const historyBuckets = await Promise.all(
    request.keywords.map((keyword) => getHistoryForKeyword(keyword)),
  );

  const result = buildResultPayload({
    runId,
    mode: request.mode,
    startedAt,
    finishedAt,
    keywords: request.keywords,
    providers: request.providers,
    offers,
    warnings: Array.from(warnings),
    historyPreview: historyBuckets.flat(),
  });

  await persistRun(result);

  return result;
}

export async function getLatestRun(): Promise<CrawlResult | null> {
  await initializePriceCompareService();

  const latestRun = await getLatestRunRow();
  if (!latestRun) {
    return null;
  }

  const offers = await getRunOffers(latestRun.id);
  const keywords = JSON.parse(latestRun.keywords_json) as string[];
  const providers = JSON.parse(latestRun.providers_json) as CrawlRequest["providers"];
  const historyPreview = (await Promise.all(keywords.map((keyword) => getHistoryForKeyword(keyword)))).flat();

  return buildResultPayload({
    runId: latestRun.id,
    mode: latestRun.mode,
    startedAt: latestRun.started_at,
    finishedAt: latestRun.finished_at,
    keywords,
    providers,
    offers,
    warnings: [],
    historyPreview,
  });
}

export async function getHistoryForKeyword(keyword: string): Promise<HistoryPoint[]> {
  await initializePriceCompareService();
  const offers = await getKeywordOffers(keyword);
  return groupHistory(offers);
}

export async function getSeedResponse(): Promise<SeedResponse> {
  await initializePriceCompareService();

  const latestSeedRun = getLatestSeedRun();
  const latestStoredSeed = await getRunMetadata(latestSeedRun.id);
  const offers = latestStoredSeed ? await getRunOffers(latestSeedRun.id) : processRawOffers(latestSeedRun.offers);
  const historyPreview = (await Promise.all(latestSeedRun.keywords.map((keyword) => getHistoryForKeyword(keyword)))).flat();

  return {
    keywords: getSeedKeywords(),
    sampleResult: buildResultPayload({
      runId: latestSeedRun.id,
      mode: latestSeedRun.mode,
      startedAt: latestSeedRun.startedAt,
      finishedAt: latestSeedRun.finishedAt,
      keywords: latestSeedRun.keywords,
      providers: latestSeedRun.providers,
      offers,
      warnings: [],
      historyPreview,
    }),
  };
}

export async function exportLatestRun(format: "json" | "csv"): Promise<string | null> {
  const latestRun = await getLatestRun();

  if (!latestRun) {
    return null;
  }

  if (format === "json") {
    return JSON.stringify(latestRun, null, 2);
  }

  const rows = [
    [
      "keyword",
      "provider",
      "productName",
      "price",
      "originalPrice",
      "salesVolume",
      "storeName",
      "storeRating",
      "labels",
      "productUrl",
      "scrapedAt",
    ],
    ...latestRun.offers.map((offer) => [
      offer.keyword,
      offer.provider,
      offer.productName,
      offer.price.toFixed(2),
      offer.originalPrice?.toFixed(2) ?? "",
      offer.salesVolume?.toString() ?? "",
      offer.storeName ?? "",
      offer.storeRating?.toFixed(1) ?? "",
      offer.labels.join("|"),
      offer.productUrl,
      offer.scrapedAt,
    ]),
  ];

  return rows
    .map((row) => row.map((value) => `"${value.replace(/"/g, '""')}"`).join(","))
    .join("\n");
}

export function processOffersForTest(rawOffers: RawOffer[]): NormalizedOffer[] {
  return processRawOffers(rawOffers);
}

export async function getLatestRunResponse(): Promise<LatestRunResponse> {
  return {
    success: true,
    data: await getLatestRun(),
  };
}
