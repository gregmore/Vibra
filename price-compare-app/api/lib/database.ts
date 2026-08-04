import fs from "node:fs/promises";
import path from "node:path";
import sqlite3 from "sqlite3";
import { open, type Database } from "sqlite";
import type { CrawlMode, NormalizedOffer, ProviderName } from "../../shared/types";

interface RunRow {
  id: string;
  mode: CrawlMode;
  started_at: string;
  finished_at: string;
  keywords_json: string;
  providers_json: string;
}

interface OfferRow {
  id: string;
  run_id: string;
  keyword: string;
  provider: ProviderName;
  product_name: string;
  normalized_title: string;
  price: number;
  original_price: number | null;
  sales_volume: number | null;
  store_name: string | null;
  store_rating: number | null;
  product_url: string;
  thumbnail_url: string | null;
  fingerprint: string;
  value_score: number;
  labels_json: string;
  scraped_at: string;
}

let databasePromise: Promise<Database> | null = null;

function resolveDatabasePath(): string {
  return process.env.PRICE_COMPARE_DB_PATH
    ?? path.join(process.cwd(), "data", "runtime", "price-compare.sqlite");
}

export async function getDatabase(): Promise<Database> {
  if (!databasePromise) {
    databasePromise = (async () => {
      const databasePath = resolveDatabasePath();

      if (databasePath !== ":memory:") {
        await fs.mkdir(path.dirname(databasePath), { recursive: true });
      }

      const database = await open({
        filename: databasePath,
        driver: sqlite3.Database,
      });

      await database.exec(`
        CREATE TABLE IF NOT EXISTS crawl_runs (
          id TEXT PRIMARY KEY,
          mode TEXT NOT NULL,
          started_at TEXT NOT NULL,
          finished_at TEXT NOT NULL,
          keywords_json TEXT NOT NULL,
          providers_json TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS offer_snapshots (
          id TEXT PRIMARY KEY,
          run_id TEXT NOT NULL REFERENCES crawl_runs(id),
          keyword TEXT NOT NULL,
          provider TEXT NOT NULL,
          product_name TEXT NOT NULL,
          normalized_title TEXT NOT NULL,
          price REAL NOT NULL,
          original_price REAL,
          sales_volume INTEGER,
          store_name TEXT,
          store_rating REAL,
          product_url TEXT NOT NULL,
          thumbnail_url TEXT,
          fingerprint TEXT NOT NULL,
          value_score REAL NOT NULL,
          labels_json TEXT NOT NULL,
          scraped_at TEXT NOT NULL
        );

        CREATE INDEX IF NOT EXISTS idx_offer_snapshots_keyword_price
          ON offer_snapshots(keyword, price);

        CREATE INDEX IF NOT EXISTS idx_offer_snapshots_keyword_scraped_at
          ON offer_snapshots(keyword, scraped_at);
      `);

      return database;
    })();
  }

  return databasePromise;
}

export async function countRuns(): Promise<number> {
  const database = await getDatabase();
  const result = await database.get<{ count: number }>("SELECT COUNT(*) AS count FROM crawl_runs");
  return result?.count ?? 0;
}

export async function insertRun(input: {
  runId: string;
  mode: CrawlMode;
  startedAt: string;
  finishedAt: string;
  keywords: string[];
  providers: ProviderName[];
  offers: NormalizedOffer[];
}): Promise<void> {
  const database = await getDatabase();

  await database.run(
    `INSERT INTO crawl_runs (id, mode, started_at, finished_at, keywords_json, providers_json)
     VALUES (?, ?, ?, ?, ?, ?)`,
    input.runId,
    input.mode,
    input.startedAt,
    input.finishedAt,
    JSON.stringify(input.keywords),
    JSON.stringify(input.providers),
  );

  for (const offer of input.offers) {
    await database.run(
      `INSERT INTO offer_snapshots (
        id, run_id, keyword, provider, product_name, normalized_title, price, original_price,
        sales_volume, store_name, store_rating, product_url, thumbnail_url, fingerprint,
        value_score, labels_json, scraped_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      offer.id,
      input.runId,
      offer.keyword,
      offer.provider,
      offer.productName,
      offer.normalizedTitle,
      offer.price,
      offer.originalPrice ?? null,
      offer.salesVolume ?? null,
      offer.storeName ?? null,
      offer.storeRating ?? null,
      offer.productUrl,
      offer.thumbnailUrl ?? null,
      offer.fingerprint,
      offer.valueScore,
      JSON.stringify(offer.labels),
      offer.scrapedAt,
    );
  }
}

export async function getLatestRunRow(): Promise<RunRow | null> {
  const database = await getDatabase();
  const row = await database.get<RunRow>(
    "SELECT * FROM crawl_runs ORDER BY finished_at DESC LIMIT 1",
  );
  return row ?? null;
}

export async function getRunOffers(runId: string): Promise<NormalizedOffer[]> {
  const database = await getDatabase();
  const rows = await database.all<OfferRow[]>(
    "SELECT * FROM offer_snapshots WHERE run_id = ? ORDER BY price ASC",
    runId,
  );

  return rows.map((row) => ({
    id: row.id,
    keyword: row.keyword,
    provider: row.provider,
    productName: row.product_name,
    normalizedTitle: row.normalized_title,
    price: row.price,
    originalPrice: row.original_price ?? undefined,
    salesVolume: row.sales_volume ?? undefined,
    storeName: row.store_name ?? undefined,
    storeRating: row.store_rating ?? undefined,
    productUrl: row.product_url,
    thumbnailUrl: row.thumbnail_url ?? undefined,
    scrapedAt: row.scraped_at,
    fingerprint: row.fingerprint,
    labels: JSON.parse(row.labels_json),
    valueScore: row.value_score,
  }));
}

export async function getKeywordOffers(keyword: string): Promise<Array<NormalizedOffer & { runId: string }>> {
  const database = await getDatabase();
  const rows = await database.all<Array<OfferRow & { finished_at: string }>>(
    `SELECT offer_snapshots.*, crawl_runs.finished_at
     FROM offer_snapshots
     JOIN crawl_runs ON crawl_runs.id = offer_snapshots.run_id
     WHERE keyword = ?
     ORDER BY crawl_runs.finished_at ASC, price ASC`,
    keyword,
  );

  return rows.map((row) => ({
    id: row.id,
    runId: row.run_id,
    keyword: row.keyword,
    provider: row.provider,
    productName: row.product_name,
    normalizedTitle: row.normalized_title,
    price: row.price,
    originalPrice: row.original_price ?? undefined,
    salesVolume: row.sales_volume ?? undefined,
    storeName: row.store_name ?? undefined,
    storeRating: row.store_rating ?? undefined,
    productUrl: row.product_url,
    thumbnailUrl: row.thumbnail_url ?? undefined,
    scrapedAt: row.scraped_at,
    fingerprint: row.fingerprint,
    labels: JSON.parse(row.labels_json),
    valueScore: row.value_score,
  }));
}

export async function getRunMetadata(runId: string): Promise<RunRow | null> {
  const database = await getDatabase();
  const row = await database.get<RunRow>("SELECT * FROM crawl_runs WHERE id = ?", runId);
  return row ?? null;
}
