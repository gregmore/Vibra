import { useEffect } from "react";
import { Link } from "react-router-dom";
import { ArrowLeft, DatabaseZap } from "lucide-react";
import { DashboardView } from "../components/DashboardView";
import { usePriceCompareStore } from "../store/usePriceCompareStore";

export default function Dashboard() {
  const {
    result,
    history,
    activeKeyword,
    loading,
    bootstrap,
    setActiveKeyword,
    loadHistory,
  } = usePriceCompareStore();

  useEffect(() => {
    if (!result) {
      void bootstrap();
    }
  }, [bootstrap, result]);

  if (loading && !result) {
    return (
      <main className="mx-auto flex min-h-screen max-w-3xl items-center justify-center px-6 text-center text-[#f6efe7]">
        <div className="rounded-[28px] border border-white/10 bg-[#10131f]/90 p-10">
          <p className="font-['Fraunces'] text-3xl">Loading the latest comparison run...</p>
        </div>
      </main>
    );
  }

  if (!result) {
    return (
      <main className="mx-auto flex min-h-screen max-w-3xl items-center justify-center px-6 text-center text-[#f6efe7]">
        <div className="rounded-[28px] border border-white/10 bg-[#10131f]/90 p-10">
          <p className="font-['Fraunces'] text-3xl">No processed run is loaded yet.</p>
          <Link
            to="/"
            className="mt-5 inline-flex rounded-full border border-cyan-300/40 bg-cyan-300/10 px-4 py-2 text-sm text-cyan-100"
          >
            Back to workbench
          </Link>
        </div>
      </main>
    );
  }

  return (
    <main className="mx-auto min-h-screen max-w-[1500px] px-6 py-10 text-[#f6efe7]">
      <header className="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.35em] text-cyan-300/75">Dashboard</p>
          <h1 className="mt-2 font-['Fraunces'] text-4xl">Cross-market analytics canvas</h1>
        </div>
        <div className="flex gap-3">
          <Link
            to="/"
            className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm text-[#d6d9e4]"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to workbench
          </Link>
          <a
            href="/api/export/latest?format=json"
            className="inline-flex items-center gap-2 rounded-full border border-amber-300/40 bg-amber-300/10 px-4 py-2 text-sm text-amber-100"
          >
            <DatabaseZap className="h-4 w-4" />
            Export latest run
          </a>
        </div>
      </header>

      <DashboardView
        result={result}
        history={history}
        activeKeyword={activeKeyword}
        onLoadHistory={loadHistory}
        onSelectKeyword={setActiveKeyword}
      />
    </main>
  );
}
