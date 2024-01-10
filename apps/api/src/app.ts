// src/app.ts
import bodyParser from "body-parser";
import cors from "cors";
import express, { Request as ExRequest, Response as ExResponse, NextFunction } from "express";
import promBundle from "express-prom-bundle";
import * as swaggerUi from "swagger-ui-express";
import { ValidateError } from "tsoa";

import { JsonWebTokenError } from "jsonwebtoken";
import { RegisterRoutes } from "./build/routes";
import swaggerDocument from "./build/swagger.json";
import { CustomError } from "./errors/error";
import { log } from "console";
import { iocContainer } from "./ioc";
import { TypeOrmConnection } from "./db/typeorm";

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

app.use("/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use("/swagger.json", (_, res) => res.send(swaggerDocument));

app.use(metricsMiddleware);

RegisterRoutes(app);

app.use(function errorHandler(
  err: unknown,
  req: ExRequest,
  res: ExResponse,
  next: NextFunction
): ExResponse | void {
  if (err instanceof ValidateError) {
    log(`Caught Validation Error for ${req.path}:`, err.fields);
    return res.status(422).json({
      message: "Validation Failed",
      details: err?.fields,
    });
  } else if (err instanceof JsonWebTokenError) {
    log(`Caught ${err.name} for ${req.path}:`, err.message);
    return res.status(422).json({
      message: err.name,
      details: err?.message,
    });
  } else if (err instanceof CustomError) {
    log(err);
    return res.status(err.status_code).json({ ...err, details: undefined });
  } else if (err instanceof Error) {
    log(err);
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
    log(err);
  }
};
