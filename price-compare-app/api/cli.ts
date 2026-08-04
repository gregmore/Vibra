import { Command } from "commander";
import type { ProviderName } from "../shared/types";
import { providerNames } from "../shared/types";
import { initializePriceCompareService, runPriceComparison } from "./services/price-compare-service.js";

function formatCurrency(value: number): string {
  return `¥${value.toFixed(2)}`;
}

function pad(value: string, width: number): string {
  return value.length >= width ? `${value.slice(0, width - 1)}…` : value.padEnd(width, " ");
}

function printResultTable(): (offer: Awaited<ReturnType<typeof runPriceComparison>>["offers"][number]) => void {
  const widths = {
    provider: 10,
    keyword: 22,
    product: 34,
    price: 10,
    sales: 10,
    rating: 8,
    labels: 28,
  };

  console.log(
    [
      pad("Provider", widths.provider),
      pad("Keyword", widths.keyword),
      pad("Product", widths.product),
      pad("Price", widths.price),
      pad("Sales", widths.sales),
      pad("Rating", widths.rating),
      pad("Labels", widths.labels),
    ].join(" | "),
  );
  console.log("-".repeat(136));

  return (offer) => {
    console.log(
      [
        pad(offer.provider, widths.provider),
        pad(offer.keyword, widths.keyword),
        pad(offer.productName, widths.product),
        pad(formatCurrency(offer.price), widths.price),
        pad(String(offer.salesVolume ?? "-"), widths.sales),
        pad(String(offer.storeRating ?? "-"), widths.rating),
        pad(offer.labels.join(", ") || "-", widths.labels),
      ].join(" | "),
    );
  };
}

async function main(): Promise<void> {
  const program = new Command();

  program
    .name("price-compare")
    .description("Collect, normalize, and compare e-commerce product prices")
    .option("--keywords <value>", "Comma-separated keywords", "wireless earbuds,gaming mouse")
    .option("--mode <value>", "demo or live mode", "demo")
    .option("--providers <value>", "Comma-separated providers", providerNames.join(","))
    .option("--limit <value>", "Max results per provider", "3");

  program.parse(process.argv);

  const options = program.opts<{
    keywords: string;
    mode: "demo" | "live";
    providers: string;
    limit: string;
  }>();

  const keywords = options.keywords.split(",").map((value) => value.trim()).filter(Boolean);
  const providers = options.providers
    .split(",")
    .map((value) => value.trim())
    .filter((value): value is ProviderName => providerNames.includes(value as ProviderName));
  const limitPerProvider = Math.min(Math.max(Number(options.limit), 1), 5);
  const mode = options.mode === "live" ? "live" : "demo";

  await initializePriceCompareService();

  const result = await runPriceComparison({
    keywords,
    providers,
    limitPerProvider,
    mode,
  });

  console.log(`\nRun ID: ${result.runId}`);
  console.log(`Mode: ${result.mode}`);
  console.log(`Keywords: ${result.keywords.join(", ")}`);
  console.log(`Providers: ${result.providers.join(", ")}`);
  console.log(`Started: ${result.startedAt}`);
  console.log(`Finished: ${result.finishedAt}\n`);

  const writeRow = printResultTable();
  result.offers.forEach(writeRow);

  console.log("\nSummary:");
  result.summary.forEach((summary) => {
    console.log(
      `- ${summary.keyword}: lowest ${formatCurrency(summary.lowestPrice)}, `
      + `average ${formatCurrency(summary.averagePrice)}, best value "${summary.bestValueProduct}"`,
    );
  });

  if (result.warnings.length > 0) {
    console.log("\nWarnings:");
    result.warnings.forEach((warning) => console.log(`- ${warning}`));
  }
}

void main();
