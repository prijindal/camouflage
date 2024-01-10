import { CustomError } from "./error";

export class UserAuthenticationError extends CustomError {
  constructor(
    public username: string,
    details: string,
    message = "Invalid username or password"
  ) {
    super(message, 403, details);
  }
}
