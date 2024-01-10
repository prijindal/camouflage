import { provide } from "inversify-binding-decorators";
import { User } from "../entity/user.entity";
import { BaseTypeOrmService } from "./BaseTypeOrmService";

@provide(UserService)
export class UserService extends BaseTypeOrmService<User> {
  get model() {
    return this.conn.getInstance().getRepository(User);
  }
}
