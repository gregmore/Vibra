export const providerNames = ["jd", "taobao", "pinduoduo"] as const;

export type ProviderName = (typeof providerNames)[number];
export type CrawlMode = "demo" | "live";

export interface CrawlRequest {
  keywords: string[];
  providers: ProviderName[];
  limitPerProvider?: number;
  mode: CrawlMode;
}

export interface RawOffer {
  keyword: string;
  provider: ProviderName;
  productName: string;
  priceText: string;
  originalPriceText?: string;
  salesText?: string;
  storeName?: string;
  storeRatingText?: string;
  productUrl: string;
  thumbnailUrl?: string;
  scrapedAt: string;
  rawPayload?: Record<string, unknown>;
}

export interface NormalizedOffer {
  id: string;
  keyword: string;
  provider: ProviderName;
  productName: string;
  normalizedTitle: string;
  price: number;
  originalPrice?: number;
  salesVolume?: number;
  storeName?: string;
  storeRating?: number;
  productUrl: string;
  thumbnailUrl?: string;
  scrapedAt: string;
  fingerprint: string;
  labels: string[];
  valueScore: number;
}

export interface RunSummary {
  keyword: string;
  lowestPrice: number;
  averagePrice: number;
  medianPrice: number;
  offerCount: number;
  bestValueProduct: string;
}

export interface HistoryPoint {
  runId: string;
  keyword: string;
  capturedAt: string;
  minPrice: number;
  averagePrice: number;
  medianPrice: number;
}

export interface CrawlResult {
  runId: string;
  mode: CrawlMode;
  startedAt: string;
  finishedAt: string;
  keywords: string[];
  providers: ProviderName[];
  offers: NormalizedOffer[];
  summary: RunSummary[];
  warnings: string[];
  historyPreview: HistoryPoint[];
}

export interface SeedKeywordPreset {
  keyword: string;
  note: string;
}

export interface SeedResponse {
  keywords: SeedKeywordPreset[];
  sampleResult: CrawlResult;
}

export interface CrawlApiResponse {
  success: boolean;
  data: CrawlResult;
}

export interface LatestRunResponse {
  success: boolean;
  data: CrawlResult | null;
}

export interface HistoryResponse {
  success: boolean;
  data: HistoryPoint[];
}
