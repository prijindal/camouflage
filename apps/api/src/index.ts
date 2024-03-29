// src/server.ts
import { logger } from "@repo/logger";
import http from "http";
import SocketIO from "socket.io";
// SocketService must be imported before app
import { SocketService } from "./service/socket.service";

import { app, shutdown } from "./app";

import { iocContainer } from "./ioc";
import { setup } from "./setup";

const port = Number(process.env.PORT || "3000");
const hostname = process.env.HOSTNAME || "0.0.0.0";

const server = http.createServer(app);
const io = new SocketIO.Server(server);

const listener = server.listen(port, hostname, 0, () =>
  logger.info(`Example app listening at http://${hostname}:${port}`)
);

io.on("connection", socket => {
  iocContainer.get<SocketService>(SocketService).newConnection(socket);
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
