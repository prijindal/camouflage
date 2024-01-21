import { Column, Entity } from "typeorm";
import { RootObject } from "./rootObject";
import { byteColumnOptions } from "./typeHelpers";

@Entity({
  name: "messages",
})
export class Message extends RootObject {
  @Column()
  public from: string;

  @Column()
  public to: string;

  @Column(byteColumnOptions())
  public encrypted_payload: string;

  @Column({})
  public message_id: string;

  @Column({})
  public timestamp: string;
}
