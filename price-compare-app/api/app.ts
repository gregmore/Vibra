import express, { type NextFunction, type Request, type Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import priceCompareRoutes from "./routes/price-compare.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

app.get("/api/health", (_req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: "ok",
  });
});

app.use("/api", priceCompareRoutes);

app.use((error: Error, _req: Request, res: Response, next: NextFunction) => {
  void next;
  res.status(500).json({
    success: false,
    error: error.message || "Server internal error",
  });
});

app.use((_req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: "API not found",
  });
});

export default app;
