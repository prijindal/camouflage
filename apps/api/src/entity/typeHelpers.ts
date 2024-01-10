import { ColumnOptions } from "typeorm";

export const dbType: "postgres" | "mysql" | "better-sqlite3" = (function () {
  if (process.env.POSTGRES_URI) {
    return "postgres";
  }
  if (process.env.MYSQL_URI) {
    return "mysql";
  }
  return "better-sqlite3";
})();

const blobSerializer = {
  to: (value?: any): Buffer | undefined =>
    value ? Buffer.from(JSON.stringify(value), "utf-8") : undefined,
  from: (value?: Buffer): any | undefined =>
    value ? JSON.parse(value.toString("utf-8")) : undefined,
};

export const byteColumnOptions = (options: ColumnOptions = {}): ColumnOptions => {
  if (dbType === "postgres") {
    return {
      ...options,
      type: "bytea",
      transformer: blobSerializer,
    };
  } else if (dbType === "mysql") {
    return {
      ...options,
      type: "longblob",
      transformer: blobSerializer,
    };
  }
  return {
    ...options,
    type: "blob",
    transformer: blobSerializer,
  };
};

export const dateColumnOptions = (options: ColumnOptions = {}): ColumnOptions => {
  if (dbType === "postgres") {
    return {
      ...options,
      type: "timestamptz",
    };
  } else if (dbType === "mysql") {
    return {
      ...options,
      type: "datetime",
    };
  }
  return {
    ...options,
    type: "text",
  };
};
