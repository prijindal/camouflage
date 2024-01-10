import { logger } from "@repo/logger";
import { TypeOrmConnection } from "./db/typeorm";

import { iocContainer } from "./ioc";

export async function setup() {
  try {
    await Promise.all([iocContainer.get(TypeOrmConnection).connect()]);
  } catch (e) {
    logger.error(e);
    throw e;
  }
}
