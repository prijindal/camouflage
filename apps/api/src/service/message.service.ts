import { provide } from "inversify-binding-decorators";
import { Message } from "../entity/message.entity";
import { BaseTypeOrmService } from "./BaseTypeOrmService";

@provide(MessageService)
export class MessageService extends BaseTypeOrmService<Message> {
  get model() {
    return this.conn.getInstance().getRepository(Message);
  }

  override create(newResource: Omit<Message, "id" | "created_at" | "updated_at">) {
    return super.create(newResource);
  }

  deleteByMessageId(message_id: string) {
    return super.deleteMany({ message_id });
  }

  findByToUsername(to: string) {
    return super.find({
      where: {
        to,
      },
    });
  }
}
