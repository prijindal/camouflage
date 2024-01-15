// src/app.ts
import bodyParser from "body-parser";
import cors from "cors";
import express, { Request as ExRequest, Response as ExResponse, NextFunction } from "express";
import promBundle from "express-prom-bundle";
import * as swaggerUi from "swagger-ui-express";
import { ValidateError } from "tsoa";

import { logger } from "@repo/logger";
import { JsonWebTokenError } from "jsonwebtoken";
import { RegisterRoutes } from "./build/routes";
import swaggerDocument from "./build/swagger.json";
import { TypeOrmConnection } from "./db/typeorm";
import { CustomError } from "./errors/error";
import { iocContainer } from "./ioc";

export const app = express();
const metricsMiddleware = promBundle({
  includeMethod: true,
  includePath: true,
  includeStatusCode: true,
  includeUp: true,
  customLabels: {
    project_name: "orchestrator-engine",
  },
  promClient: {
    collectDefaultMetrics: {},
  },
});

const UI_BUILD_PATH = process.env.UI_BUILD_PATH || "ui";

app.use(cors());
app.use(express.static(UI_BUILD_PATH));
app.use(bodyParser.json({ limit: "100mb" }));

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use("/api/swagger.json", (_, res) => res.send(swaggerDocument));

app.use(metricsMiddleware);

RegisterRoutes(app);

app.use(function errorHandler(
  err: unknown,
  req: ExRequest,
  res: ExResponse,
  next: NextFunction
): ExResponse | void {
  if (err instanceof ValidateError) {
    logger.error(`Caught Validation Error for ${req.path}:`, err.fields);
    return res.status(422).json({
      message: "Validation Failed",
      details: err?.fields,
    });
  } else if (err instanceof JsonWebTokenError) {
    logger.error(`Caught ${err.name} for ${req.path}:`, err.message);
    return res.status(422).json({
      message: err.name,
      details: err?.message,
    });
  } else if (err instanceof CustomError) {
    logger.error(err);
    return res.status(err.status_code).json({ ...err, details: undefined });
  } else if (err instanceof Error) {
    logger.error(err);
    return res.status(500).json({
      message: "Internal Server Error",
    });
  }

  next();
});

export const shutdown = async () => {
  const db = iocContainer.get(TypeOrmConnection).getInstance();
  try {
    await db?.destroy();
  } catch (err) {
    logger.error(err);
  }
};
