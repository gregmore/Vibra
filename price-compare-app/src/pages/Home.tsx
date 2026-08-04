import { useEffect } from "react";
import { Link } from "react-router-dom";
import { Activity, ArrowRight, Orbit, ShieldAlert } from "lucide-react";
import { DashboardView } from "../components/DashboardView";
import { KeywordRunner } from "../components/KeywordRunner";
import { usePriceCompareStore } from "../store/usePriceCompareStore";

export default function Home() {
  const {
    presets,
    result,
    history,
    loading,
    error,
    mode,
    activeKeyword,
    keywordsInput,
    providers,
    limitPerProvider,
    bootstrap,
    setKeywordsInput,
    setMode,
    setActiveKeyword,
    toggleProvider,
    setLimitPerProvider,
    applyPreset,
    runCrawl,
    loadHistory,
  } = usePriceCompareStore();

  useEffect(() => {
    void bootstrap();
  }, [bootstrap]);

  return (
    <main className="mx-auto min-h-screen max-w-[1500px] px-6 py-10 text-[#f6efe7]">
      <section className="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
        <article className="rounded-[32px] border border-white/10 bg-[radial-gradient(circle_at_top_left,rgba(34,211,238,0.18),transparent_34%),radial-gradient(circle_at_bottom_right,rgba(251,191,36,0.16),transparent_28%),rgba(16,19,31,0.92)] p-8 shadow-[0_30px_100px_rgba(0,0,0,0.45)]">
          <div className="inline-flex items-center gap-2 rounded-full border border-cyan-300/30 bg-cyan-300/10 px-3 py-1 text-xs uppercase tracking-[0.3em] text-cyan-100">
            <Orbit className="h-4 w-4" />
            E-commerce price intelligence
          </div>
          <h1 className="mt-6 max-w-3xl font-['Fraunces'] text-5xl leading-tight text-[#f8f3ec]">
            Compare marketplace prices with a collector, sorter, and trend dashboard in one toolchain.
          </h1>
          <p className="mt-5 max-w-2xl text-base leading-8 text-[#d6d9e4]">
            Run keyword-based collection across JD.com, Taobao, and Pinduoduo, normalize the results, remove duplicates,
            rank by price, surface value-for-money picks, and inspect the output through a seeded CLI and web demo.
          </p>

          <div className="mt-8 grid gap-4 md:grid-cols-3">
            <div className="rounded-[24px] border border-white/10 bg-white/[0.04] p-4">
              <Activity className="h-5 w-5 text-cyan-200" />
              <p className="mt-3 text-xs uppercase tracking-[0.3em] text-[#7f8598]">Current mode</p>
              <p className="mt-2 text-sm text-[#f6efe7]">{mode === "demo" ? "Seeded sample run" : "Live adapter run"}</p>
            </div>
            <div className="rounded-[24px] border border-white/10 bg-white/[0.04] p-4">
              <ShieldAlert className="h-5 w-5 text-amber-200" />
              <p className="mt-3 text-xs uppercase tracking-[0.3em] text-[#7f8598]">Safety note</p>
              <p className="mt-2 text-sm text-[#f6efe7]">Adapter boundaries make it easy to swap in legal APIs or compliant collectors.</p>
            </div>
            <div className="rounded-[24px] border border-white/10 bg-white/[0.04] p-4">
              <ArrowRight className="h-5 w-5 text-emerald-200" />
              <p className="mt-3 text-xs uppercase tracking-[0.3em] text-[#7f8598]">Next step</p>
              <Link to="/dashboard" className="mt-2 inline-flex text-sm text-[#f6efe7] underline decoration-cyan-300/50 underline-offset-4">
                Open full dashboard
              </Link>
            </div>
          </div>
        </article>

        <KeywordRunner
          keywordsInput={keywordsInput}
          mode={mode}
          providers={providers}
          limitPerProvider={limitPerProvider}
          presets={presets}
          loading={loading}
          onKeywordsChange={setKeywordsInput}
          onModeChange={setMode}
          onProviderToggle={toggleProvider}
          onLimitChange={setLimitPerProvider}
          onApplyPreset={applyPreset}
          onRun={() => void runCrawl()}
        />
      </section>

      {error && (
        <div className="mt-6 rounded-[24px] border border-rose-300/30 bg-rose-300/10 px-5 py-4 text-sm text-rose-100">
          {error}
        </div>
      )}

      {result && (
        <section className="mt-8 space-y-6">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-xs uppercase tracking-[0.35em] text-[#7f8598]">Latest output</p>
              <h2 className="mt-2 font-['Fraunces'] text-3xl text-[#f6efe7]">Processed comparison results</h2>
            </div>
            <Link
              to="/dashboard"
              className="rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm text-[#d6d9e4] transition hover:border-cyan-300/30 hover:bg-cyan-300/10 hover:text-cyan-100"
            >
              Open dedicated dashboard
            </Link>
          </div>

          <DashboardView
            result={result}
            history={history}
            activeKeyword={activeKeyword}
            onLoadHistory={(keyword) => void loadHistory(keyword)}
            onSelectKeyword={setActiveKeyword}
          />
        </section>
      )}
    </main>
  );
}
