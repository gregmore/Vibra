import type { CrawlResult } from "../../shared/types";
import { formatCompactNumber, formatCurrency, formatPercentage, formatTime } from "../lib/format";

interface OfferTableProps {
  result: CrawlResult;
}

const badgeStyleByLabel: Record<string, string> = {
  "Lowest Price": "border-emerald-300/40 bg-emerald-300/15 text-emerald-100",
  "Best Store Score": "border-cyan-300/40 bg-cyan-300/15 text-cyan-100",
  "High Sales": "border-purple-300/40 bg-purple-300/15 text-purple-100",
  "Best Value": "border-amber-300/40 bg-amber-300/15 text-amber-100",
};

export function OfferTable({ result }: OfferTableProps) {
  return (
    <section className="overflow-hidden rounded-[28px] border border-white/10 bg-[#10131f]/90 shadow-[0_20px_60px_rgba(0,0,0,0.35)]">
      <header className="flex flex-wrap items-center justify-between gap-4 border-b border-white/10 px-6 py-5">
        <div>
          <p className="text-xs uppercase tracking-[0.35em] text-[#7f8598]">Horizontal Comparison</p>
          <h3 className="mt-2 font-['Fraunces'] text-2xl text-[#f6efe7]">Price-Sorted Offer Matrix</h3>
        </div>
        <p className="text-xs text-[#7f8598]">Run time: {formatTime(result.finishedAt)}</p>
      </header>

      <div className="overflow-x-auto">
        <table className="min-w-full border-collapse text-sm text-[#d6d9e4]">
          <thead className="bg-white/[0.03]">
            <tr className="text-left text-xs uppercase tracking-[0.25em] text-[#7f8598]">
              <th className="px-4 py-3">Keyword</th>
              <th className="px-4 py-3">Platform</th>
              <th className="px-4 py-3">Product</th>
              <th className="px-4 py-3">Price</th>
              <th className="px-4 py-3">Sales</th>
              <th className="px-4 py-3">Store Rating</th>
              <th className="px-4 py-3">Value Score</th>
              <th className="px-4 py-3">Labels</th>
              <th className="px-4 py-3">Link</th>
            </tr>
          </thead>
          <tbody>
            {result.offers.map((offer) => (
              <tr key={offer.id} className="border-t border-white/5 transition hover:bg-white/[0.03]">
                <td className="px-4 py-4 font-medium text-[#f6efe7]">{offer.keyword}</td>
                <td className="px-4 py-4 capitalize">{offer.provider}</td>
                <td className="max-w-xs px-4 py-4">
                  <p className="line-clamp-2">{offer.productName}</p>
                  {offer.originalPrice && (
                    <p className="mt-1 text-xs text-[#7f8598]">
                      Original: <span className="line-through">{formatCurrency(offer.originalPrice)}</span>
                    </p>
                  )}
                </td>
                <td className="px-4 py-4 font-semibold text-emerald-200">{formatCurrency(offer.price)}</td>
                <td className="px-4 py-4">{formatCompactNumber(offer.salesVolume)}</td>
                <td className="px-4 py-4">{offer.storeRating?.toFixed(1) ?? "N/A"}</td>
                <td className="px-4 py-4">{formatPercentage(offer.valueScore)}</td>
                <td className="px-4 py-4">
                  <div className="flex flex-wrap gap-2">
                    {offer.labels.length === 0 ? (
                      <span className="rounded-full border border-white/10 bg-white/5 px-2 py-1 text-xs">Normal</span>
                    ) : (
                      offer.labels.map((label) => (
                        <span
                          key={`${offer.id}-${label}`}
                          className={`rounded-full border px-2 py-1 text-xs ${badgeStyleByLabel[label] ?? "border-white/10 bg-white/5"}`}
                        >
                          {label}
                        </span>
                      ))
                    )}
                  </div>
                </td>
                <td className="px-4 py-4">
                  <a
                    href={offer.productUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="rounded-full border border-cyan-300/40 bg-cyan-300/10 px-3 py-1 text-xs text-cyan-100 transition hover:bg-cyan-300/20"
                  >
                    Open
                  </a>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
