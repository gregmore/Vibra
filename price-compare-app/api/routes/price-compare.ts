import { Router, type Request, type Response } from "express";
import { providerNames, type CrawlRequest } from "../../shared/types";
import {
  exportLatestRun,
  getHistoryForKeyword,
  getLatestRunResponse,
  getSeedResponse,
  runPriceComparison,
} from "../services/price-compare-service";

const router = Router();

function normalizeKeywordInput(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value
      .map((item) => String(item).trim())
      .filter(Boolean);
  }

  if (typeof value === "string") {
    return value
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);
  }

  return [];
}

function normalizeProviders(value: unknown): CrawlRequest["providers"] {
  const rawProviders = Array.isArray(value) ? value : providerNames;

  return rawProviders
    .map((provider) => String(provider))
    .filter((provider): provider is CrawlRequest["providers"][number] =>
      providerNames.includes(provider as CrawlRequest["providers"][number]))
    .slice(0, providerNames.length);
}

router.get("/seeds", async (_req: Request, res: Response): Promise<void> => {
  const payload = await getSeedResponse();
  res.status(200).json(payload);
});

router.get("/runs/latest", async (_req: Request, res: Response): Promise<void> => {
  const payload = await getLatestRunResponse();
  res.status(200).json(payload);
});

router.get("/runs/history", async (req: Request, res: Response): Promise<void> => {
  const keyword = String(req.query.keyword ?? "").trim();

  if (!keyword) {
    res.status(400).json({
      success: false,
      error: "keyword query parameter is required",
    });
    return;
  }

  res.status(200).json({
    success: true,
    data: await getHistoryForKeyword(keyword),
  });
});

router.post("/crawl", async (req: Request, res: Response): Promise<void> => {
  const keywords = normalizeKeywordInput(req.body.keywords);
  const providers = normalizeProviders(req.body.providers);
  const mode = req.body.mode === "live" ? "live" : "demo";
  const limitPerProvider = Math.min(Math.max(Number(req.body.limitPerProvider ?? 3), 1), 5);

  if (keywords.length === 0) {
    res.status(400).json({
      success: false,
      error: "At least one keyword is required",
    });
    return;
  }

  const payload = await runPriceComparison({
    keywords,
    providers,
    limitPerProvider,
    mode,
  });

  res.status(200).json({
    success: true,
    data: payload,
  });
});

router.get("/export/latest", async (req: Request, res: Response): Promise<void> => {
  const format = req.query.format === "csv" ? "csv" : "json";
  const content = await exportLatestRun(format);

  if (!content) {
    res.status(404).json({
      success: false,
      error: "No run data available",
    });
    return;
  }

  res.setHeader(
    "Content-Type",
    format === "csv" ? "text/csv; charset=utf-8" : "application/json; charset=utf-8",
  );
  res.setHeader("Content-Disposition", `attachment; filename="latest-price-run.${format}"`);
  res.status(200).send(content);
});

export default router;
