import "reflect-metadata";

import { logger } from "@repo/logger";
import firebaseAdmin from "firebase-admin";
import { applicationDefault, initializeApp } from "firebase-admin/app";
import { inject } from "inversify";
import { Socket } from "socket.io";
import { singleton } from "../singleton";
import { AuthService } from "./auth.service";
import { UserService } from "./user.service";

type ChatMessage = {
  username: string;
  message_id: string;
  timestamp: string;
  encrypted_payload: string;
};

initializeApp({
  credential: applicationDefault(),
});

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
  constructor(
    @inject(AuthService) private authService: AuthService,
    @inject(UserService) private userService: UserService
  ) {}
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

  async sendNotification(
    username: string,
    notification: string,
    data: Record<string, string>,
    notificationTag: string
  ) {
    // TODO: Move to it's own service
    const user = await this.userService.getOne(username, "username");
    if (user != null && user.notificationToken != null) {
      try {
        const response = await firebaseAdmin.messaging().send({
          token: user.notificationToken,
          data: data,
          notification: {
            title: notification,
          },
          android: {
            notification: {
              tag: notificationTag,
            },
          },
          apns: {
            headers: {
              "apns-collapse-id": notificationTag,
            },
          },
        });
        logger.debug(response);
      } catch (e) {
        logger.error(e);
      }
    } else {
      logger.warn(`Failed to send notification to ${username}`);
    }
  }

  async sendChatMessage(from: string, message: ChatMessage) {
    const to = message.username;
    const instance = this.instances[to];
    if (instance != null) {
      const chatMessage = {
        ...message,
        username: from,
      };
      const response = instance.socket.emit("chat", chatMessage);
      this.sendNotification(to, from, chatMessage, chatMessage.message_id);
      return response;
    } else {
      // Send it to a queue
      throw new Error("Username doesn't have a valid socket");
    }
  }
}
