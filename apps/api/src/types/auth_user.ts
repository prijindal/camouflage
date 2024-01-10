import { Request } from "express";
import { User } from "../entity/user.entity";

export type AuthUser = Omit<User, "auth_token" | "created_at" | "updated_at" | "master_hash" | "id">

export interface SecureRequest extends Request {
  loggedInUser: AuthUser;
  scopes: string[];
}
