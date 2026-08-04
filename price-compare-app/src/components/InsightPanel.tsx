import { AlertTriangle, Download, Sparkle, TerminalSquare } from "lucide-react";
import type { CrawlResult } from "../../shared/types";

interface InsightPanelProps {
  result: CrawlResult;
}

export function InsightPanel({ result }: InsightPanelProps) {
  const liveModeWarning = result.mode === "live"
    ? "Live mode currently runs through pluggable fallback collectors. Replace them with legal site-specific adapters or official APIs before production use."
    : "Demo mode reads bundled sample snapshots so the dashboard works instantly after initialization.";

  return (
    <section className="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
      <article className="rounded-[28px] border border-white/10 bg-[#10131f]/90 p-6 shadow-[0_20px_60px_rgba(0,0,0,0.35)]">
        <div className="flex items-center gap-3">
          <div className="rounded-2xl bg-amber-300/15 p-3 text-amber-100">
            <Sparkle className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs uppercase tracking-[0.35em] text-[#7f8598]">Recommendation Logic</p>
            <h3 className="mt-2 font-['Fraunces'] text-2xl text-[#f6efe7]">How value-for-money is scored</h3>
          </div>
        </div>

        <div className="mt-5 grid gap-4 md:grid-cols-2">
          <div className="rounded-[22px] border border-white/10 bg-white/[0.03] p-4">
            <p className="text-xs uppercase tracking-[0.25em] text-[#7f8598]">Scoring factors</p>
            <p className="mt-3 text-sm leading-7 text-[#d6d9e4]">
              The value score weights price rank at 50%, sales confidence at 20%, store quality at 20%, and discount depth at 10%.
            </p>
          </div>
          <div className="rounded-[22px] border border-white/10 bg-white/[0.03] p-4">
            <p className="text-xs uppercase tracking-[0.25em] text-[#7f8598]">Labels added automatically</p>
            <p className="mt-3 text-sm leading-7 text-[#d6d9e4]">
              The pipeline marks lowest price, best store score, high sales, and the top-scoring best-value row inside every keyword group.
            </p>
          </div>
        </div>
      </article>

      <article className="space-y-4 rounded-[28px] border border-white/10 bg-[#10131f]/90 p-6 shadow-[0_20px_60px_rgba(0,0,0,0.35)]">
        <div className="flex items-center gap-3">
          <div className="rounded-2xl bg-cyan-300/15 p-3 text-cyan-100">
            <TerminalSquare className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs uppercase tracking-[0.35em] text-[#7f8598]">Operator Notes</p>
            <h3 className="mt-2 font-['Fraunces'] text-2xl text-[#f6efe7]">Run outputs and caveats</h3>
          </div>
        </div>

        <div className="rounded-[22px] border border-white/10 bg-white/[0.03] p-4 text-sm leading-7 text-[#d6d9e4]">
          <p>{liveModeWarning}</p>
        </div>

        {result.warnings.length > 0 && (
          <div className="rounded-[22px] border border-amber-300/20 bg-amber-300/10 p-4 text-sm text-amber-50">
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-4 w-4" />
              Pipeline warnings
            </div>
            <ul className="mt-3 space-y-2 text-xs leading-6 text-amber-100/90">
              {result.warnings.map((warning) => (
                <li key={warning}>{warning}</li>
              ))}
            </ul>
          </div>
        )}

        <div className="rounded-[22px] border border-white/10 bg-white/[0.03] p-4 text-sm text-[#d6d9e4]">
          <div className="flex items-center gap-2">
            <Download className="h-4 w-4 text-cyan-200" />
            Export latest run
          </div>
          <div className="mt-4 flex gap-3">
            <a
              href="/api/export/latest?format=json"
              className="rounded-full border border-cyan-300/40 bg-cyan-300/10 px-3 py-2 text-xs text-cyan-100 transition hover:bg-cyan-300/20"
            >
              Download JSON
            </a>
            <a
              href="/api/export/latest?format=csv"
              className="rounded-full border border-amber-300/40 bg-amber-300/10 px-3 py-2 text-xs text-amber-100 transition hover:bg-amber-300/20"
            >
              Download CSV
            </a>
          </div>
        </div>
      </article>
    </section>
  );
}
