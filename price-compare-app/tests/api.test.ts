import { beforeAll, describe, expect, it } from "vitest";
import request from "supertest";

describe("price comparison API", () => {
  beforeAll(() => {
    process.env.PRICE_COMPARE_DB_PATH = ":memory:";
  });

  it("returns seed metadata and supports crawl execution", async () => {
    const { default: app } = await import("../api/app");

    const seedResponse = await request(app).get("/api/seeds");
    expect(seedResponse.status).toBe(200);
    expect(seedResponse.body.keywords.length).toBeGreaterThan(0);

    const crawlResponse = await request(app)
      .post("/api/crawl")
      .send({
        keywords: ["wireless earbuds", "gaming mouse"],
        providers: ["jd", "taobao", "pinduoduo"],
        mode: "demo",
        limitPerProvider: 2,
      });

    expect(crawlResponse.status).toBe(200);
    expect(crawlResponse.body.success).toBe(true);
    expect(crawlResponse.body.data.offers.length).toBeGreaterThan(0);
  });
});
