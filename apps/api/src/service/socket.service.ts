import "reflect-metadata";

import { logger } from "@repo/logger";
import { inject } from "inversify";
import { Socket } from "socket.io";
import { singleton } from "../singleton";
import { AuthService } from "./auth.service";

type ChatMessage = {
  username: string;
  message_id: string;
  timestamp: string;
  encrypted_payload: string;
};

class UserSocketServer {
  username: string;
  socket: Socket;
  constructor({ username, socket }: { username: string; socket: Socket }) {
    this.username = username;
    this.socket = socket;
  }
}

@singleton(SocketService)
export class SocketService {
  constructor(@inject(AuthService) private authService: AuthService) {}
  instances: Record<string, UserSocketServer> = {};

  async newConnection(socket: Socket) {
    try {
      const authorization = socket.handshake.auth.Authorization;
      const user = await this.authService.authorizationVerify(authorization);
      logger.info(`A user connected, ${user.username}`);
      this.instances[user.username] = new UserSocketServer({ username: user.username, socket });
    } catch (e) {
      logger.error(e);
    }
  }

  async sendChatMessage(from: string, message: ChatMessage) {
    const to = message.username;
    if (this.instances[to] != null) {
      const response = this.instances[to].socket.emit("chat", {
        ...message,
        username: from,
      });
      return response;
    } else {
      // Send it to a queue
      throw new Error("Username doesn't have a valid socket");
    }
  }
}
