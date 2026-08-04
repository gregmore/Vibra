import type { NormalizedOffer, RawOffer, RunSummary } from "./types";

const tokenPattern = /[a-z0-9]+/g;

export function normalizeTitle(value: string): string {
  return value.toLowerCase().match(tokenPattern)?.join(" ") ?? value.toLowerCase().trim();
}

export function parsePriceText(value?: string): number | undefined {
  if (!value) {
    return undefined;
  }

  const match = value.replace(/,/g, "").match(/(\d+(?:\.\d+)?)/);
  return match ? Number(match[1]) : undefined;
}

export function parseSalesText(value?: string): number | undefined {
  if (!value) {
    return undefined;
  }

  const compact = value.toLowerCase().replace(/,/g, "");
  const match = compact.match(/(\d+(?:\.\d+)?)/);

  if (!match) {
    return undefined;
  }

  const base = Number(match[1]);

  if (compact.includes("万")) {
    return Math.round(base * 10000);
  }

  if (compact.includes("k")) {
    return Math.round(base * 1000);
  }

  return Math.round(base);
}

export function parseStoreRatingText(value?: string): number | undefined {
  if (!value) {
    return undefined;
  }

  const match = value.match(/(\d+(?:\.\d+)?)/);
  if (!match) {
    return undefined;
  }

  const rating = Number(match[1]);
  return Math.max(0, Math.min(5, rating));
}

function createFingerprint(raw: RawOffer, normalizedTitleValue: string, parsedPrice: number): string {
  const vendor = (raw.storeName ?? "unknown-store").toLowerCase();
  const titleKey = normalizedTitleValue.split(" ").slice(0, 6).join("-");
  return [raw.keyword.toLowerCase(), raw.provider, vendor, titleKey, parsedPrice.toFixed(2)].join("|");
}

function createId(raw: RawOffer, fingerprint: string): string {
  const base = `${raw.provider}-${fingerprint}-${raw.scrapedAt}`;
  return base.replace(/[^a-z0-9]+/gi, "-").replace(/(^-|-$)/g, "").slice(0, 120);
}

export function normalizeOffer(raw: RawOffer): NormalizedOffer | null {
  const price = parsePriceText(raw.priceText);
  if (price === undefined) {
    return null;
  }

  const normalizedTitleValue = normalizeTitle(raw.productName);
  const fingerprint = createFingerprint(raw, normalizedTitleValue, price);

  return {
    id: createId(raw, fingerprint),
    keyword: raw.keyword,
    provider: raw.provider,
    productName: raw.productName.trim(),
    normalizedTitle: normalizedTitleValue,
    price,
    originalPrice: parsePriceText(raw.originalPriceText),
    salesVolume: parseSalesText(raw.salesText),
    storeName: raw.storeName?.trim(),
    storeRating: parseStoreRatingText(raw.storeRatingText),
    productUrl: raw.productUrl,
    thumbnailUrl: raw.thumbnailUrl,
    scrapedAt: raw.scrapedAt,
    fingerprint,
    labels: [],
    valueScore: 0,
  };
}

export function deduplicateOffers(offers: NormalizedOffer[]): NormalizedOffer[] {
  const seen = new Map<string, NormalizedOffer>();

  for (const offer of offers) {
    const existing = seen.get(offer.fingerprint);

    if (!existing) {
      seen.set(offer.fingerprint, offer);
      continue;
    }

    const currentCompleteness = Number(Boolean(existing.salesVolume)) + Number(Boolean(existing.storeRating));
    const nextCompleteness = Number(Boolean(offer.salesVolume)) + Number(Boolean(offer.storeRating));

    if (nextCompleteness > currentCompleteness) {
      seen.set(offer.fingerprint, offer);
    }
  }

  return Array.from(seen.values());
}

