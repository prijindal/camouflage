// src/server.ts
import { app, shutdown } from "./app";
import { logger } from "@repo/logger";
import { setup } from "./setup";

const port = process.env.PORT || 3000;

const server = app.listen(port, () =>
  logger.info(`Example app listening at http://localhost:${port}`)
);

const close = async () => {
  server.close();
  await shutdown();
  process.exit();
};

setup().catch(close);

process.on("SIGINT", close);
process.on("SIGTERM", close);
