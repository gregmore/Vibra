import { useMemo } from "react";
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import type { CrawlResult, HistoryPoint } from "../../shared/types";
import { formatCurrency } from "../lib/format";

interface TrendChartCardProps {
  result: CrawlResult;
  history: Record<string, HistoryPoint[]>;
  activeKeyword: string;
  onLoadHistory: (keyword: string) => void;
  onSelectKeyword: (keyword: string) => void;
}

export function TrendChartCard({
  result,
  history,
  activeKeyword,
  onLoadHistory,
  onSelectKeyword,
}: TrendChartCardProps) {
  const chartKeyword = activeKeyword || result.summary[0]?.keyword || "";

  const chartData = useMemo(() => {
    const points = history[chartKeyword] ?? result.historyPreview.filter((item) => item.keyword === chartKeyword);
    return points.map((point) => ({
      capturedAt: new Date(point.capturedAt).toLocaleDateString(),
      minPrice: point.minPrice,
      averagePrice: point.averagePrice,
      medianPrice: point.medianPrice,
    }));
  }, [chartKeyword, history, result.historyPreview]);

  return (
    <section className="rounded-[28px] border border-white/10 bg-[#10131f]/90 p-6 shadow-[0_20px_60px_rgba(0,0,0,0.35)]">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.35em] text-[#7f8598]">Trend View</p>
          <h3 className="mt-2 font-['Fraunces'] text-2xl text-[#f6efe7]">Historical price movement</h3>
        </div>
        <div className="flex flex-wrap gap-2">
          {result.summary.map((summary) => (
            <button
              key={summary.keyword}
              type="button"
              onClick={() => {
                onSelectKeyword(summary.keyword);
                onLoadHistory(summary.keyword);
              }}
              className={`rounded-full border px-3 py-2 text-xs transition ${
                chartKeyword === summary.keyword
                  ? "border-cyan-300/50 bg-cyan-300/15 text-cyan-100"
                  : "border-white/10 bg-white/5 text-[#d6d9e4] hover:border-white/20"
              }`}
            >
              {summary.keyword}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-6 h-72">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={chartData}>
            <XAxis dataKey="capturedAt" stroke="#7f8598" />
            <YAxis stroke="#7f8598" />
            <Tooltip
              formatter={(value: number) => formatCurrency(value)}
              contentStyle={{
                backgroundColor: "#111523",
                borderRadius: "16px",
                border: "1px solid rgba(255,255,255,0.1)",
              }}
            />
            <Line type="monotone" dataKey="minPrice" stroke="#2dd4bf" strokeWidth={3} dot={{ r: 4 }} />
            <Line type="monotone" dataKey="averagePrice" stroke="#fbbf24" strokeWidth={3} dot={{ r: 4 }} />
            <Line type="monotone" dataKey="medianPrice" stroke="#c084fc" strokeWidth={3} dot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </section>
  );
}
