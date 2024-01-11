import { inject } from "inversify";
import { Body, Post, Request, Route, Security, Tags } from "tsoa";
import { SocketService } from "../service/socket.service";
import { singleton } from "../singleton";
import { SecureRequest } from "../types/auth_user";

@Route("chat")
@Tags("chat")
@singleton(ChatController)
export class ChatController {
  constructor(@inject(SocketService) private socketService: SocketService) {}

  @Post("/message")
  @Security("bearer")
  public async getMe(
    @Body()
    body: {
      username: string;
      encrypted_payload: string;
      timestamp: string;
      message_id: string;
    },
    @Request() request: SecureRequest
  ) {
    const from = request.loggedInUser.username;
    const ack = await this.socketService.sendChatMessage(from, body);
    return ack;
  }
}
