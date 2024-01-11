import { inject } from "inversify";
import { provide } from "inversify-binding-decorators";
import { Get, Route } from "tsoa";
import { TypeOrmConnection } from "../db/typeorm";

@Route()
@provide(HealthController)
export class HealthController {
  constructor(@inject(TypeOrmConnection) private typeOrmConnection: TypeOrmConnection) {}

  @Get("/health")
  getHealth() {
    const db = this.typeOrmConnection.getInstance();
    const statusCode = db != null && db.isInitialized ? 200 : 500;
    return {
      healthy: true,
      db: db != null ? db.isInitialized : false,
    };
  }
}
