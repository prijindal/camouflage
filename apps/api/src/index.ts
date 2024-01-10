// src/server.ts
import { logger } from "@repo/logger";
import http from "http";
import SocketIO from "socket.io";
import { app, shutdown } from "./app";
import { setup } from "./setup";

const port = process.env.PORT || 3000;

const server = http.createServer(app);
const io = new SocketIO.Server(server);

const listener = server.listen(port, () =>
  logger.info(`Example app listening at http://localhost:${port}`)
);

io.on("connection", socket => {
  logger.info("A user connected");
});

const close = async () => {
  listener.close();
  server.close();
  await shutdown();
  process.exit();
};

setup().catch(close);

process.on("SIGINT", close);
process.on("SIGTERM", close);
