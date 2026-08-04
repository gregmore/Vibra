import app from "./app.js";
import { initializePriceCompareService } from "./services/price-compare-service.js";

const PORT = Number(process.env.PORT ?? 3001);

async function startServer(): Promise<void> {
  await initializePriceCompareService();

  const server = app.listen(PORT, () => {
    console.log(`Server ready on port ${PORT}`);
  });

  const shutdown = () => {
    server.close(() => {
      console.log("Server closed");
      process.exit(0);
    });
  };

  process.on("SIGTERM", shutdown);
  process.on("SIGINT", shutdown);
}

void startServer();
