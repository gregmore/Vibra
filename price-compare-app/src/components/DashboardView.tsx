import type { CrawlResult, HistoryPoint } from "../../shared/types";
import { InsightPanel } from "./InsightPanel";
import { OfferTable } from "./OfferTable";
import { SummaryStrip } from "./SummaryStrip";
import { TrendChartCard } from "./TrendChartCard";

interface DashboardViewProps {
  result: CrawlResult;
  history: Record<string, HistoryPoint[]>;
  activeKeyword: string;
  onLoadHistory: (keyword: string) => void;
  onSelectKeyword: (keyword: string) => void;
}

export function DashboardView({
  result,
  history,
  activeKeyword,
  onLoadHistory,
  onSelectKeyword,
}: DashboardViewProps) {
  return (
    <div className="space-y-6">
      <SummaryStrip result={result} />
      <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <OfferTable result={result} />
        <TrendChartCard
          result={result}
          history={history}
          activeKeyword={activeKeyword}
          onLoadHistory={onLoadHistory}
          onSelectKeyword={onSelectKeyword}
        />
      </div>
      <InsightPanel result={result} />
    </div>
  );
}
