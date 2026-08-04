import { Search, Settings2, Sparkles } from "lucide-react";
import type { CrawlMode, ProviderName, SeedKeywordPreset } from "../../shared/types";

interface KeywordRunnerProps {
  keywordsInput: string;
  mode: CrawlMode;
  providers: ProviderName[];
  limitPerProvider: number;
  presets: SeedKeywordPreset[];
  loading: boolean;
  onKeywordsChange: (value: string) => void;
  onModeChange: (value: CrawlMode) => void;
  onProviderToggle: (provider: ProviderName) => void;
  onLimitChange: (value: number) => void;
  onApplyPreset: (keyword: string) => void;
  onRun: () => void;
}

const providerLabels: Record<ProviderName, string> = {
  jd: "JD.com",
  taobao: "Taobao",
  pinduoduo: "Pinduoduo",
};

export function KeywordRunner({
  keywordsInput,
  mode,
  providers,
  limitPerProvider,
  presets,
  loading,
  onKeywordsChange,
  onModeChange,
  onProviderToggle,
  onLimitChange,
  onApplyPreset,
  onRun,
}: KeywordRunnerProps) {
  return (
    <section className="rounded-[28px] border border-white/10 bg-[#141726]/90 p-6 shadow-[0_24px_80px_rgba(4,8,20,0.45)] backdrop-blur">
      <div className="flex items-center justify-between gap-4 border-b border-white/10 pb-4">
        <div>
          <p className="text-xs uppercase tracking-[0.4em] text-cyan-300/75">Collector Workbench</p>
          <h2 className="mt-2 font-['Fraunces'] text-2xl text-[#f6efe7]">Run a multi-platform price sweep</h2>
        </div>
        <div className="flex items-center gap-2 rounded-full border border-cyan-400/30 bg-cyan-400/10 px-3 py-1 text-xs text-cyan-100">
          <Sparkles className="h-4 w-4" />
          Seeded examples included
        </div>
      </div>

      <div className="mt-6 grid gap-5 xl:grid-cols-[1.4fr_0.9fr]">
        <label className="space-y-3">
          <span className="text-sm font-medium text-[#d8d0c6]">Keywords</span>
          <textarea
            value={keywordsInput}
            onChange={(event) => onKeywordsChange(event.target.value)}
            className="min-h-52 w-full rounded-[24px] border border-white/10 bg-[#0e101a] px-4 py-4 text-sm text-white outline-none transition focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-400/20"
            placeholder="Enter one keyword per line"
          />
          <p className="text-xs text-[#8a8e9f]">Use one product keyword per line. The script cleans and compares all returned offers.</p>
        </label>

        <div className="space-y-5">
          <div className="rounded-[24px] border border-white/10 bg-[#0e101a] p-4">
            <div className="flex items-center gap-2 text-sm font-medium text-[#f6efe7]">
              <Settings2 className="h-4 w-4 text-cyan-300" />
              Run settings
            </div>

            <div className="mt-4 space-y-4">
              <div>
                <p className="text-xs uppercase tracking-[0.3em] text-[#7e8498]">Mode</p>
                <div className="mt-2 grid grid-cols-2 gap-2">
                  {(["demo", "live"] as CrawlMode[]).map((item) => (
                    <button
                      key={item}
                      type="button"
                      onClick={() => onModeChange(item)}
                      className={`rounded-2xl border px-3 py-3 text-sm transition ${
                        mode === item
                          ? "border-cyan-400/50 bg-cyan-400/15 text-cyan-100"
                          : "border-white/10 bg-white/5 text-[#c5c9d7] hover:border-white/20 hover:bg-white/10"
                      }`}
                    >
                      {item === "demo" ? "Demo data mode" : "Live adapter mode"}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <p className="text-xs uppercase tracking-[0.3em] text-[#7e8498]">Platforms</p>
                <div className="mt-2 flex flex-wrap gap-2">
                  {(Object.keys(providerLabels) as ProviderName[]).map((provider) => (
                    <button
                      key={provider}
                      type="button"
                      onClick={() => onProviderToggle(provider)}
                      className={`rounded-full border px-3 py-2 text-sm transition ${
                        providers.includes(provider)
                          ? "border-amber-300/50 bg-amber-300/15 text-amber-100"
                          : "border-white/10 bg-white/5 text-[#c5c9d7] hover:border-white/20"
                      }`}
                    >
                      {providerLabels[provider]}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between text-xs uppercase tracking-[0.3em] text-[#7e8498]">
                  <span>Result limit</span>
                  <span>{limitPerProvider}</span>
                </div>
                <input
                  type="range"
                  min={1}
                  max={5}
                  value={limitPerProvider}
                  onChange={(event) => onLimitChange(Number(event.target.value))}
                  className="mt-2 h-2 w-full cursor-pointer appearance-none rounded-full bg-white/10"
                />
              </div>
            </div>
          </div>

          <div className="rounded-[24px] border border-white/10 bg-[#0e101a] p-4">
            <p className="text-xs uppercase tracking-[0.3em] text-[#7e8498]">Sample inputs</p>
            <div className="mt-3 flex flex-wrap gap-2">
              {presets.map((preset) => (
                <button
                  key={preset.keyword}
                  type="button"
                  onClick={() => onApplyPreset(preset.keyword)}
                  className="rounded-full border border-white/10 bg-white/5 px-3 py-2 text-sm text-[#f6efe7] transition hover:border-cyan-400/40 hover:bg-cyan-400/10"
                  title={preset.note}
                >
                  {preset.keyword}
                </button>
              ))}
            </div>
          </div>

          <button
            type="button"
            onClick={onRun}
            disabled={loading}
            className="flex w-full items-center justify-center gap-3 rounded-[22px] bg-gradient-to-r from-cyan-400 to-amber-300 px-5 py-4 text-sm font-semibold text-[#111523] transition hover:scale-[1.01] disabled:cursor-not-allowed disabled:opacity-70"
          >
            <Search className="h-4 w-4" />
            {loading ? "Running comparison..." : "Run collection and comparison"}
          </button>
        </div>
      </div>
    </section>
  );
}
