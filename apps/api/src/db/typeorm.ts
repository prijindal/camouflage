import { logger } from "@repo/logger";
import { DataSource } from "typeorm";
import { Retrier } from "../helpers/retrier";
import { singleton } from "../singleton";
import { options } from "./typeorm_options";

@singleton(TypeOrmConnection)
export class TypeOrmConnection {
  private _conn: DataSource;
  private _retrier = new Retrier({ limit: 10, delay: 10 * 1000 });

  constructor() {
    this._conn = new DataSource({ ...options });
  }

  connect = async () => {
    try {
      this._conn = new DataSource({ ...options });
      this._conn = await this._retrier.resolve(() => this._conn.initialize());
      logger.info("Database connected");
    } catch (e) {
      logger.error(e);
      throw e;
    }
  };

  getInstance() {
    return this._conn;
  }
}
