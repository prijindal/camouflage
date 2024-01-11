import { CreateDateColumn, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";
import { dateColumnOptions } from "./typeHelpers";

export abstract class RootObject {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @CreateDateColumn(dateColumnOptions())
  created_at: Date;

  @UpdateDateColumn(dateColumnOptions())
  updated_at: Date;
}
