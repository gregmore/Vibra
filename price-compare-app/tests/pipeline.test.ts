import { describe, expect, it } from "vitest";
import { processOffersForTest } from "../api/services/price-compare-service";
import type { RawOffer } from "../shared/types";

describe("price comparison pipeline", () => {
  it("deduplicates matching offers and assigns recommendation labels", () => {
    const rawOffers: RawOffer[] = [
      {
        keyword: "wireless earbuds",
        provider: "jd",
        productName: "Auralink Wireless Earbuds ENC Edition",
        priceText: "279.00",
        originalPriceText: "349.00",
        salesText: "9100",
        storeName: "JD Digital Flagship",
        storeRatingText: "4.8",
        productUrl: "https://search.jd.com/Search?keyword=wireless%20earbuds",
        scrapedAt: "2026-07-17T09:00:08.000Z",
      },
      {
        keyword: "wireless earbuds",
        provider: "jd",
        productName: "Auralink Wireless Earbuds ENC Edition",
        priceText: "279.00",
        originalPriceText: "349.00",
        salesText: "9100",
        storeName: "JD Digital Flagship",
        storeRatingText: "4.8",
        productUrl: "https://search.jd.com/Search?keyword=wireless%20earbuds",
        scrapedAt: "2026-07-17T09:00:08.000Z",
      },
      {
        keyword: "wireless earbuds",
        provider: "taobao",
        productName: "SoundArc Wireless Earbuds Dual Mic",
        priceText: "259.00",
        originalPriceText: "319.00",
        salesText: "14000",
        storeName: "Taobao Audio Lab",
        storeRatingText: "4.7",
        productUrl: "https://s.taobao.com/search?q=wireless%20earbuds",
        scrapedAt: "2026-07-17T09:00:08.000Z",
      },
    ];

    const offers = processOffersForTest(rawOffers);

    expect(offers).toHaveLength(2);
    expect(offers[0].labels).toContain("Lowest Price");
    expect(offers.some((offer) => offer.labels.includes("Best Value"))).toBe(true);
  });
});
