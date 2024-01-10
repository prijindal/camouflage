import { LoggerOptions } from "typeorm";
import { BaseDataSourceOptions } from "typeorm/data-source/BaseDataSourceOptions";
import { BetterSqlite3ConnectionOptions } from "typeorm/driver/better-sqlite3/BetterSqlite3ConnectionOptions";
import { MysqlConnectionOptions } from "typeorm/driver/mysql/MysqlConnectionOptions";
import { PostgresConnectionOptions } from "typeorm/driver/postgres/PostgresConnectionOptions";
import { User } from "../entity/user.entity";
import { PinoTypeormLogger } from "./typeorm_logger";

const AUTO_MIGRATION = Boolean(process.env.AUTO_MIGRATION || "false");

const logLevel = process.env.LOG_LEVEL || "debug";

const logLevelMap: { [k: string]: LoggerOptions } = {
  info: ["error", "migration", "schema", "warn"],
  debug: "all",
};

const typeOrmLogging: LoggerOptions = logLevelMap[logLevel] || [
  "error",
  "migration",
  "schema",
  "warn",
];

const createOptions = () => {
  let options: Omit<BaseDataSourceOptions, "type"> = {
    entities: [User],
    synchronize: AUTO_MIGRATION,
    logging: typeOrmLogging,
    logger: new PinoTypeormLogger(),
    extra: {
      connectionLimit: 5,
    },
  };

  if (process.env.POSTGRES_URI) {
    return {
      ...options,
      type: "postgres",
      url: process.env.POSTGRES_URI,
    } as PostgresConnectionOptions;
  } else if (process.env.MYSQL_URI) {
    return {
      ...options,
      type: "mysql",
      url: process.env.MYSQL_URI,
    } as MysqlConnectionOptions;
  } else {
    return {
      ...options,
      type: "better-sqlite3",
      database: process.env.DB_PATH || "/tmp/camouflage.db",
    } as BetterSqlite3ConnectionOptions;
  }
};

export const options = createOptions();
