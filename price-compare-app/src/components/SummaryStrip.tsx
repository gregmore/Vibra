import { BadgeDollarSign, BarChart3, Gem, Layers3 } from "lucide-react";
import type { CrawlResult } from "../../shared/types";
import { formatCurrency } from "../lib/format";

interface SummaryStripProps {
  result: CrawlResult;
}

export function SummaryStrip({ result }: SummaryStripProps) {
  const allPrices = result.offers.map((offer) => offer.price);
  const lowestPrice = Math.min(...allPrices);
  const averagePrice = allPrices.reduce((sum, value) => sum + value, 0) / allPrices.length;
  const bestValue = [...result.offers].sort((left, right) => right.valueScore - left.valueScore)[0];

  const stats = [
    {
      icon: BadgeDollarSign,
      label: "Lowest price",
      value: formatCurrency(lowestPrice),
    },
    {
      icon: Layers3,
      label: "Offers analyzed",
      value: `${result.offers.length}`,
    },
    {
      icon: BarChart3,
      label: "Average price",
      value: formatCurrency(averagePrice),
    },
    {
      icon: Gem,
      label: "Best value pick",
      value: bestValue?.productName ?? "N/A",
    },
  ];

  return (
    <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      {stats.map((stat) => (
        <article
          key={stat.label}
          className="rounded-[24px] border border-white/10 bg-white/[0.04] p-5 shadow-[0_16px_40px_rgba(2,6,23,0.25)]"
        >
          <div className="flex items-center gap-3">
            <div className="rounded-2xl bg-cyan-400/10 p-3 text-cyan-200">
              <stat.icon className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs uppercase tracking-[0.3em] text-[#7f8598]">{stat.label}</p>
              <p className="mt-2 font-['Fraunces'] text-xl text-[#f6efe7]">{stat.value}</p>
            </div>
          </div>
        </article>
      ))}
    </section>
  );
}
