import "reflect-metadata";

import { logger } from "@repo/logger";
import { inject } from "inversify";
import { Socket } from "socket.io";
import { singleton } from "../singleton";
import { AuthService } from "./auth.service";

class UserSocketServer {
  constructor({}: { username: string }) {}
}

@singleton(SocketService)
export class SocketService {
  constructor(@inject(AuthService) private authService: AuthService) {}
  instances: Record<string, UserSocketServer> = {};

  async newConnection(socket: Socket) {
    const authorization = socket.handshake.auth.Authorization;
    const user = await this.authService.authorizationVerify(authorization);
    logger.info(`A user connected, ${user.username}`);
    this.instances[user.username] = new UserSocketServer({ username: user.username });
  }
}
