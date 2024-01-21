import "reflect-metadata";

import { logger } from "@repo/logger";
import firebaseAdmin from "firebase-admin";
import { applicationDefault, initializeApp } from "firebase-admin/app";
import { inject } from "inversify";
import { Socket } from "socket.io";
import { singleton } from "../singleton";
import { AuthService } from "./auth.service";
import { MessageService } from "./message.service";
import { UserService } from "./user.service";

type ChatMessage = {
  username: string;
  message_id: string;
  timestamp: string;
  encrypted_payload: string;
};

type ReceivedMessage = {
  username: string;
  message_id: string;
  timestamp: string;
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
    @inject(UserService) private userService: UserService,
    @inject(MessageService) private messageService: MessageService
  ) {}
  instances: Record<string, UserSocketServer> = {};

  async newConnection(socket: Socket) {
    try {
      const authorization = socket.handshake.auth.Authorization;
      const user = await this.authService.authorizationVerify(authorization);
      logger.info(`A user connected, ${user.username}`);
      this.instances[user.username] = new UserSocketServer({ username: user.username, socket });
      await this.sendUnreceivedMessages(user.username);
    } catch (e) {
      logger.error(e);
    }
  }

  private async sendUnreceivedMessages(to: string) {
    const messages = await this.messageService.findByToUsername(to);
    for (const message of messages) {
      this.sendChatMessage(message.from, {
        username: message.to,
        encrypted_payload: message.encrypted_payload,
        timestamp: message.timestamp,
        message_id: message.message_id,
      });
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

  async emitToUser(ev: string, username: string, payload: any) {
    try {
      const instance = this.instances[username];
      if (instance != null) {
        const response = instance.socket.emit(ev, payload);
        return response;
      }
    } catch (e) {
      logger.error(e);
    }
  }

  async sendChatMessage(from: string, message: ChatMessage) {
    const to = message.username;
    const chatMessage = {
      ...message,
      username: from,
    };
    // First initiate sending notification
    this.sendNotification(to, from, { ...chatMessage, type: "chat" }, chatMessage.message_id);
    // then emit sending a chat message
    this.emitToUser("chat", to, chatMessage);
  }

  async receivedChatMessage(from: string, message: ReceivedMessage) {
    logger.info(message);
    const to = message.username;
    const instance = this.instances[to];
    if (instance != null) {
      const response = instance.socket.emitWithAck("received", {
        ...message,
        username: from,
      });
      await this.messageService.deleteByMessageId(message.message_id);
      return response;
    } else {
      // Send it to a queue
      throw new Error("Username doesn't have a valid socket");
    }
  }

  async readChatMessage(from: string, message: ReceivedMessage) {
    const to = message.username;
    const instance = this.instances[to];
    if (instance != null) {
      const response = instance.socket.emitWithAck("read", {
        ...message,
        username: from,
      });
      return response;
    } else {
      // Send it to a queue
      throw new Error("Username doesn't have a valid socket");
    }
  }

  isUserOnline(username: string) {
    return (
      this.instances[username] != null &&
      this.instances[username].socket != null &&
      this.instances[username].socket.connected
    );
  }
}