function scoreOffer(offer: NormalizedOffer, offers: NormalizedOffer[]): number {
  const prices = offers.map((item) => item.price);
  const minPrice = Math.min(...prices);
  const maxPrice = Math.max(...prices);
  const salesMax = Math.max(...offers.map((item) => item.salesVolume ?? 0), 1);
  const ratingMax = Math.max(...offers.map((item) => item.storeRating ?? 0), 5);
  const priceRange = Math.max(maxPrice - minPrice, 1);

  const priceScore = 1 - (offer.price - minPrice) / priceRange;
  const salesScore = Math.log1p(offer.salesVolume ?? 0) / Math.log1p(salesMax);
  const ratingScore = (offer.storeRating ?? 0) / ratingMax;
  const discountScore = offer.originalPrice && offer.originalPrice > offer.price
    ? (offer.originalPrice - offer.price) / offer.originalPrice
    : 0;

  return Number((priceScore * 0.5 + salesScore * 0.2 + ratingScore * 0.2 + discountScore * 0.1).toFixed(3));
}

export function enrichOffers(offers: NormalizedOffer[]): NormalizedOffer[] {
  const grouped = new Map<string, NormalizedOffer[]>();

  for (const offer of offers) {
    const bucket = grouped.get(offer.keyword) ?? [];
    bucket.push({ ...offer });
    grouped.set(offer.keyword, bucket);
  }

  const enriched: NormalizedOffer[] = [];

  for (const keywordOffers of grouped.values()) {
    keywordOffers.sort((left, right) => left.price - right.price);

    const lowestPrice = keywordOffers[0]?.price ?? 0;
    const bestStoreRating = Math.max(...keywordOffers.map((item) => item.storeRating ?? 0));
    const highestSales = Math.max(...keywordOffers.map((item) => item.salesVolume ?? 0));

    for (const offer of keywordOffers) {
      offer.valueScore = scoreOffer(offer, keywordOffers);
    }

    const bestValueId = [...keywordOffers].sort((left, right) => right.valueScore - left.valueScore)[0]?.id;

    for (const offer of keywordOffers) {
      const labels: string[] = [];

      if (offer.price === lowestPrice) {
        labels.push("Lowest Price");
      }

      if ((offer.storeRating ?? 0) === bestStoreRating && bestStoreRating > 0) {
        labels.push("Best Store Score");
      }

      if ((offer.salesVolume ?? 0) === highestSales && highestSales > 0) {
        labels.push("High Sales");
      }

      if (offer.id === bestValueId) {
        labels.push("Best Value");
      }

      offer.labels = labels;
      enriched.push(offer);
    }
  }

  return enriched.sort((left, right) => left.price - right.price);
}

export function buildRunSummary(offers: NormalizedOffer[]): RunSummary[] {
  const grouped = new Map<string, NormalizedOffer[]>();

  for (const offer of offers) {
    const bucket = grouped.get(offer.keyword) ?? [];
    bucket.push(offer);
    grouped.set(offer.keyword, bucket);
  }

  return Array.from(grouped.entries()).map(([keyword, keywordOffers]) => {
    const sortedPrices = keywordOffers.map((item) => item.price).sort((left, right) => left - right);
    const midpoint = Math.floor(sortedPrices.length / 2);
    const medianPrice = sortedPrices.length % 2 === 0
      ? (sortedPrices[midpoint - 1] + sortedPrices[midpoint]) / 2
      : sortedPrices[midpoint];
    const bestValue = [...keywordOffers].sort((left, right) => right.valueScore - left.valueScore)[0];
    const averagePrice = sortedPrices.reduce((sum, value) => sum + value, 0) / sortedPrices.length;

    return {
      keyword,
      lowestPrice: sortedPrices[0],
      averagePrice: Number(averagePrice.toFixed(2)),
      medianPrice: Number(medianPrice.toFixed(2)),
      offerCount: keywordOffers.length,
      bestValueProduct: bestValue?.productName ?? "N/A",
    };
  });
}
