// src/server.ts
import "reflect-metadata";
import { WorkflowController } from "./engine/workflowController";

import { logger } from "logger";
import { app } from "./app";
import { TypeOrmConnection } from "./db/typeorm";

import { setup } from "./setup";

import { iocContainer } from "./ioc";

const port = process.env.ENGINE_PORT || 5001;

const server = app.listen(port, async () => {
  logger.info(`Example app listening at http://localhost:${port}`);
  try {
    await setup();
    iocContainer.get(WorkflowController).init().then(console.log).catch(console.error);
  } catch (err) {
    console.error(err);
    onExit({ cleanup: true, exit: true });
  }
});

const onExit = async ({ exit, cleanup }: { exit?: boolean; cleanup?: boolean }) => {
  if (cleanup) {
    console.log("Cleaning up...");
    server.close();
    await shutdown();
  }
  if (exit) {
    console.log("Exitting...");
    process.exit();
  }
};

process.on("exit", () => onExit({ cleanup: true }));
process.on("SIGINT", () => onExit({ exit: true }));
process.on("SIGUSR1", () => onExit({ exit: true }));
process.on("SIGUSR2", () => onExit({ exit: true }));
process.on("uncaughtException", err => {
  logger.error(err);
  onExit({ exit: true });
});

export const shutdown = async () => {
  const db = iocContainer.get(TypeOrmConnection).getInstance();
  try {
    await db?.destroy();
  } catch (err) {
    logger.error(err);
  }
};
