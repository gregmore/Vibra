# Price Compare App

A standalone full-stack subproject for collecting, normalizing, and comparing e-commerce prices across JD.com, Taobao, and Pinduoduo.

## What It Includes

- A React dashboard for keyword entry, live run triggering, seeded demo data, comparison tables, and price trend charts
- An Express API for crawl execution, history retrieval, sample data bootstrapping, and export endpoints
- A CLI entrypoint that runs the exact same comparison pipeline from the terminal
- A bundled sample dataset so the project works immediately after setup
- Pluggable provider adapters for `demo` mode and `live` adapter fallback mode

## Project Structure

- `src/`: frontend pages, components, state, and chart UI
- `api/`: Express routes, CLI entrypoint, crawler adapters, and persistence services
- `shared/`: types plus normalization and scoring helpers shared by frontend and backend
- `data/seeds/`: bundled sample datasets and historical snapshots
- `tests/`: pipeline and API tests

## Run Locally

```bash
npm install
npm run dev
```

Frontend runs on `http://localhost:5173` and the API runs on `http://localhost:3001`.

## Useful Commands

```bash
npm run cli
npm run demo
npm run check
npm run lint
npm run test
npm run build
```

## CLI Examples

```bash
npm run cli -- --mode demo --keywords "wireless earbuds,gaming mouse"
npm run cli -- --mode live --keywords "portable power bank" --providers "jd,taobao,pinduoduo"
```

## API Endpoints

- `POST /api/crawl`
- `GET /api/seeds`
- `GET /api/runs/latest`
- `GET /api/runs/history?keyword=wireless%20earbuds`
- `GET /api/export/latest?format=json`
- `GET /api/export/latest?format=csv`

## Notes On Live Collection

- `demo` mode is fully functional and uses bundled cross-platform sample data
- `live` mode uses the same pipeline but currently relies on adapter fallbacks and search URLs instead of production scraping logic
- For real deployments, replace the fallback collectors with legal site-specific adapters, official APIs, or browser automation that respects platform policies
