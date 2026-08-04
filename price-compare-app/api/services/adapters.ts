import { getLatestSeedRun } from "../lib/seed-data";
import type { CrawlMode, ProviderName, RawOffer } from "../../shared/types";

export interface AdapterSearchOptions {
  keyword: string;
  provider: ProviderName;
  mode: CrawlMode;
  limit: number;
}

export interface AdapterSearchResult {
  offers: RawOffer[];
  warnings: string[];
}

const providerNames: ProviderName[] = ["jd", "taobao", "pinduoduo"];

function buildSearchUrl(provider: ProviderName, keyword: string): string {
  const encoded = encodeURIComponent(keyword);

  switch (provider) {
    case "jd":
      return `https://search.jd.com/Search?keyword=${encoded}`;
    case "taobao":
      return `https://s.taobao.com/search?q=${encoded}`;
    case "pinduoduo":
      return `https://mobile.yangkeduo.com/search_result.html?search_key=${encoded}`;
    default:
      return "#";
  }
}

function hashKeyword(value: string): number {
  return value.split("").reduce((accumulator, char) => accumulator + char.charCodeAt(0), 0);
}

function createLiveFallbackOffer(keyword: string, provider: ProviderName): RawOffer {
  const seed = hashKeyword(`${keyword}-${provider}`);
  const price = 80 + (seed % 180);
  const sales = 3500 + (seed % 18000);
  const rating = 4.2 + (seed % 7) * 0.1;
  const suffix = provider === "jd" ? "Flagship Pick" : provider === "taobao" ? "Merchant Edition" : "Value Pack";

  return {
    keyword,
    provider,
    productName: `${keyword.replace(/\b\w/g, (segment) => segment.toUpperCase())} ${suffix}`,
    priceText: price.toFixed(2),
    originalPriceText: (price + 30 + (seed % 25)).toFixed(2),
    salesText: `${sales}`,
    storeName: provider === "jd" ? "JD Marketplace" : provider === "taobao" ? "Taobao Marketplace" : "Pinduoduo Marketplace",
    storeRatingText: rating.toFixed(1),
    productUrl: buildSearchUrl(provider, keyword),
    scrapedAt: new Date().toISOString(),
    rawPayload: {
      source: "live-fallback",
    },
  };
}

function getSeedOffers(keyword: string, provider: ProviderName): RawOffer[] {
  const latestSeedRun = getLatestSeedRun();

  return latestSeedRun.offers.filter(
    (offer) => offer.keyword.toLowerCase() === keyword.toLowerCase() && offer.provider === provider,
  );
}

export async function searchMarketplace(options: AdapterSearchOptions): Promise<AdapterSearchResult> {
  if (!providerNames.includes(options.provider)) {
    return {
      offers: [],
      warnings: [`Unsupported provider "${options.provider}" was skipped.`],
    };
  }

  const seededOffers = getSeedOffers(options.keyword, options.provider)
    .slice(0, options.limit)
    .map((offer) => ({
      ...offer,
      scrapedAt: new Date().toISOString(),
    }));

  if (options.mode === "demo") {
    return {
      offers: seededOffers,
      warnings: [],
    };
  }

  const offers = seededOffers.length > 0 ? seededOffers.map((offer, index) => {
    const shift = options.provider === "jd" ? 6 : options.provider === "taobao" ? 3 : -4;
    const currentPrice = Number(offer.priceText) + shift + index;
    return {
      ...offer,
      priceText: currentPrice.toFixed(2),
      productUrl: buildSearchUrl(options.provider, options.keyword),
      scrapedAt: new Date().toISOString(),
      rawPayload: {
        source: "live-seeded-fallback",
      },
    };
  }) : [createLiveFallbackOffer(options.keyword, options.provider)];

  return {
    offers: offers.slice(0, options.limit),
    warnings: [
      `Live mode uses pluggable fallback collectors for ${options.provider}; replace with site-specific legal adapters for production crawling.`,
    ],
  };
}
