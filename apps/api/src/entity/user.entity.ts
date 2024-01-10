import { Column, Entity } from "typeorm";
import { RootObject } from "./rootObject";

@Entity({
  name: "users",
})
export class User extends RootObject {
  @Column({unique: true})
  public username: string;

  @Column()
  public master_hash: string;

  @Column({})
  public auth_token: string;

  @Column({})
  public public_key: string;
}
